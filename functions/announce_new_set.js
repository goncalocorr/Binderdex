/**
 * Função MANUAL para anunciar uma coleção (set) nova a todos os utilizadores.
 * Os sets não estão no Firestore, por isso não há gatilho automático — disparas
 * tu por HTTP quando sair um set.
 *
 * NÃO está ligada por omissão (precisa do Secret Manager). Para a ativar:
 *
 *   1. Ativar a API Secret Manager (uma vez):
 *        gcloud services enable secretmanager.googleapis.com
 *      (ou visita o link que o deploy mostrar e ativa no painel)
 *
 *   2. Definir o segredo (escolhes a password):
 *        firebase functions:secrets:set ANNOUNCE_SECRET
 *
 *   3. Ligar esta função: no fim de functions/index.js acrescenta
 *        require("./announce_new_set")(exports);
 *
 *   4. Redeploy:
 *        firebase deploy --only functions
 *
 * Disparar (quando sair um set):
 *   https://europe-west1-binderdex-b1908.cloudfunctions.net/announceNewSet?key=SEGREDO&setId=sv8&name=Surging%20Sparks
 */
const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");

const ANNOUNCE_SECRET = defineSecret("ANNOUNCE_SECRET");

module.exports = function register(exportsObj) {
  exportsObj.announceNewSet = onRequest(
    { secrets: [ANNOUNCE_SECRET] },
    async (req, res) => {
      const secret = ANNOUNCE_SECRET.value();
      if (!secret || req.query.key !== secret) {
        res.status(403).send("forbidden");
        return;
      }
      const db = admin.firestore();
      const messaging = admin.messaging();
      const setId = String(req.query.setId || "");
      const name = String(req.query.name || "Nova coleção");

      const usersSnap = await db.collection("users").get();
      let delivered = 0;
      for (const doc of usersSnap.docs) {
        const data = doc.data() || {};
        const tokens = Array.isArray(data.fcmTokens) ? data.fcmTokens : [];
        if (!tokens.length) continue;
        const r = await messaging.sendEachForMulticast({
          tokens,
          notification: { title: "Nova coleção!", body: name },
          data: { type: "newSet", setId },
          android: { priority: "high" },
        });
        delivered += r.successCount;
      }
      res.json({ ok: true, delivered });
    }
  );
};
