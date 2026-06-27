import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/chat.dart';
import '../../domain/entities/listing.dart';
import '../../domain/entities/market_tier.dart';
import '../../l10n/app_localizations.dart';
import '../../presentation/providers/app_providers.dart';
import '../../presentation/screens/card_detail_screen.dart';
import '../../presentation/screens/card_listings_screen.dart';
import '../../presentation/screens/community_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/chat_screen.dart';
import '../../presentation/screens/listing_detail_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/messages_screen.dart';
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
    if (!isSignedIn(ref)) return;
    _prompting = true;
    // 1. Restaura nome/avatar da conta (evita o popup em contas existentes).
    await syncProfileFromCloud(ref);
    // 2. Só pede o nome se a conta realmente não tiver.
    if (mounted && ref.read(displayNameProvider).trim().isEmpty) {
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

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 52,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Image.asset('assets/logo.png', width: 32, height: 32),
        ),
        title: Text(titles[index]),
        actions: [
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
      body: _tabs[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) =>
            ref.read(navIndexProvider.notifier).state = i,
        destinations: [
          NavigationDestination(icon: _tabIcon('inicio'), label: t.tabHome),
          NavigationDestination(icon: _tabIcon('colecoes'), label: t.tabSets),
          NavigationDestination(
              icon: _tabIcon('binder'), label: t.tabBinderShort),
          NavigationDestination(
              icon: _tabIcon('comunidade'), label: t.tabCommunity),
          NavigationDestination(icon: _tabIcon('perfil'), label: t.tabProfile),
        ],
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
    initialLocation: initial,
    refreshListenable: refresh,
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
    GoRoute(path: '/messages', builder: (_, __) => const MessagesScreen()),
    GoRoute(
      path: '/chat',
      builder: (_, s) => ChatScreen(conversation: s.extra as Conversation),
    ),
    ],
  );
});
