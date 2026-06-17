import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/sets_repository.dart';

/// Linha de uma coleção (set) com logótipo, série e progresso.
class SetTile extends StatelessWidget {
  final SetProgress data;
  final VoidCallback onTap;
  const SetTile({super.key, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = data.set;
    final p = data.progress;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: SizedBox(
          width: 56,
          height: 40,
          child: s.logoUrl.isEmpty
              ? const Icon(Icons.style)
              : CachedNetworkImage(
                  imageUrl: s.logoUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const SizedBox.shrink(),
                  errorWidget: (_, __, ___) => const Icon(Icons.style),
                ),
        ),
        title: Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.series, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: p.percent, minHeight: 6),
            ),
          ],
        ),
        trailing: Text('${p.owned}/${p.total}'),
      ),
    );
  }
}
