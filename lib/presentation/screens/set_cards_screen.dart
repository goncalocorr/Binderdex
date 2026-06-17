import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/card_filter.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/card_filter_sheet.dart';
import '../widgets/card_tile.dart';

/// Cartas de um set: dispara a sincronização (busca à API), pesquisa e filtros.
class SetCardsScreen extends ConsumerStatefulWidget {
  final String setId;
  final String? initialStatus; // 'missing' vindo do ecrã "Em falta"
  const SetCardsScreen({super.key, required this.setId, this.initialStatus});

  @override
  ConsumerState<SetCardsScreen> createState() => _SetCardsScreenState();
}

class _SetCardsScreenState extends ConsumerState<SetCardsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialStatus == 'missing') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(cardFilterProvider(widget.setId).notifier).state =
            const CardFilter(status: CardStatusFilter.missing);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final setAsync = ref.watch(setByIdProvider(widget.setId));
    final sync = ref.watch(setSyncProvider(widget.setId));
    final cardsAsync = ref.watch(cardsListProvider(widget.setId));

    return Scaffold(
      appBar: AppBar(
        title: Text(setAsync.valueOrNull?.name ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => showModalBottomSheet(
              context: context,
              showDragHandle: true,
              isScrollControlled: true,
              builder: (_) => CardFilterSheet(widget.setId),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: t.searchCardsHint,
                isDense: true,
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) {
                final f = ref.read(cardFilterProvider(widget.setId));
                ref.read(cardFilterProvider(widget.setId).notifier).state =
                    f.copyWith(query: v);
              },
            ),
          ),
          Expanded(
            child: sync.when(
              loading: () => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(t.loadingCards),
                  ],
                ),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(t.cardsLoadError, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () =>
                          ref.invalidate(setSyncProvider(widget.setId)),
                      child: Text(t.retry),
                    ),
                  ],
                ),
              ),
              data: (_) => cardsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
                data: (items) => items.isEmpty
                    ? Center(child: Text(t.noCards))
                    : GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.70,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),
                        itemCount: items.length,
                        itemBuilder: (_, i) => CardTile(
                          item: items[i],
                          onTap: () =>
                              context.push('/card/${items[i].card.id}'),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
