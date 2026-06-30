/**
 * Cloud Functions do Binderdex — envio de notificações push (FCM).
 *
 * Gatilhos:
 *   1. onNewMessage   — nova mensagem no chat → notifica o destinatário
 *   2. onNewListing   — carta seguida posta à venda/troca → notifica seguidores
 *   3. announceNewSet — (HTTP, manual) anuncia uma coleção nova a todos
 *
 * A app guarda os tokens em users/{uid}.fcmTokens e o "seguir carta" em
 * users/{uid}.notifyCards. Ver docs/push_notifications.md.
 */
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();

// europe-west1 fica perto do Firestore (eur3) → menos latência.
setGlobalOptions({ region: "europe-west1", maxInstances: 10 });

/** Tokens FCM de um utilizador. */
async function tokensOf(uid) {
  const snap = await db.collection("users").doc(uid).get();
  const d = snap.data() || {};
  return Array.isArray(d.fcmTokens) ? d.fcmTokens : [];
}

/**
 * Envia uma notificação a uma lista de tokens e limpa os que já não são
 * válidos do documento do utilizador.
 */
async function sendToTokens(uid, tokens, notification, data) {
  if (!tokens || tokens.length === 0) return 0;
  const res = await messaging.sendEachForMulticast({
    tokens,
    notification,
    data: data || {},
    android: { priority: "high" },
  });
  const invalid = [];
  res.responses.forEach((r, i) => {
    if (!r.success) {
      const code = r.error && r.error.code;
      if (
        code === "messaging/registration-token-not-registered" ||
        code === "messaging/invalid-registration-token" ||
        code === "messaging/invalid-argument"
      ) {
        invalid.push(tokens[i]);
      }
    }
  });
  if (invalid.length) {
    await db
      .collection("users")
      .doc(uid)
      .update({ fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalid) })
      .catch(() => {});
  }
  return res.successCount;
}

/** Verdadeiro se `uid` bloqueou `otherUid`. */
async function hasBlocked(uid, otherUid) {
  const snap = await db
    .collection("users")
    .doc(uid)
    .collection("blocks")
    .doc(otherUid)
    .get();
  return snap.exists;
}

// 1) Nova mensagem no chat → notifica o destinatário.
exports.onNewMessage = onDocumentCreated(
  "conversations/{cid}/messages/{mid}",
  async (event) => {
    const msg = event.data && event.data.data();
    if (!msg) return;
    const sender = msg.senderUid;
    if (!sender) return;

    const convSnap = await db
      .collection("conversations")
      .doc(event.params.cid)
      .get();
    const conv = convSnap.data();
    if (!conv) return;

    const participants = conv.participants || [];
    const recipient = participants.find((u) => u !== sender);
    if (!recipient) return;

    // Não notificar quem bloqueou o remetente.
    if (await hasBlocked(recipient, sender)) return;

    const senderName = (conv.names && conv.names[sender]) || "Nova mensagem";
    const body = conv.cardName
      ? `${conv.cardName}: ${msg.text || ""}`.trim()
      : msg.text || "Enviou-te uma mensagem";

    const tokens = await tokensOf(recipient);
    await sendToTokens(
      recipient,
      tokens,
      { title: senderName, body },
      { type: "message" }
    );
  }
);

// 2) Carta seguida posta à venda/troca → notifica os seguidores.
exports.onNewListing = onDocumentCreated("listings/{id}", async (event) => {
  const l = event.data && event.data.data();
  if (!l || !l.cardId) return;
  const cardId = l.cardId;
  const owner = l.ownerUid;

  const watchers = await db
    .collection("users")
    .where("notifyCards", "array-contains", cardId)
    .get();
  if (watchers.empty) return;

  const title = l.cardName
    ? `${l.cardName} disponível na Comunidade!`
    : "Uma carta que segues está disponível!";
  const body = "Alguém acabou de a pôr à venda ou troca.";

  await Promise.all(
    watchers.docs.map(async (doc) => {
      const uid = doc.id;
      if (uid === owner) return; // não notificar o próprio anunciante
      if (await hasBlocked(uid, owner)) return; // bloqueou o dono → ignora
      const data = doc.data() || {};
      const tokens = Array.isArray(data.fcmTokens) ? data.fcmTokens : [];
      await sendToTokens(uid, tokens, { title, body }, { type: "listing", cardId });
    })
  );
});

// 3) Anúncio de coleção nova (manual, HTTP) → functions/announce_new_set.js.
//    Usa o segredo ANNOUNCE_SECRET (Secret Manager).
// 4) Verificacao de compra (callable) + 5) RTDN (Pub/Sub) — Play Billing.
Object.assign(exports, require("./verify_purchase"));
Object.assign(exports, require("./play_rtdn"));
require("./announce_new_set")(exports);
