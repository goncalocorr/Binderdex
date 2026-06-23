import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/dex_tokens.dart';

/// Todos os avatares incluídos (assets/avatars/<id>.png).
final List<String> kAvatarIds = [
  for (var i = 1; i <= 16; i++) 'avatar_${i.toString().padLeft(2, '0')}',
  for (var i = 1; i <= 16; i++)
    'person_avatar_${i.toString().padLeft(2, '0')}',
];

/// Avatar circular: imagem escolhida (assets/avatars/<id>.png) ou, em reserva,
/// a inicial do nome / um ícone para convidado.
class Avatar extends StatelessWidget {
  final String name;
  final double size;

  /// Id do avatar escolhido (ex.: "avatar_03"). Vazio → inicial/ícone.
  final String avatarId;

  const Avatar(
      {super.key, required this.name, this.size = 48, this.avatarId = ''});

  @override
  Widget build(BuildContext context) {
    if (avatarId.isNotEmpty) {
      return ClipOval(
        child: Image.asset(
          'assets/avatars/$avatarId.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

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
