import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/auth_guard.dart';
import '../widgets/card_tile.dart';
import 'my_cards_screen.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});
  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  late final TextEditingController _searchController =
      TextEditingController(text: ref.read(communitySearchQueryProvider));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeDisclaimer());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _maybeDisclaimer() async {
    if (ref.read(communityDisclaimerSeenProvider)) return;
    final t = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(t.communityDisclaimerTitle),
        content: Text(t.communityDisclaimerBody),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.communityDisclaimerOk),
          ),
        ],
      ),
    );
    await ref.read(prefsProvider).setBool('communityDisclaimerSeen', true);
    ref.read(communityDisclaimerSeenProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final query = ref.watch(communitySearchQueryProvider);
    final searching = query.trim().isNotEmpty;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(t.sellOrTrade),
        onPressed: () {
          if (!requireSignIn(context, ref)) return;
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const MyCardsScreen(startDuplicates: true)));
        },
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            onChanged: (v) =>
                ref.read(communitySearchQueryProvider.notifier).state = v,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: t.searchCardHint,
              suffixIcon: searching
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(communitySearchQueryProvider.notifier).state =
                            '';
                      },
                    )
                  : null,
            ),
          ),
        ),
        if (!searching)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextButton.icon(
                icon: const Icon(Icons.sell),
                label: Text(t.myListings),
                onPressed: () {
                  if (!requireSignIn(context, ref)) return;
                  context.push('/my-listings');
                },
              ),
            ),
          ),
        Expanded(
          child: searching ? _buildSearchResults(t) : _buildPrompt(t),
        ),
      ]),
    );
  }

  /// Estado inicial: a Comunidade é só por pesquisa — sem feed geral. Convida
  /// o utilizador a procurar uma carta para ver quem a vende ou troca.
  Widget _buildPrompt(AppLocalizations t) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/community_empty.png', width: 140),
            const SizedBox(height: 16),
            Text(
              t.communitySearchPrompt,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  /// Resultados da pesquisa de cartas — tocar abre os anúncios dessa carta.
  Widget _buildSearchResults(AppLocalizations t) {
    final results = ref.watch(communitySearchResultsProvider);
    return results.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (items) => items.isEmpty
          ? Center(child: Text(t.noMatch))
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.62,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) => CardTile(
                item: items[i],
                onTap: () =>
                    context.push('/community/card/${items[i].card.id}'),
              ),
            ),
    );
  }
}
