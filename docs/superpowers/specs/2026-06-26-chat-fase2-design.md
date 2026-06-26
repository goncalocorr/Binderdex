# Chat (Fase 2) — Design

**Data:** 2026-06-26 · **App:** Binderdex · **Estado:** Aprovado.

## Resumo
Mensagens privadas entre utilizadores da Comunidade, para combinar trocas/vendas.
Liga o botão "Contactar" do detalhe do anúncio. **1 conversa por par de
utilizadores** (não por anúncio). Inclui um **aviso de burla** quando uma
mensagem recebida partilha email/telemóvel.

## Decisões
- Conversa = **por par** (convId determinístico dos 2 uids ordenados).
- Aviso de burla mostrado a **quem recebe** (deteção por regex no cliente).
- Entradas: **ícone 💬 na Comunidade** (com badge de não-lidas) **e** linha
  **"Mensagens" no Perfil**.
- Só **texto** (sem imagens/anexos), sem indicador de "a escrever". (YAGNI)

## Modelo de dados (Firestore)
```
conversations/{convId}            // convId = sorted(uidA,uidB).join('_')
  participants: [uidA, uidB]
  names:   { uidA: 'Ana', uidB: 'Rui' }      // desnormalizado
  avatars: { uidA: 'avatar_01', uidB: '' }
  lastMessage: string
  lastSenderUid: string
  updatedAt: serverTimestamp
  unread: { uidA: int, uidB: int }           // não-lidas por participante

conversations/{convId}/messages/{msgId}
  senderUid: string
  text: string
  createdAt: serverTimestamp
```

## Lógica pura (testável)
- **`conversationIdFor(a, b)`** → `[a,b]..sort()` juntos por `_`. Determinístico
  e simétrico (`idFor(a,b) == idFor(b,a)`).
- **`messageHasContact(text)`** → `true` se o texto contém email
  (`\S+@\S+\.\S+`) ou um número de telemóvel (sequência de 9+ dígitos,
  tolerando espaços/`+`/`-`). Usado para o aviso de burla.

## Camada de dados — `ChatService`
```dart
Stream<List<Conversation>> watchConversations(String uid);   // array-contains + orderBy updatedAt
Stream<List<ChatMessage>>  watchMessages(String convId);     // orderBy createdAt
Future<String> openConversation({                            // cria se não existir; devolve convId
  required String meUid, required String meName, required String meAvatar,
  required String otherUid, required String otherName, required String otherAvatar });
Future<void> sendMessage({ required String convId, required String senderUid,
  required String otherUid, required String text });         // msg + update conversa + incr unread do outro
Future<void> markRead(String convId, String uid);            // zera o meu unread
```
`sendMessage` usa um batch: cria a mensagem + atualiza
`lastMessage/lastSenderUid/updatedAt` + `unread.{otherUid} += 1`.

## Entidades de domínio
```dart
class Conversation { String id, otherUid, otherName, otherAvatar, lastMessage,
  lastSenderUid; int unread; DateTime updatedAt; }   // "other" resolvido p/ o uid atual
class ChatMessage { String id, senderUid, text; DateTime createdAt; }
```

## Apresentação
- **`MessagesScreen`** (`/messages`): lista de `watchConversations`, ordenada por
  recência; cada linha = avatar+nome do outro, prévia, **badge** se `unread>0`.
  Conversas com utilizadores **bloqueados** são filtradas (reusa
  `blockedUidsProvider`). Vazio → `EmptyState`.
- **`ChatScreen`** (`/chat`, recebe a `Conversation` via `extra`): stream de
  mensagens em balões (meus à direita). Mensagens **recebidas** com
  `messageHasContact` mostram por baixo um aviso destacado (ícone + texto de
  isenção). Campo de texto + enviar. `markRead` ao abrir. App bar: **Bloquear**.
- **Entradas:** ícone 💬 no `community_screen` (badge via novo
  `unreadTotalProvider`); linha "Mensagens" em `settings_screen`. O botão
  **"Contactar"** em `listing_detail_screen` deixa de ser "em breve" → abre a
  conversa (`openConversation` → push `/chat`); escondido se
  `listing.ownerUid == meuUid`.

## Providers
`chatServiceProvider`, `conversationsProvider` (StreamProvider, filtra
bloqueados), `messagesProvider.family(convId)`, `unreadTotalProvider`
(soma dos `unread` das conversas).

## Regras Firestore
```
match /conversations/{cid} {
  allow read:  if request.auth != null && request.auth.uid in resource.data.participants;
  allow create: if request.auth != null && request.auth.uid in request.resource.data.participants;
  allow update: if request.auth != null && request.auth.uid in resource.data.participants;
  match /messages/{mid} {
    allow read: if request.auth != null
      && request.auth.uid in get(/databases/$(database)/documents/conversations/$(cid)).data.participants;
    allow create: if request.auth != null
      && request.resource.data.senderUid == request.auth.uid
      && request.auth.uid in get(/databases/$(database)/documents/conversations/$(cid)).data.participants;
  }
}
```
Anónimos não podem enviar (já são tratados como não-autenticados na app; reforço
opcional: exigir `sign_in_provider != 'anonymous'` no create — fora de âmbito v1).

## Índice
`conversations`: `participants` (ARRAY_CONTAINS) + `updatedAt` (DESC).

## Testes
- `conversationIdFor` — determinístico e simétrico.
- `messageHasContact` — apanha emails e telemóveis (9+ dígitos, com espaços/`+`);
  não dá falso-positivo em texto normal nem em números curtos (ex.: "tenho 3").
- `Conversation.fromDoc` / `ChatMessage.fromMap` — mapeamento.
O fluxo Firestore real (enviar/receber/badge) é verificado em dispositivo +
`firebase deploy --only firestore:rules,firestore:indexes`.

## Fora de âmbito (futuro)
Imagens/anexos, "a escrever…", apagar mensagens, notificações push, denúncia de
mensagens (já há denúncia de anúncios).
