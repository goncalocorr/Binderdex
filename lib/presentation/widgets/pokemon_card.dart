import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/utils/sprites.dart';
import '../../domain/entities/pokemon.dart';
import 'type_chip.dart';

/// Cartão da grelha.
///
/// - Não apanhado: imagem em silhueta escura e esbatida.
/// - Apanhado: imagem a cores.
/// - Shiny: estrela no canto.
/// - Enquanto a imagem não está em cache: indicador de carregamento (placeholder).
class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final bool caught;
  final bool shiny;
  final VoidCallback onTap;

  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.caught,
    required this.shiny,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: Sprites.artwork(pokemon.id, shiny: shiny && caught),
      fit: BoxFit.contain,
      placeholder: (_, __) =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorWidget: (_, __, ___) =>
          const Icon(Icons.catching_pokemon, size: 48),
      // Quando não apanhado, pinta tudo de preto (silhueta).
      color: caught ? null : Colors.black,
      colorBlendMode: caught ? BlendMode.dst : BlendMode.srcIn,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                children: [
                  Text('#${pokemon.id}',
                      style: const TextStyle(fontSize: 11)),
                  Expanded(
                    child: Opacity(
                      opacity: caught ? 1 : 0.55,
                      child: image,
                    ),
                  ),
                  Text(
                    pokemon.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    alignment: WrapAlignment.center,
                    children: pokemon.types.map((t) => TypeChip(t)).toList(),
                  ),
                ],
              ),
            ),
            if (shiny)
              const Positioned(
                top: 4,
                right: 4,
                child: Icon(Icons.star, color: Colors.amber, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}
