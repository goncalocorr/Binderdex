import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/admin_service.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../report_reasons.dart';
import 'admin_broadcast_screen.dart';
import 'admin_chat_screen.dart';
import 'admin_users_screen.dart';

/// Etiqueta de como a denúncia foi resolvida.
String _resolutionLabel(AppLocalizations t, String resolution) {
  switch (resolution) {
    case 'warn':
      return t.resolvedWarn;
    case 'ban':
      return t.resolvedBan;
    case 'delete':
      return t.resolvedDelete;
    default:
      return t.resolved;
  }
}

/// Painel de administração (só [kAdminEmail]): menu para as várias áreas.
class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final reports = ref.watch(openReportsCountProvider);
    final suggestions = ref.watch(unseenSuggestionsCountProvider);
    void go(Widget page) => Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => page));
    return Scaffold(
      appBar: AppBar(title: Text(t.admin)),
      body: ListView(children: [
        _row(Icons.flag_outlined, t.adminReports,
            onTap: () => go(const _AdminReportsPage()), count: reports),
        _row(Icons.lightbulb_outline, t.adminSuggestions,
            onTap: () => go(const _AdminSuggestionsPage()), count: suggestions),
        _row(Icons.block, t.adminBanned,
            onTap: () => go(const AdminBannedScreen())),
        _row(Icons.workspace_premium_outlined, t.adminPremium,
            onTap: () => go(const AdminPremiumScreen())),
        _row(Icons.campaign_outlined, t.adminBroadcast,
            onTap: () => go(const AdminBroadcastScreen())),
      ]),
    );
  }

  Widget _row(IconData icon, String title,
          {required VoidCallback onTap, int count = 0}) =>
      ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (count > 0) Badge(label: Text('$count')),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right),
        ]),
        onTap: onTap,
      );
}

class _AdminReportsPage extends StatelessWidget {
  const _AdminReportsPage();
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.adminReports)),
        body: const _ReportsTab(),
      );
}

class _AdminSuggestionsPage extends ConsumerStatefulWidget {
  const _AdminSuggestionsPage();
  @override
  ConsumerState<_AdminSuggestionsPage> createState() =>
      _AdminSuggestionsPageState();
}

class _AdminSuggestionsPageState extends ConsumerState<_AdminSuggestionsPage> {
  @override
  void initState() {
    super.initState();
    // Ao abrir, marca as sugestões como vistas (zera o badge).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      ref.read(lastSeenSuggestionsProvider.notifier).state = now;
      ref
          .read(prefsProvider)
          .setInt('lastSeenSuggestions', now.millisecondsSinceEpoch);
    });
  }

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(children: [
        const Icon(Icons.filter_list),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButton<String?>(
            isExpanded: true,
            value: filter,
            items: [
              DropdownMenuItem(value: null, child: Text(t.reportAll)),
              for (final r in kReportReasons)
                DropdownMenuItem(
                    value: r, child: Text(reportReasonLabel(t, r))),
            ],
            onChanged: (v) =>
                ref.read(reportFilterProvider.notifier).state = v,
          ),
        ),
      ]),
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
    final resolved = report.status != 'open';
    return ListTile(
      isThreeLine: resolved,
      leading: Icon(resolved ? Icons.check_circle : Icons.flag_outlined,
          color: resolved ? Colors.green : null),
      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(reportReasonLabel(t, report.reason),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          if (resolved)
            Text(_resolutionLabel(t, report.resolution),
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.w600)),
        ],
      ),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => AdminChatScreen(report: report))),
      trailing: PopupMenuButton<String>(
        onSelected: (v) async {
          final messenger = ScaffoldMessenger.of(context);
          if (v == 'warn') {
            final text = await _promptWarning(context, t);
            if (text == null || text.trim().isEmpty) return;
            await svc.warnUser(report.reportedUid, text);
            await svc.resolveReport(report.id, 'warn');
            messenger.showSnackBar(SnackBar(content: Text(t.userWarned)));
          } else if (v == 'ban') {
            final ok = await _confirmBan(context, t);
            if (ok != true) return;
            await svc.banUser(report.reportedUid, true);
            await svc.resolveReport(report.id, 'ban');
            messenger.showSnackBar(SnackBar(content: Text(t.userBanned)));
          } else if (v == 'delete') {
            await svc.deleteListing(report.listingId);
            await svc.resolveReport(report.id, 'delete');
            messenger.showSnackBar(SnackBar(content: Text(t.listingDeleted)));
          } else if (v == 'handled') {
            await svc.resolveReport(report.id, 'done');
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
