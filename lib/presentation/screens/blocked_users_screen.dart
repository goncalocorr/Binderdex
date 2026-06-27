import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';

/// Lista de utilizadores bloqueados, com opção de desbloquear.
class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final blocked = ref.watch(blockedUsersProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.blockedUsers)),
      body: blocked.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => list.isEmpty
            ? Center(child: Text(t.noBlockedUsers))
            : ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final u = list[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: u.avatar.isEmpty
                          ? null
                          : AssetImage('assets/avatars/${u.avatar}.png'),
                      child:
                          u.avatar.isEmpty ? const Icon(Icons.person) : null,
                    ),
                    title: Text(u.name.isEmpty ? '—' : u.name),
                    trailing: TextButton(
                      onPressed: () {
                        final me =
                            ref.read(authStateProvider).valueOrNull?.uid;
                        if (me != null) {
                          ref.read(marketServiceProvider).unblock(me, u.uid);
                        }
                      },
                      child: Text(t.unblock),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
