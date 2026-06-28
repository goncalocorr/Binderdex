import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Motivos de denúncia (ids guardados em `reports/{}.reason`).
const List<String> kReportReasons = [
  'scam',
  'abuse',
  'inappropriate',
  'fake',
  'spam',
  'other',
];

/// Etiqueta localizada de um motivo. Motivos antigos/desconhecidos (ex.: 'user')
/// caem em "Outro".
String reportReasonLabel(AppLocalizations t, String id) {
  switch (id) {
    case 'scam':
      return t.reportScam;
    case 'abuse':
      return t.reportAbuse;
    case 'inappropriate':
      return t.reportInappropriate;
    case 'fake':
      return t.reportFake;
    case 'spam':
      return t.reportSpam;
    default:
      return t.reportOther;
  }
}

/// Mostra o seletor de motivo de denúncia. Devolve o id escolhido (ou null se
/// cancelar).
Future<String?> pickReportReason(BuildContext context) {
  final t = AppLocalizations.of(context)!;
  return showModalBottomSheet<String>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(t.reportReasonTitle,
                style: Theme.of(ctx).textTheme.titleLarge),
          ),
          for (final r in kReportReasons)
            ListTile(
              title: Text(reportReasonLabel(t, r)),
              onTap: () => Navigator.of(ctx).pop(r),
            ),
        ],
      ),
    ),
  );
}
