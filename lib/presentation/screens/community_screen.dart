import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../appeal.dart';
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
    // Banido → não pode usar a Comunidade. Pode apelar 1x (por baixo do aviso).
    final mod = ref.watch(selfModerationProvider).valueOrNull;
    if (mod?.banned ?? false) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.block,
                  size: 56, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(t.bannedCommunity, textAlign: TextAlign.center),
              if (!mod!.appealed) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  icon: const Icon(Icons.record_voice_over_outlined),
                  label: Text(t.appeal),
                  onPressed: () => showAppealSheet(context, ref),
                ),
              ],
            ]),
          ),
        ),
      );
    }
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
        if (!searching) _tradeMatchesBanner(t),
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

  /// Banner de entrada para as "trocas perfeitas" (premium), com o contador.
  Widget _tradeMatchesBanner(AppLocalizations t) {
    final cs = Theme.of(context).colorScheme;
    final count = ref.watch(tradeMatchCountProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: Material(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            if (!requireSignIn(context, ref)) return;
            context.push('/trades');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Icon(Icons.swap_horiz, color: cs.onPrimaryContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(t.tradeMatches,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onPrimaryContainer)),
              ),
              if (count > 0) Badge(label: Text('$count')),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: cs.onPrimaryContainer),
            ]),
          ),
        ),
      ),
    );
  }

  /// Estado inicial: a Comunidade é só por pesquisa — sem feed geral. Convida
  /// o utilizador a procurar uma carta para ver quem a vende ou troca.
  Widget _buildPrompt(AppLocalizations t) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: const Alignment(0, -0.45),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
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
