import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/dex_tokens.dart';
import '../../domain/entities/market_tier.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/premium_badge.dart';

/// Ecrã de subscrição premium. Mostra os níveis e desbloqueia via marcador
/// (`setTier`). O botão "Desbloquear" fica pronto para ligar ao Play Billing.
class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final current = ref.watch(marketTierProvider).valueOrNull ?? 0;
    return Scaffold(
      appBar: AppBar(title: Text(t.premium)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(t.premiumYourPlan(MarketTier.nameFor(current)),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          for (var i = 0; i < MarketTier.slots.length; i++)
            _TierCard(tier: i, current: current),
        ],
      ),
    );
  }
}

class _TierCard extends ConsumerWidget {
  final int tier;
  final int current;
  const _TierCard({required this.tier, required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final isCurrent = tier == current;
    final premium = MarketTier.isPremium(tier);

    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(DexRadii.lg),
        border: Border.all(
          // Nos premium o anel do glow faz de moldura (sem dourado por cima);
          // o plano atual distingue-se pelo glow reforçado + selo no botão.
          color: premium
              ? Colors.transparent
              : (isCurrent ? DexColors.gold500 : cs.outlineVariant),
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            if (premium) PremiumBadge(size: 22, tier: tier),
            if (premium) const SizedBox(width: 6),
            Text(MarketTier.nameFor(tier),
                style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            if (premium)
              Text('${MarketTier.priceFor(tier)}${t.perMonth}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 10),
          _perk(context, t.perkSlots(MarketTier.slotsFor(tier))),
          if (premium) _perk(context, t.perkBadge),
          if (premium) _perk(context, t.perkAvatars),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: isCurrent
                ? OutlinedButton(
                    onPressed: null, child: Text(t.currentPlanTag))
                : FilledButton(
                    onPressed: () async {
                      final uid =
                          ref.read(authStateProvider).valueOrNull?.uid;
                      if (uid == null) return;
                      await ref.read(marketServiceProvider).setTier(uid, tier);
                      if (!context.mounted) return;
                      tier == 0
                          ? _showSubscriptionEnded(context, t)
                          : _showUnlocked(context, t, tier);
                    },
                    child: Text(t.unlock),
                  ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: premium
          ? PremiumGlow(
              tier: tier, radius: DexRadii.lg, strong: isCurrent, child: card)
          : card,
    );
  }

  Widget _perk(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Icon(Icons.check_circle,
              size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ]),
      );
}

/// Popup de "desbloqueado com sucesso" com as vantagens do nível.
void _showUnlocked(BuildContext context, AppLocalizations t, int tier) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: PremiumBadge(size: 44, tier: tier),
      title: Text(t.premiumUnlocked(MarketTier.nameFor(tier)),
          textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.youUnlocked,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _unlockPerk(ctx, t.perkSlots(MarketTier.slotsFor(tier))),
          _unlockPerk(ctx, t.perkBadge),
          _unlockPerk(ctx, t.perkAvatars),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(t.continueLabel),
        ),
      ],
    ),
  );
}

/// Aviso ao voltar ao plano Grátis (subscrição não renovada / expirada).
void _showSubscriptionEnded(BuildContext context, AppLocalizations t) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.info_outline, color: Colors.orange, size: 36),
      title: Text(t.subscriptionNotRenewed, textAlign: TextAlign.center),
      content: Text(t.backToFreeBody),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(t.continueLabel),
        ),
      ],
    ),
  );
}

Widget _unlockPerk(BuildContext context, String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Icon(Icons.check_circle,
            size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ]),
    );
