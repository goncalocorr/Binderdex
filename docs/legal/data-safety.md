# Play Store — Data Safety (mapeamento)

Guia para preencher o formulário **Data safety** da Google Play Console.
Reflete o comportamento real da app (Etapa 2: auth + sincronização opcional).

## Resumo
- **Recolhe dados?** Sim (mínimos), só com início de sessão opcional.
- **Partilha dados com terceiros?** Não (o Firebase é processador, não é
  partilha para fins próprios de terceiros).
- **Encriptação em trânsito?** Sim (HTTPS/TLS via Firebase).
- **Forma de eliminar dados?** Sim — Perfil → Eliminar conta.

## Dados recolhidos

| Categoria (Play) | Tipo | Recolhido? | Opcional? | Finalidade |
|---|---|---|---|---|
| **Informações pessoais** | Email | Sim (só com conta) | Sim | Gestão de conta / autenticação |
| **Identificadores** | User ID (UID Firebase) | Sim (só com conta) | Sim | Sincronização da coleção |
| **Atividade na app** | A coleção do utilizador (cartas, quantidades, notas, wishlist) | Sim (na nuvem só com conta) | Sim | Funcionalidade da app |

## Não recolhido / não usado
Localização · Contactos · Mensagens · Fotos/vídeos · Ficheiros · Áudio ·
Informação financeira/pagamentos · Histórico de navegação · Publicidade ·
Analytics · Identificadores de tracking.

## Práticas de segurança a declarar
- ✅ Dados encriptados em trânsito.
- ✅ O utilizador pode pedir a eliminação dos dados (na app).
- ✅ Sem recolha obrigatória: a app é totalmente utilizável sem conta.

## Notas
- Sem início de sessão, **nada sai do dispositivo** — nesse modo a app não
  recolhe dados pessoais.
- O email só é tratado se o utilizador criar conta / usar Google Sign-In.
- A política de privacidade (URL público) tem de ser indicada na ficha da Play
  Store — ver `docs/legal/privacy-policy.md` (alojar em Firebase Hosting ou
  GitHub Pages na Etapa 3).
