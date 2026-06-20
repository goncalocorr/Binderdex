import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/stats_scope.dart';

/// Seletor de âmbito: [As minhas coleções] / [Todas], ou um chip com a coleção
/// focada (com ✕ para voltar). Partilhado pelos ecrãs de Progresso e Em falta.
class ScopeBar extends ConsumerWidget {
  final StateProvider<StatsScope> provider;
  final String mineLabel;
  final String allLabel;
  const ScopeBar({
    super.key,
    required this.provider,
    required this.mineLabel,
    required this.allLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    // Sempre o toggle [As minhas coleções | Todas]. Quando uma coleção está
    // focada, nenhum fica selecionado (a coleção vê-se pela linha realçada e
    // pelo título); tocar num deles sai do foco.
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: Text(mineLabel),
          selected: !scope.isSet && !scope.all,
          onSelected: (_) => notifier.state = const StatsScope(all: false),
        ),
        ChoiceChip(
          label: Text(allLabel),
          selected: !scope.isSet && scope.all,
          onSelected: (_) => notifier.state = const StatsScope(all: true),
        ),
      ],
    );
  }
}
