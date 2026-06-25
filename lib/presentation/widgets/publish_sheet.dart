import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/market_service.dart';
import '../../domain/entities/listing.dart';
import '../../domain/entities/market_tier.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';

class PublishSheet extends ConsumerStatefulWidget {
  final List<CardRef> cards;
  const PublishSheet({super.key, required this.cards});

  @override
  ConsumerState<PublishSheet> createState() => _PublishSheetState();
}

class _PublishSheetState extends ConsumerState<PublishSheet> {
  TradeMode _mode = TradeMode.trade;
  CardCondition _cond = CardCondition.good;
  final _want = TextEditingController();
  final _note = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _want.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    final t = AppLocalizations.of(context)!;
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    final tier = ref.read(marketTierProvider).valueOrNull ?? 0;
    final active = ref.read(activeListingsCountProvider);
    if (!MarketTier.canPublish(
        activeCount: active, tier: tier, selectedCount: widget.cards.length)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.slotLimitReached)));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(marketServiceProvider).publish(
            cards: widget.cards,
            ownerUid: uid,
            ownerName: ref.read(displayNameProvider),
            ownerAvatar: ref.read(avatarProvider),
            tier: tier,
            activeCount: active,
            mode: _mode,
            condition: _cond,
            wantText: _want.text.trim(),
            note: _note.text.trim(),
          );
      if (mounted) Navigator.of(context).pop(true);
    } on SlotLimitException {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(t.slotLimitReached)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final tier = ref.watch(marketTierProvider).valueOrNull ?? 0;
    final active = ref.watch(activeListingsCountProvider);
    return Padding(
      padding: EdgeInsets.only(
          left: 16, right: 16, top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(t.slotsUsed(active, MarketTier.slotsFor(tier)),
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 12),
        SegmentedButton<TradeMode>(
          segments: [
            ButtonSegment(value: TradeMode.trade, label: Text(t.modeTrade)),
            ButtonSegment(value: TradeMode.sell, label: Text(t.modeSell)),
            ButtonSegment(value: TradeMode.both, label: Text(t.modeBoth)),
          ],
          selected: {_mode},
          onSelectionChanged: (s) => setState(() => _mode = s.first),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<CardCondition>(
          initialValue: _cond,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: [
            DropdownMenuItem(value: CardCondition.mint, child: Text(t.condMint)),
            DropdownMenuItem(value: CardCondition.good, child: Text(t.condGood)),
            DropdownMenuItem(value: CardCondition.used, child: Text(t.condUsed)),
            DropdownMenuItem(value: CardCondition.damaged, child: Text(t.condDamaged)),
          ],
          onChanged: (v) => setState(() => _cond = v ?? CardCondition.good),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _want,
          maxLength: 280,
          decoration: InputDecoration(
              labelText: t.whatIWant, border: const OutlineInputBorder()),
        ),
        TextField(
          controller: _note,
          maxLength: 280,
          decoration: InputDecoration(
              labelText: t.noteOptional, border: const OutlineInputBorder()),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _busy ? null : _publish,
          child: _busy
              ? const SizedBox(
                  height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text('${t.publish} (${widget.cards.length})'),
        ),
      ]),
    );
  }
}
