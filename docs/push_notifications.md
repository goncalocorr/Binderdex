# Notificações push (FCM)

Tem **duas partes, ambas já escritas**:

- **App (cliente)** — pede permissão, guarda o token, mostra/encaminha as
  notificações. Ver [`lib/data/remote/push_service.dart`](../lib/data/remote/push_service.dart).
- **Servidor (Cloud Functions)** — envia o push quando algo acontece no
  Firestore. Ver [`functions/index.js`](../functions/index.js).

Falta só **ativar o plano Blaze** e fazer **deploy** das functions.

## O que a app faz (cliente)

- Pede permissão de notificações ao iniciar sessão com conta (não convidado).
- Guarda o **token FCM** em `users/{uid}.fcmTokens` (lista). Atualiza no refresh.
- "Seguir carta" (sino) guarda também em `users/{uid}.notifyCards` (lista).
- Em primeiro plano mostra a notificação; ao tocar abre o ecrã certo.
- Ao terminar sessão, remove o token deste dispositivo.

## Convenção do payload (`data`)

| `data.type` | Campos extra | Abre na app                          |
|-------------|--------------|--------------------------------------|
| `message`   | —            | `/messages` (caixa de mensagens)     |
| `listing`   | `cardId`     | `/community/card/<cardId>` (ofertas) |
| `newSet`    | `setId`      | `/notifications` (centro)            |

## Cloud Functions (já implementadas em `functions/index.js`)

Região **europe-west1** (perto do Firestore `eur3`).

1. **`onNewMessage`** — `conversations/{cid}/messages/{mid}` onCreate → notifica o
   destinatário (o participante que não é o remetente). Salta quem bloqueou o
   remetente.
2. **`onNewListing`** — `listings/{id}` onCreate → notifica quem segue essa carta
   (`users` com `notifyCards array-contains cardId`), exceto o próprio dono e
   quem o bloqueou.
3. **`announceNewSet`** — HTTP **manual** (os sets não estão no Firestore). Disparas
   tu quando sair uma coleção. Protegida por segredo `ANNOUNCE_SECRET`.

Limpeza automática: tokens inválidos são removidos de `users/{uid}.fcmTokens`.

## Como pôr a funcionar (uma vez)

```bash
# 1. Ativar o plano Blaze na consola Firebase (Definições → Uso e faturação).
#    Recomendado: definir um alerta/limite de orçamento.

# 2. (opcional, só para o anúncio de coleções) definir o segredo:
firebase functions:secrets:set ANNOUNCE_SECRET   # escolhe uma password

# 3. Deploy das functions:
firebase deploy --only functions
```

Disparar um anúncio de coleção nova (gatilho 3, manual):
```
https://europe-west1-binderdex-b1908.cloudfunctions.net/announceNewSet?key=SEGREDO&setId=sv8&name=Surging%20Sparks
```

## Testar
- **Sem deploy:** Consola Firebase → Cloud Messaging → "Enviar mensagem de teste"
  → cola um token (vê-o em `users/{uid}.fcmTokens`). Confirma que chega.
- **Com deploy:** envia uma mensagem de chat de uma conta para outra — a outra
  deve receber push (app fechada/2.º plano) ou o aviso local (1.º plano).
- Logs: `firebase functions:log`.

## Notas
- **iOS:** falta configurar **APNs** no Firebase (certificado/chave). Android não precisa.
- Ícone de notificação: usa o do launcher por agora; um `drawable` branco dedicado
  fica melhor na barra de estado.
