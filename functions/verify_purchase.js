const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const { google } = require("googleapis");
const { subStateFromV2 } = require("./billing");

const PACKAGE = "com.binderdex.app";
const PRODUCT_ID = "binderdex_premium";

let _publisher;
async function publisher() {
  if (_publisher) return _publisher;
  // Usa a conta de serviço da função (ADC). Conceder-lhe acesso na Play Console.
  const auth = new google.auth.GoogleAuth({
    scopes: ["https://www.googleapis.com/auth/androidpublisher"],
  });
  _publisher = google.androidpublisher({ version: "v3", auth });
  return _publisher;
}

exports.verifyPurchase = onCall(async (request) => {
  const uid = request.auth && request.auth.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Sessao necessaria.");
  const token = request.data && request.data.purchaseToken;
  if (!token) throw new HttpsError("invalid-argument", "purchaseToken em falta.");

  const ap = await publisher();
  let resp;
  try {
    const r = await ap.purchases.subscriptionsv2.get({
      packageName: PACKAGE,
      token,
    });
    resp = r.data;
  } catch (e) {
    throw new HttpsError("not-found", "Compra invalida ou nao encontrada.");
  }

  const s = subStateFromV2(resp);
  // Segurança: o token tem de pertencer a quem chama. Na compra marcamos
  // obfuscatedAccountId = uid; a Play devolve-o em externalAccountIdentifiers.
  // Se não bater, é uma tentativa de usar o token de outra conta — rejeita.
  if (s.uid && s.uid !== uid) {
    throw new HttpsError("permission-denied", "Compra de outra conta.");
  }
  const db = admin.firestore();
  await db.collection("users").doc(uid).set(
    {
      marketTier: s.tier,
      sub: {
        productId: PRODUCT_ID,
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
  await db
    .collection("purchaseTokens")
    .doc(token)
    .set({ uid, basePlanId: s.basePlanId });

  // Upgrade/downgrade: limpa o mapeamento do token antigo substituido.
  if (resp.linkedPurchaseToken) {
    await db
      .collection("purchaseTokens")
      .doc(resp.linkedPurchaseToken)
      .delete()
      .catch(() => {});
  }

  return { tier: s.tier, expiryMs: s.expiryMs, state: s.state };
});
