import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/market_tier.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/dex_ui.dart';
import '../widgets/edit_listing_sheet.dart';
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
                ? EmptyState(
                    imageAsset: 'assets/empty_listings.png',
                    icon: Icons.storefront_outlined,
                    title: t.noListings,
                    description: t.noListingsBody,
                  )
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final l = list[i];
                      // Tocar abre a edição, onde está o botão "Apagar anúncio".
                      return ListingTile(
                        listing: l,
                        onTap: () => showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => EditListingSheet(listing: l),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ]),
    );
  }
}
