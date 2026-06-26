import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/dex_tokens.dart';
import '../../domain/entities/card_filter.dart';
import '../../domain/entities/tcg_card.dart';
import '../../domain/entities/user_card_entry.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/auth_guard.dart';
import '../widgets/card_filter_sheet.dart';
import '../widgets/card_tile.dart';
import '../widgets/dex_ui.dart';

/// Folha de ações ao manter pressionada uma carta na grelha — atalho para ver
/// os anúncios dessa carta na Comunidade sem abrir o detalhe.
void _showCardOffersSheet(BuildContext context, String cardId, String cardName) {
  final t = AppLocalizations.of(context)!;
  showModalBottomSheet<void>(
    context: context,
    builder: (sheetCtx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.style),
            title: Text(cardName),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.storefront),
            title: Text(t.checkCommunityOffers),
            onTap: () {
              Navigator.of(sheetCtx).pop();
              context.push('/community/card/$cardId');
            },
          ),
        ],
      ),
    ),
  );
}

/// Cartas de um set: sincroniza (busca à API), abas com contagens, pesquisa,
/// barra de progresso e FAB de adição rápida.
class SetCardsScreen extends ConsumerStatefulWidget {
  final String setId;
  final String? initialStatus;
  const SetCardsScreen({super.key, required this.setId, this.initialStatus});

  @override
  ConsumerState<SetCardsScreen> createState() => _SetCardsScreenState();
}

class _SetCardsScreenState extends ConsumerState<SetCardsScreen> {
  @override
  void initState() {
    super.initState();
    final st = switch (widget.initialStatus) {
      'owned' => CardStatusFilter.owned,
      'missing' => CardStatusFilter.missing,
      _ => null,
    };
    if (st != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(cardFilterProvider(widget.setId).notifier).state =
            CardFilter(status: st);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final setAsync = ref.watch(setByIdProvider(widget.setId));
    final sync = ref.watch(setSyncProvider(widget.setId));
    final cardsAsync = ref.watch(cardsListProvider(widget.setId));
    final countsAsync = ref.watch(setCountsProvider(widget.setId));
    final filter = ref.watch(cardFilterProvider(widget.setId));

    return Scaffold(
      appBar: AppBar(
        title: Text(setAsync.valueOrNull?.name ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => showModalBottomSheet(
              context: context,
              showDragHandle: true,
              isScrollControlled: true,
              builder: (_) => CardFilterSheet(widget.setId),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!requireSignIn(context, ref)) return; // convidado → login
          showModalBottomSheet(
            context: context,
            showDragHandle: true,
            isScrollControlled: true,
            builder: (_) => _QuickAddSheet(setId: widget.setId),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Barra "% completo"
          countsAsync.maybeWhen(
            data: (c) {
              final pct = c.total == 0 ? 0 : (c.owned / c.total * 100).round();
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(DexRadii.pill),
                        child: LinearProgressIndicator(
                          value: c.total == 0 ? 0 : c.owned / c.total,
                          minHeight: 8,
                          color: DexColors.green500,
                          backgroundColor: cs.surfaceContainerHigh,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(t.percentComplete(pct),
                        style: AppTheme.mono(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: DexColors.green500)),
                  ],
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          // Coleção por tipo (recolhível, para não ocupar a grelha)
          _TypeBreakdown(setId: widget.setId),
          // Pesquisa
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: t.searchCardsHint,
              ),
              onChanged: (v) {
                final f = ref.read(cardFilterProvider(widget.setId));
                ref.read(cardFilterProvider(widget.setId).notifier).state =
                    f.copyWith(query: v);
              },
            ),
          ),
          // Abas Tudo / Tenho / Em falta com contagens
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: countsAsync.maybeWhen(
              data: (c) => _StatusTabs(
                setId: widget.setId,
                current: filter.status,
                all: c.total,
                owned: c.owned,
                missing: c.total - c.owned,
              ),
              orElse: () => _StatusTabs(
                  setId: widget.setId, current: filter.status),
            ),
          ),
          const SizedBox(height: 6),
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
              error: (e, _) => EmptyState(
                icon: Icons.wifi_off,
                title: t.cardsLoadError,
                action: FilledButton(
                  onPressed: () =>
                      ref.invalidate(setSyncProvider(widget.setId)),
                  child: Text(t.retry),
                ),
              ),
              data: (_) => cardsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
                data: (items) {
                  if (items.isEmpty) {
                    return EmptyState(
                      icon: switch (filter.status) {
                        CardStatusFilter.missing => Icons.celebration,
                        CardStatusFilter.owned => Icons.style,
                        _ => Icons.search_off,
                      },
                      title: switch (filter.status) {
                        CardStatusFilter.missing => t.allCollected,
                        CardStatusFilter.owned => t.emptyOwned,
                        _ => t.noMatch,
                      },
                      description: filter.status == CardStatusFilter.owned
                          ? t.emptyOwnedBody
                          : null,
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.62,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final card = items[i].card;
                      return CardTile(
                        item: items[i],
                        onTap: () => context.push('/card/${card.id}'),
                        onLongPress: () =>
                            _showCardOffersSheet(context, card.id, card.name),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Abas de estado com contagens (Tudo / Tenho / Em falta).
class _StatusTabs extends ConsumerWidget {
  final String setId;
  final CardStatusFilter current;
  final int? all;
  final int? owned;
  final int? missing;
  const _StatusTabs({
    required this.setId,
    required this.current,
    this.all,
    this.owned,
    this.missing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    Widget seg(CardStatusFilter s, String label, int? count) {
      final on = current == s;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            final f = ref.read(cardFilterProvider(setId));
            ref.read(cardFilterProvider(setId).notifier).state =
                f.copyWith(status: s);
          },
          child: Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: on ? cs.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(DexRadii.pill),
            ),
            child: Text(
              count == null ? label : '$label · $count',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                color: on ? cs.onPrimary : cs.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(DexRadii.pill),
      ),
      child: Row(
        children: [
          seg(CardStatusFilter.all, t.statusAll, all),
          seg(CardStatusFilter.owned, t.statusOwned, owned),
          seg(CardStatusFilter.missing, t.statusMissing, missing),
        ],
      ),
    );
  }
}

/// Folha de adição rápida: lista cartas em falta para marcar como "tenho".
class _QuickAddSheet extends ConsumerWidget {
  final String setId;
  const _QuickAddSheet({required this.setId});

  Future<void> _markOwned(
      WidgetRef ref, BuildContext context, TcgCard card) async {
    final repo = ref.read(collectionRepositoryProvider);
    final t = AppLocalizations.of(context)!;
    await repo.save(UserCardEntry(
        cardId: card.id,
        ownedNormal: true,
        qtyNormal: 1,
        updatedAt: DateTime.now()));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(t.addedToBinder(card.name)),
      action: SnackBarAction(
        label: t.undo,
        onPressed: () => repo
            .save(UserCardEntry(cardId: card.id, updatedAt: DateTime.now())),
      ),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final missing = ref.watch(missingCardsProvider(setId));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(t.quickAddTitle,
                style: Theme.of(context).textTheme.titleLarge),
          ),
          Expanded(
            child: missing.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (items) => items.isEmpty
                  ? EmptyState(icon: Icons.celebration, title: t.allCollected)
                  : ListView.builder(
                      controller: controller,
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final c = items[i].card;
                        return ListTile(
                          leading: SizedBox(
                            width: 36,
                            height: 50,
                            child: CachedNetworkImage(
                              imageUrl: c.imageSmall,
                              fit: BoxFit.contain,
                              placeholder: (_, __) => const SizedBox.shrink(),
                              errorWidget: (_, __, ___) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                          ),
                          title: Text(c.name,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text('#${c.number}',
                              style: AppTheme.mono(fontSize: 11)),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle),
                            color: Theme.of(context).colorScheme.primary,
                            onPressed: () => _markOwned(ref, context, c),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Secção recolhível "Coleção por tipo" para os detalhes de um set:
/// mostra as cartas possuídas por tipo (ex.: grass, fire…) nessa coleção.
class _TypeBreakdown extends ConsumerWidget {
  final String setId;
  const _TypeBreakdown({required this.setId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final byType = ref.watch(setByTypeProvider(setId));

    return byType.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (rows) {
        if (rows.isEmpty) return const SizedBox.shrink();
        final max = rows.first.owned;
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Theme(
            // Remove os divisores nativos do ExpansionTile.
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Material(
              color: cs.surface,
              borderRadius: BorderRadius.circular(DexRadii.lg),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(DexRadii.lg),
                child: ExpansionTile(
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  leading: Icon(Icons.donut_small, color: cs.primary),
                  title: Text(t.statsByType,
                      style: AppTheme.mono(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface)),
                  children: rows
                      .map((r) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                SizedBox(
                                    width: 120,
                                    child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: TypeBadge(r.type, soft: true))),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(DexRadii.pill),
                                    child: LinearProgressIndicator(
                                      value: max <= 0
                                          ? 0
                                          : (r.owned / max).clamp(0.0, 1.0),
                                      minHeight: 10,
                                      color: colorForCardType(r.type),
                                      backgroundColor: cs.surfaceContainerHigh,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 34,
                                  child: Text(' ${r.owned}',
                                      textAlign: TextAlign.right,
                                      style: AppTheme.mono(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: cs.onSurface)),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
