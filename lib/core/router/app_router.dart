import 'dart:ui' show ImageFilter;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/chat.dart';
import '../../domain/entities/listing.dart';
import '../../domain/entities/market_tier.dart';
import 'root_navigator.dart';
import '../../l10n/app_localizations.dart';
import '../../presentation/providers/app_providers.dart';
import '../../presentation/screens/admin_screen.dart';
import '../../presentation/screens/blocked_users_screen.dart';
import '../../presentation/screens/card_detail_screen.dart';
import '../../presentation/screens/card_listings_screen.dart';
import '../../presentation/screens/community_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/chat_screen.dart';
import '../../presentation/screens/listing_detail_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/messages_screen.dart';
import '../../presentation/screens/notifications_screen.dart';
import '../../presentation/screens/trade_matches_screen.dart';
import '../../presentation/screens/my_binder_screen.dart';
import '../../presentation/screens/my_cards_screen.dart';
import '../../presentation/screens/my_listings_screen.dart';
import '../../presentation/screens/onboarding_screen.dart';
import '../../presentation/screens/premium_screen.dart';
import '../../presentation/screens/search_screen.dart';
import '../../presentation/screens/set_cards_screen.dart';
import '../../presentation/screens/sets_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/wishlist_screen.dart';
import '../../presentation/widgets/auth_guard.dart';
import '../../presentation/widgets/avatar.dart';

/// Ícone (imagem) de um separador da barra inferior (assets/tabs/<name>.png).
Widget _tabIcon(String name) => Image.asset(
      'assets/tabs/$name.png',
      width: 28,
      height: 28,
      cacheWidth: 112,
    );

/// Casca com navegação inferior (Início, Coleções, O meu binder, Perfil).
class _Shell extends ConsumerStatefulWidget {
  const _Shell();
  @override
  ConsumerState<_Shell> createState() => _ShellState();
}

class _ShellState extends ConsumerState<_Shell> {
  bool _prompting = false;

  static const _tabs = [
    HomeScreen(),
    SetsScreen(),
    MyBinderScreen(),
    CommunityScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Cobre o caso de já estar autenticado ao montar (sessão restaurada).
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAskName());
  }

  /// Após autenticar: restaura o perfil da nuvem e, se a conta ainda não tiver
  /// nome, pede-o (uma vez). É aqui, e não no login, porque o gate desmonta o
  /// ecrã de login ao autenticar.
  Future<void> _maybeAskName() async {
    if (_prompting || !mounted) return;
    // Qualquer sessão (conta real ou convidado anónimo) tem um uid.
    if (ref.read(authStateProvider).valueOrNull == null) return;
    _prompting = true;
    // 1. Restaura nome/avatar da conta (evita o popup em contas existentes).
    await syncProfileFromCloud(ref);
    // 2. Consentimento por conta: conta nova tem sempre de aceitar (1x).
    if (mounted) await ensureTermsAccepted(context, ref);
    // 3. Só pede o nome a contas reais que ainda não tenham nome.
    if (mounted &&
        isSignedIn(ref) &&
        ref.read(displayNameProvider).trim().isEmpty) {
      await ensureDisplayName(context, ref);
    }
    _prompting = false;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final index = ref.watch(navIndexProvider);
    final titles = [
      t.tabHome,
      t.tabSets,
      t.tabBinder,
      t.tabCommunity,
      t.tabProfile,
    ];

    // Após login (mudança de sessão), pede o nome se faltar.
    ref.listen(authStateProvider, (_, __) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAskName());
    });

    // Se o premium expirar (tier deixa de ser premium) e o avatar atual for
    // premium, repõe o avatar por omissão — perde-se o acesso aos avatares.
    ref.listen(marketTierProvider, (_, next) {
      if (MarketTier.isPremium(next.valueOrNull ?? 0)) return;
      if (!isPremiumAvatar(ref.read(avatarProvider))) return;
      ref.read(avatarProvider.notifier).state = '';
      ref.read(prefsProvider).setString('avatar', '');
      final uid = ref.read(authStateProvider).valueOrNull?.uid;
      if (uid != null) {
        ref.read(profileServiceProvider).save(uid, avatar: '').catchError((_) {});
      }
    });

    // 1.ª vez: marca todos os sets atuais como "vistos" (senão as 173 coleções
    // apareceriam como novas). A partir daí, só sets adicionados depois são novos.
    ref.listen(setsListProvider, (_, next) {
      if (ref.read(seenSetsProvider) != null) return;
      final sets = next.valueOrNull;
      if (sets == null || sets.isEmpty) return;
      final ids = sets.map((s) => s.set.id).toSet();
      ref.read(seenSetsProvider.notifier).state = ids;
      ref.read(prefsProvider).setStringList('seenSets', ids.toList());
    });

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 52,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Image.asset('assets/logo.png', width: 32, height: 32),
        ),
        title: Text(titles[index]),
        actions: [
          IconButton(
            tooltip: t.notifications,
            icon: () {
              final n = ref.watch(notifUnseenCountProvider);
              const ic = Icon(Icons.notifications_outlined);
              return n > 0 ? Badge(label: Text('$n'), child: ic) : ic;
            }(),
            onPressed: () => context.push('/notifications'),
          ),
          if (index == 3)
            IconButton(
              tooltip: t.messages,
              icon: () {
                final unread = ref.watch(unreadTotalProvider);
                const ic = Icon(Icons.chat_bubble_outline);
                return unread > 0
                    ? Badge(label: Text('$unread'), child: ic)
                    : ic;
              }(),
              onPressed: () => context.push('/messages'),
            ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: t.tabSearch,
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      // extendBody: o conteúdo passa por trás da barra (efeito vidro/blur).
      extendBody: true,
      // Transição suave (fade + micro-slide) ao trocar de separador.
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
                    begin: const Offset(0, 0.015), end: Offset.zero)
                .animate(anim),
            child: child,
          ),
        ),
        child: KeyedSubtree(key: ValueKey(index), child: _tabs[index]),
      ),
      bottomNavigationBar: _FloatingNav(
        index: index,
        unread: ref.watch(unreadTotalProvider),
        onSelect: (i) {
          if (i == index) return;
          HapticFeedback.selectionClick(); // feedback subtil ao trocar de tab
          ref.read(navIndexProvider.notifier).state = i;
        },
      ),
    );
  }
}

/// Barra de navegação flutuante em "pílula": fundo translúcido com blur,
/// destacada das margens e com o item ativo realçado.
class _FloatingNav extends StatelessWidget {
  final int index;
  final int unread;
  final ValueChanged<int> onSelect;
  const _FloatingNav(
      {required this.index, required this.unread, required this.onSelect});

  static const _icons = ['inicio', 'colecoes', 'binder', 'comunidade', 'perfil'];

  static const _curve = Curves.easeOutCubic;
  static const _dur = Duration(milliseconds: 340);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.black : Colors.white;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                // Vidro: leve gradiente vertical para apanhar a luz no topo.
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    base.withValues(alpha: isDark ? 0.34 : 0.40),
                    base.withValues(alpha: isDark ? 0.20 : 0.26),
                  ],
                ),
                borderRadius: BorderRadius.circular(34),
                border: Border.all(
                    color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.55),
                    width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 30,
                    spreadRadius: -4,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: LayoutBuilder(builder: (context, c) {
                final slot = c.maxWidth / _icons.length;
                const inset = 8.0;
                return Stack(children: [
                  // Indicador ativo que desliza entre separadores.
                  AnimatedPositioned(
                    duration: _dur,
                    curve: _curve,
                    left: index * slot + inset,
                    top: 10,
                    bottom: 10,
                    width: slot - inset * 2,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: cs.primary.withValues(alpha: 0.45),
                            width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: cs.primary.withValues(alpha: 0.35),
                            blurRadius: 14,
                            spreadRadius: -3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < _icons.length; i++)
                        Expanded(child: _item(context, i)),
                    ],
                  ),
                ]);
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int i) {
    final active = i == index;
    Widget icon = _tabIcon(_icons[i]);
    if (i == 3 && unread > 0) {
      icon = Badge(label: Text('$unread'), child: icon);
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onSelect(i),
      child: Center(
        child: AnimatedScale(
          duration: _dur,
          curve: _curve,
          scale: active ? 1.14 : 1,
          child: AnimatedOpacity(
            duration: _dur,
            curve: _curve,
            opacity: active ? 1 : 0.5,
            child: icon,
          ),
        ),
      ),
    );
  }
}

/// Cria o router com a rota inicial decidida no arranque.
///
/// Gate de entrada: depois do splash nativo, a app exige **login** (ou entrar
/// como **convidado**). Onboarding aparece só no 1º arranque. Convidado vê o
/// catálogo mas não edita (o bloqueio de edição é por ação, com popup).
final appRouterProvider = Provider<GoRouter>((ref) {
  // Rota inicial: onboarding (1ª vez) → início (se já autenticado) → login.
  final onboardingDone = ref.read(onboardingDoneProvider);
  final initiallyAuthed = fb.FirebaseAuth.instance.currentUser != null;
  final initial = !onboardingDone
      ? '/onboarding'
      : (initiallyAuthed ? '/' : '/login');

  // Reavalia o gate quando a sessão / convidado / onboarding mudam.
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, __) => refresh.value++);
  ref.listen(guestModeProvider, (_, __) => refresh.value++);
  ref.listen(onboardingDoneProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initial,
    refreshListenable: refresh,
    // Analytics: regista a navegação entre ecrãs automaticamente.
    observers: [FirebaseAnalyticsObserver(analytics: ref.read(analyticsProvider))],
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      if (auth.isLoading) return null; // ainda a restaurar a sessão
      final authed = auth.valueOrNull != null;
      final guest = ref.read(guestModeProvider);
      final done = ref.read(onboardingDoneProvider);
      final loc = state.matchedLocation;

      if (!done && loc != '/onboarding') return '/onboarding';
      if (done && !authed && !guest && loc != '/login') return '/login';
      if (authed && (loc == '/login' || loc == '/onboarding')) return '/';
      return null;
    },
    routes: [
    GoRoute(
        path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/', builder: (_, __) => const _Shell()),
    GoRoute(
      path: '/set/:id',
      builder: (_, s) => SetCardsScreen(
        setId: s.pathParameters['id']!,
        initialStatus: s.uri.queryParameters['status'],
      ),
    ),
    GoRoute(
      path: '/card/:id',
      builder: (_, s) => CardDetailScreen(id: s.pathParameters['id']!),
    ),
    GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
    GoRoute(path: '/wishlist', builder: (_, __) => const WishlistScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/my-cards', builder: (_, __) => const MyCardsScreen()),
    GoRoute(
        path: '/my-listings', builder: (_, __) => const MyListingsScreen()),
    GoRoute(
      path: '/listing/:id',
      builder: (_, s) => ListingDetailScreen(listing: s.extra as Listing),
    ),
    GoRoute(
      path: '/community/card/:id',
      builder: (_, s) => CardListingsScreen(cardId: s.pathParameters['id']!),
    ),
    GoRoute(path: '/premium', builder: (_, __) => const PremiumScreen()),
    GoRoute(path: '/admin', builder: (_, __) => const AdminScreen()),
    GoRoute(
        path: '/trades', builder: (_, __) => const TradeMatchesScreen()),
    GoRoute(path: '/messages', builder: (_, __) => const MessagesScreen()),
    GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationsScreen()),
    GoRoute(
        path: '/blocked', builder: (_, __) => const BlockedUsersScreen()),
    GoRoute(
      path: '/chat',
      builder: (_, s) => ChatScreen(conversation: s.extra as Conversation),
    ),
    ],
  );
});
