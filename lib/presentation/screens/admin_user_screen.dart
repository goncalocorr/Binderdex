import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/dex_tokens.dart';
import '../../domain/entities/market_tier.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/dex_ui.dart';
import '../widgets/premium_badge.dart';

/// Stats e ações de um utilizador (admin): premium, banido, nº de anúncios e
/// denúncias, com avisar / banir / mudar nível.
class AdminUserScreen extends ConsumerWidget {
  final String uid;
  final String fallbackName;
  const AdminUserScreen({super.key, required this.uid, this.fallbackName = ''});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final userAsync = ref.watch(adminUserProvider(uid));
    final reports = ref.watch(adminUserReportsProvider(uid)).valueOrNull ?? const [];
    final listings = ref.watch(adminUserListingsProvider(uid)).valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(
          title: Text(userAsync.valueOrNull?.name.isNotEmpty == true
              ? userAsync.valueOrNull!.name
              : (fallbackName.isEmpty ? uid : fallbackName))),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (u) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Cabeçalho
            Row(children: [
              CircleAvatar(
                radius: 26,
                backgroundImage: u.avatar.isEmpty
                    ? null
                    : AssetImage('assets/avatars/${u.avatar}.png'),
                child: u.avatar.isEmpty ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(u.name.isEmpty ? '—' : u.name,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(u.uid,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
            ]),
            const SizedBox(height: 12),
            // Estado (premium / banido)
            Wrap(spacing: 8, runSpacing: 8, children: [
              if (MarketTier.isPremium(u.tier))
                Chip(
                  avatar: PremiumBadge(size: 16, tier: u.tier),
                  label: Text(MarketTier.nameFor(u.tier)),
                ),
              if (u.banned)
                Chip(
                  avatar: const Icon(Icons.block, size: 16, color: Colors.red),
                  label: Text(t.bannedLabel),
                ),
            ]),
            const SizedBox(height: 16),
            // Stats
            Row(children: [
              Expanded(
                child: StatCard(
                    icon: Icons.sell,
                    value: '${listings.length}',
                    label: t.statListings,
                    color: DexColors.gold500),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                    icon: Icons.flag_outlined,
                    value: '${reports.length}',
                    label: t.statReports,
                    color: DexColors.red500),
              ),
            ]),
            const SizedBox(height: 20),
            // Ações
            Wrap(spacing: 8, runSpacing: 8, children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.warning_amber_rounded),
                label: Text(t.warnUser),
                onPressed: () => _warn(context, ref, t),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.workspace_premium_outlined),
                label: Text(t.change),
                onPressed: () => _pickTier(context, ref, t),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: u.banned ? null : Colors.red),
                icon: Icon(u.banned ? Icons.lock_open : Icons.block),
                label: Text(u.banned ? t.unban : t.banUser),
                onPressed: () =>
                    ref.read(adminServiceProvider).banUser(uid, !u.banned),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Future<void> _warn(
      BuildContext context, WidgetRef ref, AppLocalizations t) async {
    final ctrl = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.warnTitle),
        content: TextField(
            controller: ctrl,
            autofocus: true,
            maxLines: 3,
            decoration: InputDecoration(hintText: t.warnHint)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel)),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(ctrl.text),
              child: Text(t.send)),
        ],
      ),
    );
    if (text == null || text.trim().isEmpty) return;
    await ref.read(adminServiceProvider).warnUser(uid, text);
    messenger.showSnackBar(SnackBar(content: Text(t.userWarned)));
  }

  Future<void> _pickTier(
      BuildContext context, WidgetRef ref, AppLocalizations t) async {
    final messenger = ScaffoldMessenger.of(context);
    final tier = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < MarketTier.names.length; i++)
            ListTile(
                title: Text(MarketTier.nameFor(i)),
                onTap: () => Navigator.of(ctx).pop(i)),
        ]),
      ),
    );
    if (tier == null) return;
    await ref.read(adminServiceProvider).setUserTier(uid, tier);
    messenger.showSnackBar(SnackBar(content: Text(t.premiumUpdated)));
  }
}
