# Especificação de Design — App Pokédex (Caderneta de Coleção)

- **Data:** 2026-06-17
- **Estado:** Aprovado o desenho geral; a aguardar revisão final desta spec
- **Autor:** Sessão de brainstorming (agente + utilizador)

---

## 1. Visão Geral

App móvel **Flutter/Dart** para a Google Play que funciona como **caderneta pessoal de
coleção de Pokémon**. Lista todos os Pokémon (Pokédex Nacional, todas as gerações,
~1025+), o utilizador marca quais "tem", e a app mostra o que falta com indicadores de
progresso. **Local-first / offline-first**, com sincronização opcional na nuvem.

### Princípios

- **Local-first:** a app é 100% utilizável offline e sem conta.
- **Sync opcional:** a nuvem só serve para manter a coleção entre dispositivos.
- **Privacidade primeiro:** dados mínimos, sem tracking, conforme RGPD.
- **Arquitetura limpa por camadas:** data / domain / presentation.
- **Pronta para freemium:** pontos premium marcados, **sem** pagamentos nesta fase.

---

## 2. Stack Técnica

| Área | Escolha |
|------|---------|
| Framework | Flutter + Dart |
| Estado | Riverpod |
| BD local (offline-first) | **Drift** (SQLite tipado, queries reativas) |
| Nuvem | Firebase: **Auth** (Anonymous + Google + email/password) e **Cloud Firestore** |
| HTTP | dio (apenas no script de geração e em refresh do dataset) |
| Imagens | cached_network_image (URLs determinísticos da arte oficial) |
| Navegação | GoRouter |
| i18n | flutter_localizations + intl (.arb: PT + EN) |
| UI | Material 3, claro/escuro/sistema |
| Ícone/Splash | flutter_launcher_icons + flutter_native_splash |

**Requisitos de publicação:** minSdk 26 (Android 8.0), só permissão de Internet, sem
dados sensíveis, pronto para gerar **Android App Bundle (.aab) assinado**.

---

## 3. Estrutura de Pastas

```
lib/
├── main.dart                      # bootstrap: Firebase, ProviderScope, hidratação do dataset
├── app.dart                       # MaterialApp, tema, localização, router
├── core/
│   ├── theme/                     # Material 3 claro/escuro, cores por tipo de Pokémon
│   ├── router/                    # GoRouter
│   ├── premium/                   # ⭐ feature gates freemium (marcados, não implementados)
│   ├── errors/                    # Failures e exceções
│   └── utils/                     # helpers (ex.: URL de sprite a partir do nº)
├── l10n/                          # app_pt.arb, app_en.arb
├── data/
│   ├── local/                     # Drift: database, tabelas, DAOs
│   ├── seed/                      # carregador do dataset incluído (assets → Drift) + version check
│   ├── remote/                    # Firestore (sync da coleção)
│   └── repositories/              # implementações dos repositórios
├── domain/
│   ├── entities/                  # Pokemon, PokemonType, UserEntry, Progress...
│   └── repositories/              # interfaces (contratos)
└── presentation/
    ├── providers/                 # Riverpod (auth, catálogo, coleção, filtros, progresso)
    ├── screens/                   # ecrãs (ver §7)
    └── widgets/                   # cartões, chips de tipo, badges shiny, barras de progresso

tool/
└── generate_dataset.dart          # PokéAPI → assets/data/pokedex.json (+ dataset_version.json)
assets/
└── data/pokedex.json              # dataset gerado (todas as gerações)
web_legal/                         # política de privacidade + pedido de eliminação de conta (estático)
test/                              # testes unitários + de widget
android/                           # config de assinatura para .aab
firestore.rules                    # regras de segurança
```

---

## 4. Camada de Dados — Dataset incluído (abordagem C)

### 4.1 Geração do dataset
`tool/generate_dataset.dart` corre **na máquina de build, uma vez por versão**:
1. Percorre a PokéAPI (`/pokemon`, `/pokemon-species`).
2. Extrai por Pokémon: nº (id nacional), nome, tipos, estatísticas base, descrição/lore,
   geração. **Nome e lore em PT quando existir, fallback EN.**
3. Grava `assets/data/pokedex.json` (estrutura compacta) e `dataset_version.json` (nº de
   versão + data).
4. **Imagens não são incluídas** — usamos o URL determinístico da arte oficial:
   - Normal: `.../official-artwork/{id}.png`
   - Shiny: `.../official-artwork/shiny/{id}.png`
   - Caching via `cached_network_image`.

### 4.2 Hidratação
- **Primeiro arranque:** lê o asset e popula o Drift (offline imediato).
- **Arranques seguintes:** lê só do Drift.

### 4.3 Atualização leve do dataset (confirmado)
- O dataset incluído é a base — funciona offline para sempre.
- **Alojamento:** `dataset_version.json` + `pokedex.json` no **Firebase Hosting** (mesmo
  domínio da política de privacidade; sem segundo serviço).
- **Versionamento:** `dataset_version.json` contém um inteiro `datasetVersion` + `generatedAt`.
  O asset incluído carrega o seu próprio `datasetVersion`; a app compara o inteiro local com
  o remoto.
- No arranque (com rede), a app consulta o `dataset_version.json` remoto. Se o inteiro remoto
  for maior, descarrega `pokedex.json` em **segundo plano** e reidrata o Drift. **Pokémon
  novos entram sem esperar por atualização na Play Store.**
- Sem rede → ignora silenciosamente e usa o dataset incluído.

### 4.4 Drift (local)
- **`pokemon`** (catálogo estático): id, nome, tipos, stats, descrição, geração. Índices
  em nome, geração e tipo.
- **`user_entries`** (coleção): pokemonId, `caught`, `shiny`, `quantity`, `notes`,
  `updatedAt` (timestamp local da última edição), `dirty` (pendente de sync).
- **Filtros e pesquisa são feitos em SQL** (`WHERE`, `LIKE`, índices) — nunca em memória
  sobre os ~1025. Queries reativas (Streams) → a UI atualiza-se sozinha.

---

## 5. Autenticação, Sincronização e Conflitos

### 5.1 Autenticação (login opcional)
- **Sem ecrã de login obrigatório.** A app abre em modo convidado.
- A sincronização é opt-in. Quando o utilizador a ativa:
  - Cria sessão **Firebase Anonymous Auth** (se ainda não existir).
  - Ao criar conta real (Google ou email/password), faz **`linkWithCredential`** — a conta
    anónima torna-se definitiva **sem perder os dados locais**.
- Sem rede ou sem conta → app totalmente funcional.

### 5.2 Sincronização (offline-first)
- Toda a edição escreve **primeiro no Drift** (UI instantânea) e marca `dirty = true`.
- Um serviço de sync envia os registos `dirty` para o Firestore quando há rede e há sessão.
- Estrutura Firestore: `users/{uid}/entries/{pokemonId}`.

### 5.3 Resolução de conflitos — última escrita vence (server timestamp)
- Cada escrita no Firestore grava `serverUpdatedAt = FieldValue.serverTimestamp()`.
- O "última escrita vence" usa o **server timestamp do Firestore**, não o relógio do
  dispositivo (evita problemas de relógios dessincronizados).
- Ao sincronizar: compara `serverUpdatedAt` remoto com o último sincronizado localmente;
  o mais recente prevalece, por Pokémon.

---

## 6. Segurança, Privacidade e Publicação

### 6.1 Regras de segurança do Firestore (`firestore.rules`)
Fechado por omissão; cada utilizador só acede aos seus dados:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/entries/{entryId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### 6.2 Privacidade / RGPD
- **Política de privacidade** estática (em `web_legal/`, publicável em Firebase Hosting ou
  GitHub Pages); link na app e na Play Store.
- **Minimização:** só guardamos email (se criar conta) e a coleção. Sem analytics/tracking.
- **Direito de acesso/portabilidade:** exportar a coleção (JSON) a partir das Definições.
- **Direito ao esquecimento:** eliminação de conta (ver 6.3).
- Base legal: consentimento (o sync é opt-in).

### 6.3 Eliminação de conta
> **Armadilhas do Firebase a respeitar:**
> 1. Apagar `users/{uid}` **não** apaga a subcoleção `entries/` — os filhos ficam órfãos.
>    A eliminação tem de apagar explicitamente todos os `users/{uid}/entries/{pokemonId}`
>    (em lote/`WriteBatch`) **antes** (ou via Cloud Function com `recursiveDelete`).
> 2. `user.delete()` exige **login recente**; sessões antigas devolvem
>    `requires-recent-login`. O fluxo tem de **reautenticar** antes de apagar.

- **Na app (Definições → Eliminar conta):**
  1. Reautenticar o utilizador (re-login Google/email) — trata `requires-recent-login`.
  2. **Cloud Function `deleteAccount` (callable, recomendada):** faz `recursiveDelete` de
     `users/{uid}` (subcoleção `entries/` incluída) e `admin.auth().deleteUser(uid)` — a
     única forma robusta de eliminação verdadeiramente completa.
     *Fallback sem Cloud Function:* apagar `entries/` em `WriteBatch`, depois o doc do
     utilizador, e por fim `user.delete()` no cliente.
  3. Limpar o Drift local e voltar ao modo convidado.
- **Via web:** página pública de pedido de eliminação (em `web_legal/`) com instruções +
  contacto, satisfazendo o requisito da Play Store de um URL de eliminação fora da app.

### 6.4 Data Safety (Play Store)
- Documento de mapeamento de dados (o que é recolhido, finalidade, se é partilhado) para
  preencher o formulário. Resumo: email (gestão de conta, opcional), dados de coleção
  (funcionalidade, guardados na conta), **não partilhados com terceiros**, encriptados em
  trânsito, eliminação disponível.

---

## 7. Ecrãs (Presentation)

1. **Pokédex (grelha)** — ecrã inicial. Cartões: nº, nome, imagem, tipos. Não apanhados em
   silhueta/apagado; apanhados a cores; **badge shiny**. **Placeholder/silhueta** enquanto
   a imagem não está em cache. Pesquisa (nome ou nº) + filtros (geração, tipo, estado:
   tenho/falta/shiny). Tudo via queries do Drift.
2. **Detalhe** — imagem (toggle normal/shiny), tipos, descrição/lore, estatísticas base, e
   controlos de coleção (tenho, shiny, quantidade, notas).
3. **Progresso** — total apanhados, em falta, % global e **por geração**.
4. **Em falta** — lista dedicada só dos que faltam.
5. **Definições** — idioma (PT/EN), tema (claro/escuro/sistema), sincronização (ativar/
   criar conta/login), exportar coleção, eliminar conta, e secção **Premium** (bloqueada).

**Estado (Riverpod):** providers para auth, catálogo, coleção, filtros+pesquisa (alimentam
a query do Drift), e progresso (derivado da coleção).

---

## 8. Monetização (preparar, não implementar)

- Pasta `core/premium/` com `PremiumGate` e `entitlementProvider` que **devolve sempre
  "tudo desbloqueado"** por agora.
- Pontos candidatos marcados com `// ⭐ PREMIUM:` (ex.: notas ilimitadas, temas extra,
  backup/export avançado). Pronto para `in_app_purchase` ou RevenueCat no futuro. **Sem
  pagamentos nesta fase.**

---

## 9. i18n e Tema

- **i18n:** `flutter_localizations` + `intl`, `app_pt.arb` / `app_en.arb`. Lore: PT quando
  existir, fallback EN (resolvido no dataset).
- **Tema:** Material 3, claro/escuro/sistema; cartões e chips coloridos por tipo de Pokémon.

---

## 10. Testes e Verificação

### 10.1 Testes automáticos
- Unitários: repositórios, lógica de progresso, resolução de conflitos, query de filtros.
- Widget: cartão apanhado vs. silhueta, badge shiny, estado de placeholder.

### 10.2 Verificação manual (dois carris)
- **Flutter Web (`flutter run -d chrome`):** verificação rápida de toda a Pokédex offline
  (grelha, pesquisa, filtros, detalhe, progresso) **sem Firebase**. Capturas tiradas pelo
  utilizador.
- **Android emulador:** valida Firebase/Auth/Google Sign-In e geração do `.aab`.

### 10.3 O que é preciso do utilizador
- Instalar Flutter + Chrome (instruções fornecidas).
- Mais tarde (para sync): criar projeto Firebase, fornecer `google-services.json` + config
  web + SHA-1 (Google Sign-In).

---

## 11. Publicação (.aab)

- minSdk 26; permissão única: Internet.
- Ícone, nome e splash configurados.
- Assinatura: keystore + `key.properties` (instruções), `build.gradle` configurado para
  release, comando `flutter build appbundle`.

---

## 12. Pausas de Validação

1. Após **esqueleto + dataset + Pokédex offline a funcionar** (antes do Firebase).
2. Na **configuração do Firebase/Auth/sync** (requer projeto Firebase do utilizador).
3. Na **preparação da monetização**.

---

## 13. Fora de Âmbito (YAGNI nesta fase)

- Pagamentos / subscrições reais.
- Trocas/social entre utilizadores.
- Dados sensíveis ou permissões além de Internet.
- Cloud Function de eliminação: **recomendada** para eliminação completa; se não a
  ativarmos no MVP, usa-se o fallback cliente (`WriteBatch` + `user.delete()`) descrito em §6.3.
