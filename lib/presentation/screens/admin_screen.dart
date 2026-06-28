import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/admin_service.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../report_reasons.dart';
import 'admin_broadcast_screen.dart';
import 'admin_chat_screen.dart';
import 'admin_users_screen.dart';

/// Painel de administração (só [kAdminEmail]): menu para as várias áreas.
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    void go(Widget page) => Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => page));
    return Scaffold(
      appBar: AppBar(title: Text(t.admin)),
      body: ListView(children: [
        ListTile(
          leading: const Icon(Icons.flag_outlined),
          title: Text(t.adminReports),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => go(const _AdminReportsPage()),
        ),
        ListTile(
          leading: const Icon(Icons.lightbulb_outline),
          title: Text(t.adminSuggestions),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => go(const _AdminSuggestionsPage()),
        ),
        ListTile(
          leading: const Icon(Icons.block),
          title: Text(t.adminBanned),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => go(const AdminBannedScreen()),
        ),
        ListTile(
          leading: const Icon(Icons.workspace_premium_outlined),
          title: Text(t.adminPremium),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => go(const AdminPremiumScreen()),
        ),
        ListTile(
          leading: const Icon(Icons.campaign_outlined),
          title: Text(t.adminBroadcast),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => go(const AdminBroadcastScreen()),
        ),
      ]),
    );
  }
}

class _AdminReportsPage extends StatelessWidget {
  const _AdminReportsPage();
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.adminReports)),
        body: const _ReportsTab(),
      );
}

class _AdminSuggestionsPage extends StatelessWidget {
  const _AdminSuggestionsPage();
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar:
            AppBar(title: Text(AppLocalizations.of(context)!.adminSuggestions)),
        body: const _SuggestionsTab(),
      );
}

class _ReportsTab extends ConsumerWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final reports = ref.watch(reportsProvider);
    final filter = ref.watch(reportFilterProvider);
    return Column(children: [
      _filterBar(context, ref, t, filter),
      const Divider(height: 1),
      Expanded(
        child: reports.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (all) {
            final list =
                filter == null ? all : all.where((r) => r.reason == filter).toList();
            return list.isEmpty
                ? Center(child: Text(t.noReports))
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) => _ReportTile(report: list[i]),
                  );
          },
        ),
      ),
    ]);
  }

  Widget _filterBar(
      BuildContext context, WidgetRef ref, AppLocalizations t, String? filter) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          for (final r in <String?>[null, ...kReportReasons])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: ChoiceChip(
                  label: Text(r == null ? t.reportAll : reportReasonLabel(t, r)),
                  selected: filter == r,
                  onSelected: (_) =>
                      ref.read(reportFilterProvider.notifier).state = r,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReportTile extends ConsumerWidget {
  final Report report;
  const _ReportTile({required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final svc = ref.read(adminServiceProvider);
    final name = report.reportedName.isEmpty ? report.reportedUid : report.reportedName;
    return ListTile(
      leading: const Icon(Icons.flag_outlined),
      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
          '${reportReasonLabel(t, report.reason)} · ${report.listingId}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => AdminChatScreen(report: report))),
      trailing: PopupMenuButton<String>(
        onSelected: (v) async {
          final messenger = ScaffoldMessenger.of(context);
          if (v == 'warn') {
            final text = await _promptWarning(context, t);
            if (text == null || text.trim().isEmpty) return;
            await svc.warnUser(report.reportedUid, text);
            await svc.markReportHandled(report.id);
            messenger.showSnackBar(SnackBar(content: Text(t.userWarned)));
          } else if (v == 'ban') {
            final ok = await _confirmBan(context, t);
            if (ok != true) return;
            await svc.banUser(report.reportedUid, true);
            await svc.markReportHandled(report.id);
            messenger.showSnackBar(SnackBar(content: Text(t.userBanned)));
          } else if (v == 'delete') {
            await svc.deleteListing(report.listingId);
            await svc.markReportHandled(report.id);
            messenger.showSnackBar(SnackBar(content: Text(t.listingDeleted)));
          } else if (v == 'handled') {
            await svc.markReportHandled(report.id);
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(value: 'warn', child: Text(t.warnUser)),
          PopupMenuItem(value: 'ban', child: Text(t.banUser)),
          PopupMenuItem(value: 'delete', child: Text(t.deleteListing)),
          PopupMenuItem(value: 'handled', child: Text(t.markHandled)),
        ],
      ),
    );
  }

  Future<String?> _promptWarning(BuildContext context, AppLocalizations t) {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.warnTitle),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(hintText: t.warnHint),
        ),
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
  }

  Future<bool?> _confirmBan(BuildContext context, AppLocalizations t) =>
      showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(t.banConfirm),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel)),
            FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(t.banUser)),
          ],
        ),
      );
}

class _SuggestionsTab extends ConsumerWidget {
  const _SuggestionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final items = ref.watch(suggestionsProvider);
    return items.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (list) => list.isEmpty
          ? Center(child: Text(t.noSuggestions))
          : ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final s = list[i];
                return ListTile(
                  leading: const Icon(Icons.lightbulb_outline),
                  title: Text(s.text),
                  subtitle: Text(s.name.isEmpty ? s.uid : s.name),
                );
              },
            ),
    );
  }
}
