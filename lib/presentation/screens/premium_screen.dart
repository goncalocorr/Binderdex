import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/dex_tokens.dart';
import '../../domain/entities/market_tier.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';

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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(DexRadii.lg),
        border: Border.all(
          color: isCurrent ? DexColors.gold500 : cs.outlineVariant,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            if (premium)
              const Icon(Icons.workspace_premium,
                  size: 20, color: DexColors.gold500),
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
                    onPressed: () {
                      final uid =
                          ref.read(authStateProvider).valueOrNull?.uid;
                      if (uid != null) {
                        ref.read(marketServiceProvider).setTier(uid, tier);
                      }
                    },
                    child: Text(t.unlock),
                  ),
          ),
        ],
      ),
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
