import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/market_tier.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';

/// Utilizadores banidos — com opção de desbanir.
class AdminBannedScreen extends ConsumerWidget {
  const AdminBannedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final users = ref.watch(bannedUsersAdminProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.adminBanned)),
      body: users.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => list.isEmpty
            ? Center(child: Text(t.noBanned))
            : ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final u = list[i];
                  return ListTile(
                    leading: const Icon(Icons.block, color: Colors.red),
                    title: Text(u.name.isEmpty ? u.uid : u.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(u.uid,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: TextButton(
                      onPressed: () =>
                          ref.read(adminServiceProvider).banUser(u.uid, false),
                      child: Text(t.unban),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// Utilizadores premium — ver quem tem, mudar/remover o nível, e conceder a
/// uma conta (por uid).
class AdminPremiumScreen extends ConsumerStatefulWidget {
  const AdminPremiumScreen({super.key});
  @override
  ConsumerState<AdminPremiumScreen> createState() => _AdminPremiumScreenState();
}

class _AdminPremiumScreenState extends ConsumerState<AdminPremiumScreen> {
  final _uid = TextEditingController();

  @override
  void dispose() {
    _uid.dispose();
    super.dispose();
  }

  /// Menu para escolher o nível (0 = Grátis = remover).
  Future<void> _pickTier(String uid) async {
    final t = AppLocalizations.of(context)!;
    final tier = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < MarketTier.names.length; i++)
              ListTile(
                title: Text(MarketTier.nameFor(i)),
                onTap: () => Navigator.of(ctx).pop(i),
              ),
          ],
        ),
      ),
    );
    if (tier == null) return;
    await ref.read(adminServiceProvider).setUserTier(uid, tier);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(t.premiumUpdated)));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final users = ref.watch(premiumUsersProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.adminPremium)),
      body: Column(children: [
        // Conceder premium a uma conta por uid.
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _uid,
                decoration: InputDecoration(
                    labelText: t.grantPremium, hintText: t.uidHint),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () {
                final uid = _uid.text.trim();
                if (uid.isNotEmpty) _pickTier(uid);
              },
              child: Text(t.grant),
            ),
          ]),
        ),
        const Divider(height: 1),
        Expanded(
          child: users.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (list) => list.isEmpty
                ? Center(child: Text(t.noPremiumUsers))
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final u = list[i];
                      return ListTile(
                        leading: const Icon(Icons.workspace_premium,
                            color: Color(0xFFE0A100)),
                        title: Text(u.name.isEmpty ? u.uid : u.name,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(MarketTier.nameFor(u.tier)),
                        trailing: TextButton(
                          onPressed: () => _pickTier(u.uid),
                          child: Text(t.change),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ]),
    );
  }
}
