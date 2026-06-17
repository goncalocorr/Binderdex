import 'package:flutter/material.dart';

import '../../core/theme/type_colors.dart';
import '../../domain/entities/pokemon.dart';

/// Chip colorido com o nome do tipo.
class TypeChip extends StatelessWidget {
  final PokemonType type;
  const TypeChip(this.type, {super.key});

  @override
  Widget build(BuildContext context) {
    final label = type.name[0].toUpperCase() + type.name.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colorForType(type),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}
