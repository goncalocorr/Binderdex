import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/dex_ui.dart';
import '../widgets/listing_tile.dart';

class CardListingsScreen extends ConsumerWidget {
  final String cardId;
  const CardListingsScreen({super.key, required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final listings = ref.watch(listingsForCardProvider(cardId));
    return Scaffold(
      appBar: AppBar(title: Text(t.recentListings)),
      body: listings.when(
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
                itemBuilder: (_, i) => ListingTile(
                  listing: list[i],
                  onTap: () =>
                      context.push('/listing/${list[i].id}', extra: list[i]),
                ),
              ),
      ),
    );
  }
}
