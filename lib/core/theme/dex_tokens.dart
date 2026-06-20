import 'package:flutter/material.dart';

/// Cores primitivas do **Dex Design System** (tokens/colors.css).
/// Sistema original e brand-neutral: Flare Red + Energy Gold, cores de tipo
/// genéricas e uma rampa de neutros levemente fria.
abstract class DexColors {
  // Brand — Flare Red
  static const red50 = Color(0xFFFFF1F0);
  static const red100 = Color(0xFFFFDBD8);
  static const red400 = Color(0xFFFB5950);
  static const red500 = Color(0xFFF03B36); // primary
  static const red600 = Color(0xFFD62828);
  static const red700 = Color(0xFFB11D1D);

  // Accent — Energy Gold
  static const gold300 = Color(0xFFFFE08A);
  static const gold400 = Color(0xFFFFD24C);
  static const gold500 = Color(0xFFFCC419); // accent

  // Neutros (warm-cool gray)
  static const n0 = Color(0xFFFFFFFF);
  static const n50 = Color(0xFFF6F7F9);
  static const n100 = Color(0xFFECEEF2);
  static const n200 = Color(0xFFDCE0E8);
  static const n300 = Color(0xFFC2C8D4);
  static const n400 = Color(0xFF9AA3B2);
  static const n500 = Color(0xFF6B7280);
  static const n600 = Color(0xFF4B5363);
  static const n700 = Color(0xFF343B49);
  static const n800 = Color(0xFF232936);
  static const n900 = Color(0xFF161B24);
  static const n950 = Color(0xFF0E1218);

  // Semânticas
  static const green500 = Color(0xFF2FB344); // "have / collected"
  static const green400 = Color(0xFF3FD06A);
  static const danger = Color(0xFFE03131);
  static const dangerDark = Color(0xFFFF6B6B);

  // Raridade
  static const rarityCommon = Color(0xFF9AA3B2);
  static const rarityUncommon = Color(0xFF44C265);
  static const rarityRare = Color(0xFF3F8EFC);
  static const rarityHolo = Color(0xFF8B5CF6);
  static const rarityUltra = Color(0xFFFF5C8A);
  static const rarityGold = Color(0xFFE6B422);

  // Cores de tipo elementais (genéricas — não símbolos oficiais)
  static const types = <String, Color>{
    'normal': Color(0xFF9CA0A8),
    'fire': Color(0xFFFF7A33),
    'water': Color(0xFF3F8EFC),
    'grass': Color(0xFF44C265),
    'electric': Color(0xFFFBC531),
    'ice': Color(0xFF5FD3DE),
    'fighting': Color(0xFFD8493B),
    'poison': Color(0xFFA95FCB),
    'ground': Color(0xFFE0B457),
    'flying': Color(0xFF8FA8E8),
    'psychic': Color(0xFFFF5C8A),
    'bug': Color(0xFF9CBF3B),
    'rock': Color(0xFFC2A86B),
    'ghost': Color(0xFF6E5AB0),
    'dragon': Color(0xFF6A53E8),
    'dark': Color(0xFF4C4A52),
    'steel': Color(0xFF7FA6B8),
    'fairy': Color(0xFFF297CF),
  };
}

/// Gradientes de brilho para cartas raras (tokens/colors.css).
abstract class DexSheens {
  static const holo = [
    Color(0xFFC8F9FF),
    Color(0xFFD3C7FF),
    Color(0xFFFFD0EC),
    Color(0xFFFFF3C4),
    Color(0xFFC6FFD9),
    Color(0xFFC8F9FF),
  ];
  static const foil = [
    Color(0xFFF6D365),
    Color(0xFFFDA085),
    Color(0xFFF093FB),
    Color(0xFF5EE7DF),
    Color(0xFFF6D365),
  ];
  static const rainbow = [
    Color(0xFFFF5C5C),
    Color(0xFFFFB84C),
    Color(0xFFFFE14C),
    Color(0xFF57D97A),
    Color(0xFF4CC3FF),
    Color(0xFF9B6CFF),
    Color(0xFFFF6CD0),
  ];
}

/// Escolhe o brilho a aplicar a uma carta possuída:
/// secret/rainbow → arco-íris; holo → holo; reverse → foil; senão nenhum.
List<Color>? sheenColorsForCard({
  String? rarity,
  required bool ownedHolo,
  required bool ownedReverse,
  required bool ownedAny,
}) {
  if (!ownedAny) return null;
  final r = (rarity ?? '').toLowerCase();
  if (r.contains('secret') || r.contains('rainbow')) return DexSheens.rainbow;
  if (ownedHolo) return DexSheens.holo;
  if (ownedReverse) return DexSheens.foil;
  return null;
}

/// Raios — "chunky & friendly" (tokens/spacing.css).
abstract class DexRadii {
  static const sm = 10.0;
  static const md = 14.0; // inputs, chips
  static const lg = 18.0; // cards
  static const xl = 24.0; // sheets
  static const pill = 999.0;
}

/// Proporção de carta (retrato 5:7).
const double kCardAspect = 5 / 7;

/// Cor de tipo a partir do tipo de energia do TCG (Fire, Lightning, Metal…),
/// mapeado para a paleta de tipos do design system.
Color colorForCardType(String? type) {
  switch ((type ?? 'normal').toLowerCase()) {
    case 'fire':
      return DexColors.types['fire']!;
    case 'water':
      return DexColors.types['water']!;
    case 'grass':
      return DexColors.types['grass']!;
    case 'lightning':
    case 'electric':
      return DexColors.types['electric']!;
    case 'psychic':
      return DexColors.types['psychic']!;
    case 'fighting':
      return DexColors.types['fighting']!;
    case 'darkness':
    case 'dark':
      return DexColors.types['dark']!;
    case 'metal':
    case 'steel':
      return DexColors.types['steel']!;
    case 'dragon':
      return DexColors.types['dragon']!;
    case 'fairy':
      return DexColors.types['fairy']!;
    case 'colorless':
    case 'normal':
      return DexColors.types['normal']!;
    default:
      return DexColors.types['normal']!;
  }
}

/// Cor da raridade (escala common → secret) a partir do texto da raridade do TCG.
Color colorForRarity(String? rarity) {
  final s = (rarity ?? '').toLowerCase();
  if (s.isEmpty) return DexColors.rarityCommon;
  if (s.contains('secret') || s.contains('rainbow') || s.contains('gold')) {
    return DexColors.rarityGold;
  }
  if (s.contains('ultra') || s.contains('full art') || s.contains('illustration')) {
    return DexColors.rarityUltra;
  }
  if (s.contains('holo') || s.contains('ex') || s.contains('gx') || s.contains('v')) {
    return DexColors.rarityHolo;
  }
  if (s.contains('rare')) return DexColors.rarityRare;
  if (s.contains('uncommon')) return DexColors.rarityUncommon;
  return DexColors.rarityCommon;
}