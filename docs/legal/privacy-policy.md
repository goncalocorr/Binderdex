# Política de Privacidade — Binderdex

> ⚠️ **Versão canónica (a alojar):** [`docs/privacy.html`](../privacy.html) —
> atualizada (28/06/2026) com comunidade, chat, notificações e moderação.
> O texto abaixo é a versão antiga (só coleção/sync) e fica como histórico.

_Última atualização: 23 de junho de 2026_

A Binderdex ("a app") é um registo pessoal de coleções de cartas. Esta política
explica que dados a app trata e porquê. A app é **local-first**: funciona sem
conta e a tua coleção fica no teu dispositivo; só sincroniza para a nuvem se
**escolheres** iniciar sessão.

## Quem é o responsável
A app é desenvolvida por **hivecode** (contacto: hivecode.comercial@gmail.com).

## Que dados tratamos

| Dado | Quando | Para quê | Onde |
|---|---|---|---|
| **Email** | Só se criares conta / iniciares sessão | Autenticar-te e ligar a tua coleção entre dispositivos | Firebase Authentication |
| **A tua coleção** (cartas que tens, variantes, quantidades, notas, lista de desejos) | Ao usares a app | Mostrar progresso e o que falta | No dispositivo (sempre) e, com sessão iniciada, no Cloud Firestore |
| **Identificador de conta (UID)** | Com sessão iniciada | Associar a coleção à tua conta | Firebase |

**Não** recolhemos: localização, contactos, ficheiros, dados de pagamento,
publicidade ou identificadores de tracking. **Não** usamos analytics. **Não**
vendemos nem partilhamos dados com terceiros para fins de marketing.

## Subcontratantes
Usamos o **Google Firebase** (Authentication e Cloud Firestore) como
processador de dados, exclusivamente para autenticação e sincronização. Os dados
são transmitidos de forma **encriptada (HTTPS/TLS)**.

## Conservação e eliminação
- Sem conta, os dados existem apenas no teu dispositivo; desinstalar a app
  remove-os.
- Com conta, podes **eliminar a conta** a qualquer momento em **Perfil →
  Eliminar conta**, o que apaga a tua coleção da nuvem **e** do dispositivo, e
  remove a tua conta de autenticação (direito ao esquecimento — RGPD).

## Os teus direitos (RGPD)
Tens direito de acesso, retificação, eliminação e portabilidade. A eliminação
está disponível na app; para os restantes pedidos, contacta o email acima.

## Crianças
A app não se destina a recolher dados de crianças e não pede dados pessoais para
além do email opcional de início de sessão.

## Alterações
Podemos atualizar esta política; a data acima reflete a última versão.
