const { onMessagePublished } = require("firebase-functions/v2/pubsub");
const admin = require("firebase-admin");
const { google } = require("googleapis");
const { decodeRtdn, subStateFromV2 } = require("./billing");

const PACKAGE = "com.binderdex.app";

let _ap;
async function publisher() {
  if (_ap) return _ap;
  const auth = new google.auth.GoogleAuth({
    scopes: ["https://www.googleapis.com/auth/androidpublisher"],
  });
  _ap = google.androidpublisher({ version: "v3", auth });
  return _ap;
}

/** Resolve o uid: pela Play (obfuscated id) ou pelo mapeamento purchaseTokens. */
async function resolveUid(db, state, token) {
  if (state.uid) return state.uid;
  const map = await db.collection("purchaseTokens").doc(token).get();
  return map.exists ? map.data().uid : null;
}

exports.playRtdn = onMessagePublished("play-rtdn", async (event) => {
  const note = decodeRtdn(event.data.message.data);
  const sub = note && note.subscriptionNotification;
  if (!sub || !sub.purchaseToken) return; // ignora outros tipos (voided/test)
  const token = sub.purchaseToken;

  const ap = await publisher();
  let resp;
  try {
    const r = await ap.purchases.subscriptionsv2.get({ packageName: PACKAGE, token });
    resp = r.data;
  } catch (_) {
    return; // token desconhecido/invalido — nada a fazer
  }

  const s = subStateFromV2(resp);
  const db = admin.firestore();
  const uid = await resolveUid(db, s, token);
  if (!uid) return; // sem dono resolúvel — ignora

  const userRef = db.collection("users").doc(uid);
  const snap = await userRef.get();
  const current = (snap.data() && snap.data().sub) || {};

  // GUARDA DE STALENESS: só age se for o token autoritativo do utilizador.
  if (current.purchaseToken && current.purchaseToken !== token) {
    // Token antigo (resubscrição/upgrade) — limpa o mapeamento, não toca no tier.
    await db.collection("purchaseTokens").doc(token).delete().catch(() => {});
    return;
  }

  await userRef.set(
    {
      marketTier: s.tier,
      sub: {
        productId: current.productId || "binderdex_premium",
        basePlanId: s.basePlanId,
        state: s.state,
        expiryMs: s.expiryMs,
        autoRenewing: s.autoRenewing,
        purchaseToken: token,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
    },
    { merge: true }
  );
});
