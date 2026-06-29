# Checklist de lançamento — Binderdex (Play Store)

Estado: preparação da ficha. Marca à medida que avanças.

## 1. Política de privacidade online (obrigatório)
- [ ] No GitHub: **Settings → Pages** → Source = **Deploy from a branch** →
      branch `master`, pasta **/docs** → Save.
- [ ] Aguardar ~1 min e confirmar:
      `https://goncalocorr.github.io/Binderdex/privacy.html`
- [ ] Guardar esse URL (usa-se na ficha e no Data Safety).

> Em alternativa: Firebase Hosting (`firebase init hosting` → pasta `docs` →
> `firebase deploy --only hosting`).

## 2. Build de produção assinado
- [ ] `flutter build appbundle --release` (assina com a tua chave de release;
      ver android/key.properties).
- [ ] Confirma o `.aab` em `build/app/outputs/bundle/release/app-release.aab`.

## 3. Conta Play Console
- [ ] Conta de programador Google Play (taxa única de ~25 USD), se ainda não tens.
- [ ] **Create app** → nome "Binderdex", PT/EN, App, Free.

## 4. Ficha da loja (ver `docs/store-listing.md`)
- [ ] Descrição curta + completa (PT e EN).
- [ ] Ícone 512×512, feature graphic 1024×500, 2–8 screenshots.
- [ ] Categoria, email de contacto, URL da política de privacidade.

## 5. Formulários obrigatórios (App content)
- [ ] **Privacy policy** → colar o URL.
- [ ] **Data safety** → preencher segundo `docs/legal/data-safety.md`.
- [ ] **Content rating** → questionário IARC (declarar interação/chat + UGC com
      moderação).
- [ ] **Target audience**, **Ads** (sem anúncios), **News app** (não), etc.

## 6. Upload e teste
- [ ] **Testing → Internal testing** → criar release → enviar o `.aab` → adicionar
      o teu email como testador → instalar pelo link e validar.

## 7. CRÍTICO — Login Google na loja
- [ ] Após o 1.º upload, a Google **re-assina** a app (Play App Signing). Vai a
      **Play Console → Setup → App signing**, copia o **SHA-1 do "App signing key
      certificate"** e adiciona-o no **Firebase Console → Definições do projeto →
      a tua app Android → Adicionar impressão digital**.
- [ ] Sem isto, o **login Google** falha para quem instalar da loja. (O SHA-1 da
      tua chave de *upload* já está; falta o do *Play App Signing*.)

## 8. Antes de publicar (recomendado)
- [ ] **Premium:** decidir — lançar com premium como está (marcador) ou ligar o
      **Play Billing** real primeiro. Sem Billing, não há pagamento; o premium
      desbloqueia na mesma (não cobrar). Para cobrar → implementar Play Billing.
- [ ] Rever as **regras do Firestore** (já deployed) e os **índices**.
- [ ] Testar fluxo completo numa conta nova (onboarding → login → coleção →
      comunidade → trocas → premium → moderação).

## 8a. Crashlytics + Analytics (já ligados no código)
- [ ] **Firebase Console → Crashlytics** → confirmar/clicar "Enable" (aparece após
      o 1.º relatório). Em **release**, força um crash de teste para validar:
      `FirebaseCrashlytics.instance.crash();` (remove depois).
- [ ] **Analytics** liga-se sozinho; confirma eventos em Console → Analytics →
      Realtime (pode demorar a aparecer).
- [ ] **Opcional** (só se usares `flutter build --obfuscate`): adicionar o
      **plugin Gradle do Crashlytics** para deobfuscar stack traces —
      `id("com.google.firebase.crashlytics")` no app/build.gradle.kts + no
      settings.gradle.kts (`version` compatível com o teu AGP). Sem obfuscação,
      os stack traces de Dart já são legíveis.

## 8b. Pendentes técnicos conhecidos
- iOS: **APNs** por configurar (se um dia fores para iOS).
- Push de "carta seguida": precisa que o "seguir carta" esteja no Firestore
  (já está, via wishlist).
- Reforço de slots do marketplace é client-trusted (até haver Play Billing).

## 9. Publicar
- [ ] Promover de Internal → **Production** (ou Closed/Open testing primeiro).
- [ ] Aguardar revisão da Google (horas a dias).
