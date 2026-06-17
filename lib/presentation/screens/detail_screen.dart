import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/sprites.dart';
import '../../domain/entities/user_entry.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/type_chip.dart';

/// Detalhe de um Pokémon + edição do registo de coleção.
class DetailScreen extends ConsumerStatefulWidget {
  final int id;
  const DetailScreen({super.key, required this.id});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  bool _showShiny = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final pokeAsync = ref.watch(pokemonByIdProvider(widget.id));
    final entryAsync = ref.watch(entryProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(_showShiny ? Icons.star : Icons.star_border,
                color: Colors.amber),
            tooltip: t.shiny,
            onPressed: () => setState(() => _showShiny = !_showShiny),
          ),
        ],
      ),
      body: pokeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (p) {
          if (p == null) return const Center(child: Text('—'));
          return entryAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro: $e')),
            data: (entry) {
              final repo = ref.read(collectionRepositoryProvider);
              void save(UserEntry e) =>
                  repo.save(e.copyWith(updatedAt: DateTime.now()));

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: CachedNetworkImage(
                      imageUrl: Sprites.artwork(p.id, shiny: _showShiny),
                      height: 200,
                      placeholder: (_, __) => const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.catching_pokemon, size: 96),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('#${p.id}  ${p.name}',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: p.types.map((ty) => TypeChip(ty)).toList(),
                  ),
                  const SizedBox(height: 12),
                  if (p.description.isNotEmpty) Text(p.description),
                  const Divider(height: 32),
                  Text(t.baseStats,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _StatBar(label: t.statHp, value: p.hp),
                  _StatBar(label: t.statAttack, value: p.attack),
                  _StatBar(label: t.statDefense, value: p.defense),
                  _StatBar(label: t.statSpAttack, value: p.spAttack),
                  _StatBar(label: t.statSpDefense, value: p.spDefense),
                  _StatBar(label: t.statSpeed, value: p.speed),
                  const Divider(height: 32),

                  // --- Edição da coleção ---
                  SwitchListTile(
                    title: Text(t.caught),
                    value: entry.caught,
                    onChanged: (v) => save(entry.copyWith(caught: v)),
                  ),
                  SwitchListTile(
                    title: Text(t.shiny),
                    value: entry.shiny,
                    onChanged: (v) => save(entry.copyWith(shiny: v)),
                  ),
                  ListTile(
                    title: Text(t.quantity),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: entry.quantity > 0
                              ? () => save(entry.copyWith(
                                  quantity: entry.quantity - 1))
                              : null,
                        ),
                        Text('${entry.quantity}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => save(
                              entry.copyWith(quantity: entry.quantity + 1)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextFormField(
                      // A key garante que o campo é recriado ao mudar de Pokémon.
                      key: ValueKey('notes_${p.id}'),
                      initialValue: entry.notes,
                      decoration: InputDecoration(
                        labelText: t.notes,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      // ⭐ PREMIUM: no futuro, notas longas/ilimitadas podem ser premium.
                      onChanged: (v) => save(entry.copyWith(notes: v)),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final int value;
  const _StatBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            SizedBox(width: 90, child: Text(label)),
            Expanded(
              child: LinearProgressIndicator(
                value: (value / 255).clamp(0, 1),
                minHeight: 8,
              ),
            ),
            SizedBox(
                width: 40,
                child: Text(' $value', textAlign: TextAlign.right)),
          ],
        ),
      );
}
