# Play Store — Data Safety (mapeamento)

Guia para preencher o formulário **Data safety** da Google Play Console.
Reflete o comportamento real da app (coleção local-first + comunidade opcional:
marketplace, chat, notificações, moderação).

## Resumo
- **Recolhe dados?** Sim — só com início de sessão (opcional). Sem conta, tudo
  fica no dispositivo.
- **Partilha com terceiros?** Não para fins próprios de terceiros. O Firebase é
  **subcontratante**. Dentro da app, anúncios/mensagens são visíveis a outros
  utilizadores (é a função da comunidade, não "partilha com terceiros").
- **Encriptação em trânsito?** Sim (HTTPS/TLS via Firebase).
- **O utilizador pode pedir a eliminação?** Sim — Perfil → Eliminar conta
  (remove a coleção); o resto a pedido por email.

## Dados recolhidos (Data collected)

| Categoria (Play) | Tipo | Recolhido | Opcional | Finalidade |
|---|---|---|---|---|
| Informações pessoais | Email | Sim (só com conta) | Sim | Conta / autenticação |
| Informações pessoais | Nome de apresentação (à escolha) | Sim (só com conta) | Sim | Identificação na comunidade |
| Identificadores | User ID (UID) + token do dispositivo (FCM) | Sim (só com conta) | Sim | Sincronização e notificações |
| Mensagens | Mensagens de chat (texto) | Sim (se usar o chat) | Sim | Conversa entre utilizadores |
| Atividade na app | Coleção (cartas, quantidades, notas, wishlist) + anúncios | Sim (só com conta) | Sim | Funcionalidade da app |
| Atividade na app | Denúncias / sugestões / apelações (texto) | Sim (se enviar) | Sim | Moderação / melhoria |

**Nota "partilha":** nome/avatar, anúncios e mensagens são **visíveis a outros
utilizadores** pela natureza da comunidade. Na Play declara-se como *recolhido*
(não como "partilhado com terceiros", que é para empresas terceiras).

## Práticas de segurança a declarar
- ✅ Dados encriptados em trânsito.
- ✅ O utilizador pode pedir a eliminação dos dados.
- ✅ Sem recolha obrigatória: a app é utilizável sem conta.

## NÃO recolhido
Localização · Contactos · Fotos/vídeos/ficheiros do dispositivo · Áudio ·
Saúde · Histórico de navegação · Publicidade/tracking · Analytics.

## Quando ligares o Play Billing (premium pago)
Acrescentar **"Compras na app"** — processadas pela Google. A app não guarda
dados de cartão.

## Política de privacidade (URL público — obrigatório)
Ficheiro a alojar: `docs/privacy.html`. Com o GitHub Pages ativo (ver
`docs/launch-checklist.md`), o URL fica:
`https://goncalocorr.github.io/Binderdex/privacy.html`
