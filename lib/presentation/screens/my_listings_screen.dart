import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/market_tier.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/listing_tile.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final mine = ref.watch(myListingsProvider);
    final tier = ref.watch(marketTierProvider).valueOrNull ?? 0;
    final active = ref.watch(activeListingsCountProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.myListings)),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(t.slotsUsed(active, MarketTier.slotsFor(tier)),
              style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(
          child: mine.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (list) => list.isEmpty
                ? Center(child: Text(t.noListings))
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final l = list[i];
                      return Dismissible(
                        key: ValueKey(l.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => ref
                            .read(marketServiceProvider)
                            .deleteListing(l.id, l.ownerUid),
                        child: ListingTile(listing: l),
                      );
                    },
                  ),
          ),
        ),
      ]),
    );
  }
}
