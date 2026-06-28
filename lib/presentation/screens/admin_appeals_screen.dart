import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';

/// Apelações de utilizadores banidos (só admin). Permite desbanir direto.
class AdminAppealsScreen extends ConsumerStatefulWidget {
  const AdminAppealsScreen({super.key});
  @override
  ConsumerState<AdminAppealsScreen> createState() => _AdminAppealsScreenState();
}

class _AdminAppealsScreenState extends ConsumerState<AdminAppealsScreen> {
  @override
  void initState() {
    super.initState();
    // Ao abrir, marca as apelações como vistas (zera o badge).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      ref.read(lastSeenAppealsProvider.notifier).state = now;
      ref.read(prefsProvider).setInt('lastSeenAppeals', now.millisecondsSinceEpoch);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final items = ref.watch(appealsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.adminAppeals)),
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => list.isEmpty
            ? Center(child: Text(t.noAppeals))
            : ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final a = list[i];
                  return ListTile(
                    isThreeLine: true,
                    leading: const Icon(Icons.record_voice_over_outlined),
                    title: Text(a.name.isEmpty ? a.uid : a.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(a.text),
                    trailing: TextButton(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(ctx);
                        await ref
                            .read(adminServiceProvider)
                            .banUser(a.uid, false);
                        messenger
                          ..clearSnackBars()
                          ..showSnackBar(
                              SnackBar(content: Text(t.userUnbanned)));
                      },
                      child: Text(t.unban),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
