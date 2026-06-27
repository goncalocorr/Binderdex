import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/dex_tokens.dart';
import '../../domain/entities/market_tier.dart';
import '../../domain/entities/trade_match.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/dex_ui.dart';

/// "Trocas perfeitas": cruza a minha wishlist + repetidas com os anúncios.
/// Premium — cada nível vê um nº de trocas (Grátis vê só o total, como teaser).
class TradeMatchesScreen extends ConsumerWidget {
  const TradeMatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final tier = ref.watch(marketTierProvider).valueOrNull ?? 0;
    final async = ref.watch(tradeMatchesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.tradeMatches)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (all) {
          if (all.isEmpty) {
            return EmptyState(
              imageAsset: 'assets/trades_empty.png',
              icon: Icons.swap_horiz,
              title: t.tradeMatches,
              description: t.noTradeMatches,
            );
          }
          final total = all.length;
          final visible = MarketTier.limitTradeMatches(all, tier);
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // Contador (teaser): total de trocas, independente do limite.
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text(
                  t.tradeMatchesFound(total),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (visible.isEmpty)
                _locked(context, t) // Grátis: vê o número, lista bloqueada
              else
                ...visible.map((m) => _MatchTile(match: m)),
              if (visible.length < total)
                _seeMore(context, t, visible.length, total),
            ],
          );
        },
      ),
    );
  }

  Widget _locked(BuildContext context, AppLocalizations t) => Card(
        margin: const EdgeInsets.only(top: 8),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const Icon(Icons.lock_outline, size: 40, color: DexColors.gold500),
            const SizedBox(height: 12),
            Text(t.tradeMatchesLockedBody, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.push('/premium'),
              icon: const Icon(Icons.workspace_premium),
              label: Text(t.seePlans),
            ),
          ]),
        ),
      );

  Widget _seeMore(
          BuildContext context, AppLocalizations t, int shown, int total) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
        child: OutlinedButton(
          onPressed: () => context.push('/premium'),
          child: Text(t.tradeMatchesSeeMore(shown, total)),
        ),
      );
}

class _MatchTile extends StatelessWidget {
  final TradeMatch match;
  const _MatchTile({required this.match});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final l = match.listing;
    final give = match.iGive.map((c) => c.cardName).join(', ');
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: _thumb(l.cardImage),
        title: Text('${t.tradeReceive}: ${l.cardName}',
            maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${t.tradeGive}: $give',
                maxLines: 2, overflow: TextOverflow.ellipsis),
            Text(l.ownerName,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/community/card/${l.cardId}'),
      ),
    );
  }

  Widget _thumb(String url) => SizedBox(
        width: 42,
        height: 58,
        child: url.isEmpty
            ? const Icon(Icons.style)
            : ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                    imageUrl: url, fit: BoxFit.cover, memCacheWidth: 126),
              ),
      );
}
