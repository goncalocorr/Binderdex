# Pokédex — Caderneta de Coleção

App Flutter para gerir a tua coleção pessoal de Pokémon (todas as gerações),
**local-first / offline-first**, com sincronização opcional na nuvem (a partir da Etapa 2).

- Especificação: [docs/superpowers/specs/2026-06-17-pokedex-app-design.md](docs/superpowers/specs/2026-06-17-pokedex-app-design.md)
- Plano da Etapa 1: [docs/superpowers/plans/2026-06-17-pokedex-etapa1.md](docs/superpowers/plans/2026-06-17-pokedex-etapa1.md)

Esta entrega corresponde à **Etapa 1**: Pokédex offline (grelha, pesquisa, filtros,
detalhe, progresso, em falta) com Drift + Riverpod. **Sem Firebase ainda.**

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

## 4. (Recomendado) Gerar o dataset completo

O repositório inclui um `assets/data/pokedex.json` **placeholder com apenas 4 Pokémon**
para a app arrancar logo. Para teres todas as gerações (~1025+), corre o gerador
(precisa de internet; demora alguns minutos):

```bash
dart run tool/generate_dataset.dart
```

Isto reescreve `assets/data/pokedex.json`. **Apaga a base de dados local** se já tinhas
corrido a app antes, para forçar nova hidratação (no emulador/web basta limpar os dados
da app; em desenvolvimento, reinstalar).

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
- Grelha de Pokémon — os **não apanhados em silhueta**, os apanhados a cores.
- Pesquisa por nome/número e filtros (estado, geração, tipo).
- Detalhe com tipos, lore, stats e controlos (Tenho / Shiny / Quantidade / Notas).
- Ecrã de **Progresso** (global e por geração) e lista de **Em falta**.
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
- **domain/** — entidades puras (`Pokemon`, `UserEntry`, `ProgressStats`, `PokedexFilter`).
- **data/** — Drift (catálogo + coleção), carregador do dataset, repositórios.
- **presentation/** — providers Riverpod, ecrãs e widgets.
- **core/** — tema M3, cores por tipo, router, utilitários, (futuro) `premium/`.
