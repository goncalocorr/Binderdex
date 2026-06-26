import 'package:flutter/material.dart';

import '../../core/theme/dex_tokens.dart';

/// Pequeno selo (coroa dourada) que marca um utilizador premium.
class PremiumBadge extends StatelessWidget {
  final double size;
  const PremiumBadge({super.key, this.size = 16});

  @override
  Widget build(BuildContext context) =>
      Icon(Icons.workspace_premium, size: size, color: DexColors.gold500);
}
