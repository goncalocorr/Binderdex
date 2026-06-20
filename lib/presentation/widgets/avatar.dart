import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/dex_tokens.dart';

/// Avatar circular com a inicial do nome (ou um ícone para convidado).
class Avatar extends StatelessWidget {
  final String name;
  final double size;
  const Avatar({super.key, required this.name, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final letter = trimmed.isEmpty ? '' : trimmed.characters.first.toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DexColors.red400, DexColors.red600],
        ),
      ),
      child: letter.isEmpty
          ? Icon(Icons.person, color: Colors.white, size: size * 0.55)
          : Text(
              letter,
              style: TextStyle(
                fontFamily: AppTheme.displayFont,
                fontWeight: FontWeight.w700,
                fontSize: size * 0.42,
                color: Colors.white,
              ),
            ),
    );
  }
}
