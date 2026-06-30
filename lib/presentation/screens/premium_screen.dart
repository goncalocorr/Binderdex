import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../../core/theme/dex_tokens.dart';
import '../../data/remote/billing_ids.dart';
import '../../domain/entities/market_tier.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/premium_badge.dart';

// ─── Provider local: carrega os offers da Play ───────────────────────────────

final _offersProvider = FutureProvider<List<ProductDetails>>((ref) async {
  final billing = ref.read(billingServiceProvider);
  final available = await billing.isAvailable();
  if (!available) return const [];
  return billing.loadOffers();
});

// ─── Helper: extrai o basePlanId de um GooglePlayProductDetails ───────────────

String? _basePlanIdOf(ProductDetails pd) {
  if (pd is GooglePlayProductDetails && pd.subscriptionIndex != null) {
    final subs = pd.productDetails.subscriptionOfferDetails;
    if (subs != null && pd.subscriptionIndex! < subs.length) {
      return subs[pd.subscriptionIndex!].basePlanId;
    }
  }
  return null;
}

/// Ecrã de subscrição premium. Mostra os níveis com preços da Play e compra
/// via Play Billing. O desbloqueio chega pelo listener global (Task 12) +
/// `marketTierProvider` (stream do Firestore).
class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final current = ref.watch(marketTierProvider).valueOrNull ?? 0;
    final offersAsync = ref.watch(_offersProvider);
    final offers = offersAsync.valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(title: Text(t.premium)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(t.premiumYourPlan(MarketTier.nameFor(current)),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          for (var i = 0; i < MarketTier.slots.length; i++)
            _TierCard(tier: i, current: current, offers: offers),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () => ref.read(billingServiceProvider).restore(),
              icon: const Icon(Icons.restore),
              label: Text(t.restorePurchases),
            ),
          ),
        ],
      ),
    );
  }
}

class _TierCard extends ConsumerWidget {
  final int tier;
  final int current;
  final List<ProductDetails> offers;

  const _TierCard({
    required this.tier,
    required this.current,
    required this.offers,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final isCurrent = tier == current;
    final premium = MarketTier.isPremium(tier);

    // Para planos pagos, tenta encontrar o offer correspondente.
    ProductDetails? matchedOffer;
    if (premium) {
      final wantedBasePlan = basePlanForTier(tier);
      if (wantedBasePlan != null) {
        for (final o in offers) {
          if (_basePlanIdOf(o) == wantedBasePlan) {
            matchedOffer = o;
            break;
          }
        }
      }
    }

    // Preço: da Play se disponível; fallback ao valor hardcoded.
    final priceLabel =
        matchedOffer?.price ?? MarketTier.priceFor(tier);
    // O billing está disponível se obtivemos pelo menos um offer
    // OU se este tier é gratuito (não precisa de billing).
    final billingAvailable = !premium || matchedOffer != null;

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
              Text('$priceLabel${t.perMonth}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 10),
          _perk(context, t.perkSlots(MarketTier.slotsFor(tier))),
          if (premium) _perk(context, _tradeMatchesPerk(t, tier)),
          if (premium) _perk(context, t.perkBadge),
          if (premium) _perk(context, t.perkAvatars),
          if (premium && !billingAvailable)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'indisponível',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: cs.outline),
              ),
            ),
          // Plano atual → etiqueta. Plano pago não-atual → comprar.
          // Grátis não-atual (utilizador é premium) → sem botão: para cancelar
          // usa-se a Play e o downgrade chega via RTDN.
          if (isCurrent) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                  onPressed: null, child: Text(t.currentPlanTag)),
            ),
          ] else if (premium) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: billingAvailable
                    ? () {
                        if (matchedOffer != null) {
                          ref.read(billingServiceProvider).buy(matchedOffer);
                        }
                      }
                    : null,
                child: Text(t.unlock),
              ),
            ),
          ],
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

/// Texto do perk "trocas perfeitas" para um nível (número ou ilimitado).
String _tradeMatchesPerk(AppLocalizations t, int tier) {
  final n = MarketTier.tradeMatchViewsFor(tier);
  return n < 0 ? t.perkTradeMatchesUnlimited : t.perkTradeMatchesCount(n);
}
