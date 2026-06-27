# Notificações push (FCM)

A **app já está pronta** para receber push. Falta só a parte do servidor — as
**Cloud Functions** que enviam a notificação quando algo acontece no Firestore.
Isto exige o plano **Blaze** (pay-as-you-go) no Firebase.

## O que a app já faz (lado do cliente)

- Pede permissão de notificações ao iniciar sessão com conta (não convidado).
- Obtém o **token FCM** do dispositivo e guarda-o em `users/{uid}.fcmTokens`
  (lista — vários dispositivos = vários tokens). Atualiza no refresh do token.
- Em primeiro plano, mostra a notificação (via `flutter_local_notifications`).
- Ao tocar na notificação, abre o ecrã certo (ver convenção abaixo).
- Ao terminar sessão, remove o token deste dispositivo da conta.

Código: [`lib/data/remote/push_service.dart`](../lib/data/remote/push_service.dart).

## Convenção do payload (`data`)

As Functions devem enviar `notification` (título/corpo) **e** `data` com `type`:

| `data.type` | Campos extra      | Abre na app                         |
|-------------|-------------------|-------------------------------------|
| `message`   | —                 | `/messages` (caixa de mensagens)    |
| `listing`   | `cardId`          | `/community/card/<cardId>` (ofertas)|
| `newSet`    | `setId`           | `/notifications` (centro)           |

## Cloud Functions a implementar (3 gatilhos)

Pré-requisitos: `firebase init functions` (Node), plano **Blaze**, depois
`firebase deploy --only functions`. Lógica (pseudocódigo):

### 1. Nova mensagem no chat
`onCreate` em `conversations/{cid}/messages/{mid}`:
1. Ler a conversa `cid` → `participants`, `names`.
2. Destinatário = participante que **não** é `senderUid`.
3. Ler `users/{destinatario}.fcmTokens`.
4. `sendEachForMulticast` com `notification {title: nome do remetente, body: texto}`
   e `data {type: 'message'}`.

### 2. Carta seguida posta à venda/troca
`onCreate` em `listings/{id}`:
1. `cardId = listing.cardId`.
2. Procurar utilizadores que seguem essa carta. **Nota:** hoje o "seguir carta"
   (`notifyCards`) está só em `SharedPreferences` no cliente. Para o servidor
   saber, é preciso passar a guardar também no Firestore (ex.: coleção
   `cardWatchers/{cardId}/users/{uid}` ou `users/{uid}.notifyCards`).
3. Para cada seguidor (≠ `ownerUid`, e que não tenha bloqueado o dono): enviar
   `data {type: 'listing', cardId}`.

### 3. Coleção (set) nova
`onCreate` em `sets/{setId}` (se/quando os sets forem escritos no Firestore) ou
uma função agendada que compara com o catálogo: enviar a todos os tokens
`data {type: 'newSet', setId}`.

## Por fazer antes de ligar isto
- [ ] Ativar o plano **Blaze** na consola Firebase.
- [ ] Persistir o "seguir carta" (`notifyCards`) no Firestore (gatilho 2).
- [ ] (iOS) Configurar **APNs** no Firebase (certificado/chave) — Android não precisa.
- [ ] Ícone branco de notificação dedicado (`drawable`), senão usa o do launcher.
