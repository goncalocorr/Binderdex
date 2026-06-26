import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/listing.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import 'want_cards_field.dart';

/// Folha de edição de um anúncio já publicado. A carta é fixa; só se editam
/// modo, condição, "o que quero" e nota.
class EditListingSheet extends ConsumerStatefulWidget {
  final Listing listing;
  const EditListingSheet({super.key, required this.listing});

  @override
  ConsumerState<EditListingSheet> createState() => _EditListingSheetState();
}

class _EditListingSheetState extends ConsumerState<EditListingSheet> {
  late TradeMode _mode = widget.listing.mode;
  late CardCondition _cond = widget.listing.condition;
  late List<CardRef> _wantCards = widget.listing.wantCards;
  late final _note = TextEditingController(text: widget.listing.note ?? '');
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final t = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(t.deleteListingConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(marketServiceProvider)
          .deleteListing(widget.listing.id, widget.listing.ownerUid);
      if (mounted) Navigator.of(context).pop(true);
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$err')));
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await ref.read(marketServiceProvider).editListing(
            id: widget.listing.id,
            mode: _mode,
            condition: _cond,
            wantText: null,
            note: _note.text,
            wantCards: _mode == TradeMode.sell ? const [] : _wantCards,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$err')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          const Icon(Icons.edit, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text('${t.editListingTitle} · ${widget.listing.cardName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium),
          ),
        ]),
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
            DropdownMenuItem(
                value: CardCondition.damaged, child: Text(t.condDamaged)),
          ],
          onChanged: (v) => setState(() => _cond = v ?? CardCondition.good),
        ),
        const SizedBox(height: 12),
        if (_mode != TradeMode.sell) ...[
          WantCardsField(
            cards: _wantCards,
            onChanged: (v) => setState(() => _wantCards = v),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _note,
          maxLength: 280,
          decoration: InputDecoration(
              labelText: t.noteOptional, border: const OutlineInputBorder()),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: _busy
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(t.save),
        ),
        TextButton.icon(
          onPressed: _busy ? null : _delete,
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          label: Text(t.deleteListingAction,
              style: const TextStyle(color: Colors.red)),
        ),
      ]),
    );
  }
}
