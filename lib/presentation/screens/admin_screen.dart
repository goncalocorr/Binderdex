import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/admin_service.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';

/// Painel de administração (só [kAdminEmail]): denúncias + sugestões.
class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.admin),
          bottom: TabBar(tabs: [
            Tab(text: t.adminReports),
            Tab(text: t.adminSuggestions),
          ]),
        ),
        body: const TabBarView(children: [_ReportsTab(), _SuggestionsTab()]),
      ),
    );
  }
}

class _ReportsTab extends ConsumerWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final reports = ref.watch(reportsProvider);
    return reports.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (list) => list.isEmpty
          ? Center(child: Text(t.noReports))
          : ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => _ReportTile(report: list[i]),
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
      subtitle: Text('${report.reason} · ${report.listingId}',
          maxLines: 2, overflow: TextOverflow.ellipsis),
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
          } else if (v == 'handled') {
            await svc.markReportHandled(report.id);
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(value: 'warn', child: Text(t.warnUser)),
          PopupMenuItem(value: 'ban', child: Text(t.banUser)),
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
