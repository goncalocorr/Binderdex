import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/listing.dart';
import '../../l10n/app_localizations.dart';

class ListingTile extends StatelessWidget {
  final Listing listing;
  final VoidCallback? onTap;
  const ListingTile({super.key, required this.listing, this.onTap});

  String _modeLabel(AppLocalizations t) => switch (listing.mode) {
        TradeMode.trade => t.modeTrade,
        TradeMode.sell => t.modeSell,
        TradeMode.both => t.modeBoth,
      };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: SizedBox(
        width: 40,
        child: listing.cardImage.isEmpty
            ? const Icon(Icons.style)
            : CachedNetworkImage(
                imageUrl: listing.cardImage,
                fit: BoxFit.contain,
                errorWidget: (_, __, ___) => const Icon(Icons.style),
              ),
      ),
      title: Text(listing.cardName,
          maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(listing.ownerName,
          maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Chip(
        label: Text(_modeLabel(t)),
        backgroundColor: cs.primaryContainer,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
