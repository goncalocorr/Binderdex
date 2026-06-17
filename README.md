# Caderneta de Cartas Pokémon (TCG)

App Flutter para gerir a tua coleção de **cartas Pokémon (TCG)**: navegas pelas
**coleções (sets oficiais)**, abres um set e marcas quais cartas tens.
**Local-first / offline-first**, com sincronização opcional na nuvem (a partir da Etapa 2).

- Especificação: [docs/superpowers/specs/2026-06-17-pokedex-app-design.md](docs/superpowers/specs/2026-06-17-pokedex-app-design.md)

Fonte de dados: **Pokémon TCG API** (https://pokemontcg.io). A lista de sets é incluída na
app; as cartas de cada set são buscadas on-demand e cacheadas no Drift. **Sem Firebase ainda.**

---

## 1. Pré-requisitos (instalar uma vez)

1. **Flutter SDK** (canal stable): https://docs.flutter.dev/get-started/install/windows
   - No fim, confirma com: `flutter doctor`
2. **Google Chrome** (para a verificação rápida em web).
3. *(Opcional, para a Etapa 2/3)* **Android Studio** + um emulador Android (API 26+).

Confirma que está tudo no PATH:
```bash
flutter --version
dart --version
```

---

## 2. Gerar as pastas de plataforma (android/ e web/)

Este repositório traz o código-fonte (`lib/`, `test/`, `tool/`, `assets/`,
`pubspec.yaml`, etc.) mas **não** as pastas geradas `android/` e `web/`. Cria-as com:

```bash
flutter create . --org com.example --project-name pokedex --platforms=android,web
```

> O `flutter create` **não sobrescreve** os ficheiros que já existem (vais ver "Skipped"
> para `pubspec.yaml`, `lib/main.dart`, etc.). Se por acaso alguma coisa for alterada,
> repõe os nossos ficheiros com:
> ```bash
> git checkout -- pubspec.yaml analysis_options.yaml lib/main.dart
> ```

Depois, garante `minSdk 26` em `android/app/build.gradle` (ou `build.gradle.kts`):
```gradle
defaultConfig {
    minSdkVersion 26
}
```

---

## 3. Instalar dependências e gerar código

```bash
flutter pub get

# Gera o código do Drift (lib/data/local/database.g.dart)
dart run build_runner build --delete-conflicting-outputs

# Gera as localizações (lib/l10n/app_localizations.dart)
flutter gen-l10n
```

---

## 4. Lista de sets incluída (já gerada)

O repositório já traz `assets/data/tcg_sets.json` com todos os sets oficiais (~173).
As **cartas** de cada set são buscadas à Pokémon TCG API quando abres o set (online) e
ficam em cache no Drift; a partir daí, esse set funciona offline.

Só precisas de regenerar a lista de sets quando saírem novos sets (precisa de internet):
```bash
dart run tool/generate_tcg_sets.dart
```

**Chave de API (opcional):** a app funciona sem chave (limites mais baixos). Para usar a
tua chave gratuita do pokemontcg.io:
```bash
flutter run -d chrome --dart-define=TCG_API_KEY=a-tua-chave
```

---

## 4b. Suporte web do Drift (já incluído)

Na web, o SQLite corre em **WebAssembly**. O repositório já traz os dois ficheiros
necessários em `web/`:
- `web/sqlite3.wasm` (corresponde ao pacote `sqlite3` 3.3.3)
- `web/drift_worker.dart.js` (corresponde ao pacote `drift` 2.34.0)

Só precisas de os regenerar se atualizares essas dependências:
```bash
# sqlite3.wasm — descarregar a versão que corresponde ao teu pubspec.lock:
#   https://github.com/simolus3/sqlite3.dart/releases (asset sqlite3.wasm)

# drift_worker.dart.js — recompilar a partir do ponto de entrada incluído:
dart compile js -O4 -o web/drift_worker.dart.js tool/drift_worker_entry.dart
```

A ligação à base de dados é escolhida automaticamente por plataforma em
`lib/data/local/connection/` (nativo via FFI vs. WASM na web).

---

## 5. Correr a app

**Web (verificação rápida — não precisa de Firebase):**
```bash
flutter run -d chrome
```

**Android (emulador):**
```bash
flutter run
```

O que deves ver:
- **Coleções (sets)** no ecrã inicial, cada uma com progresso (ex.: *37/102*).
- Ao abrir um set, as **cartas** desse set (busca on-demand) — não possuídas em
  **silhueta**, possuídas a cores; badge de variante (holo/reverse).
- Pesquisa por nome/número e filtros (tenho / em falta / raridade).
- Detalhe com imagem grande e controlos (Tenho / Variante / Quantidade / Notas).
- Ecrã de **Progresso** (global e por set) e lista de **Em falta**.
- Definições: tema (claro/escuro/sistema) e idioma (PT/EN).

> 📸 Tira capturas dos ecrãs para validarmos antes de avançar para a Etapa 2 (Firebase).

---

## 6. Testes

```bash
flutter analyze
flutter test
```

Testes incluídos: filtros/pesquisa no Drift, cálculo de progresso, e estados do cartão.

---

## 7. Próximas etapas

- **Etapa 2 — Nuvem e conformidade:** Firebase (Anonymous Auth + login Google/email com
  `linkWithCredential`), sincronização Firestore (offline-first, conflitos por *server
  timestamp*), regras de segurança por utilizador, eliminação de conta (com reautenticação
  e deleção recursiva), política de privacidade e Data Safety.
- **Etapa 3 — Monetização e publicação:** gates premium (`// ⭐ PREMIUM:`), ícone/splash,
  assinatura e geração do **Android App Bundle (.aab)** para a Play Store.

## Arquitetura (resumo)

Camadas `data / domain / presentation` com Riverpod:
- **domain/** — entidades puras (`CardSet`, `TcgCard`, `UserCardEntry`, `ProgressStats`, `CardFilter`).
- **data/** — Drift (`card_sets`, `tcg_cards`, `user_card_entries`), cliente da TCG API
  (`remote/tcg_api.dart`), loader de sets, repositórios.
- **presentation/** — providers Riverpod, ecrãs (sets → cartas → detalhe) e widgets.
- **core/** — tema M3, router, config da API (`config/tcg_config.dart`), (futuro) `premium/`.
