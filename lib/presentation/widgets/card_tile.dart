import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/cards_repository.dart';
import '../../domain/entities/tcg_card.dart';

/// Cartão da grelha de cartas.
/// - Não possuída: imagem em silhueta escura/esbatida.
/// - Possuída: imagem a cores.
/// - Variante (holo/reverse): ícone no canto.
class CardTile extends StatelessWidget {
  final CardItem item;
  final VoidCallback onTap;
  const CardTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = item.card;
    final owned = item.owned;

    final image = CachedNetworkImage(
      imageUrl: c.imageSmall,
      fit: BoxFit.contain,
      placeholder: (_, __) =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported),
      color: owned ? null : Colors.black,
      colorBlendMode: owned ? BlendMode.dst : BlendMode.srcIn,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  Expanded(
                    child: Opacity(opacity: owned ? 1 : 0.5, child: image),
                  ),
                  Text('#${c.number}', style: const TextStyle(fontSize: 11)),
                ],
              ),
            ),
            if (owned && item.variant != CardVariant.normal)
              Positioned(
                top: 4,
                right: 4,
                child: Icon(
                  item.variant == CardVariant.holo
                      ? Icons.auto_awesome
                      : Icons.flip,
                  size: 16,
                  color: Colors.amber,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
