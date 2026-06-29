import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/dex_tokens.dart';
import '../../data/repositories/sets_repository.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/completion_ring.dart';

/// Início: "launchpad" pessoal — saudação, progresso compacto (ou CTA de
/// login), ações rápidas, "Quase lá!" e "Descobrir". O dashboard detalhado
/// vive no separador "O meu binder".
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final name = ref.watch(displayNameProvider);
    final signedIn = ref.watch(authStateProvider).valueOrNull != null;
    final setsAsync = ref.watch(setsListProvider);

    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        // Saudação.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            name.isEmpty ? t.homeGreetingGuest : t.homeGreeting(name),
            style: TextStyle(
              fontFamily: AppTheme.displayFont,
              fontWeight: FontWeight.w700,
              fontSize: 26,
              color: cs.onSurface,
            ),
          ),
        ),

        // Progresso compacto OU CTA de login (convidado).
        setsAsync.maybeWhen(
          orElse: () => const SizedBox.shrink(),
          data: (sets) {
            final mine = sets.where((s) => s.progress.owned > 0).toList();
            if (!signedIn) return _SignInCta();
            final owned = mine.fold<int>(0, (a, s) => a + s.progress.owned);
            final total = mine.fold<int>(0, (a, s) => a + s.progress.total);
            return _ProgressCard(
              owned: owned,
              total: total,
              percent: total == 0 ? 0 : owned / total,
              onOpen: () => ref.read(navIndexProvider.notifier).state = 2,
            );
          },
        ),

        // Ações rápidas.
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            children: [
              _QuickAction(
                  icon: Icons.search,
                  label: t.tabSearch,
                  onTap: () => context.push('/search')),
              const SizedBox(width: 10),
              _QuickAction(
                  icon: Icons.favorite_border,
                  label: t.wishlist,
                  onTap: () => context.push('/wishlist')),
              const SizedBox(width: 10),
              _QuickAction(
                  icon: Icons.style,
                  label: t.tabSets,
                  onTap: () => ref.read(navIndexProvider.notifier).state = 1),
            ],
          ),
        ),

        // "Quase lá!" — coleções mais perto de completar.
        setsAsync.maybeWhen(
          orElse: () => const SizedBox.shrink(),
          data: (sets) {
            final almost = sets
                .where((s) =>
                    s.progress.owned > 0 && s.progress.owned < s.progress.total)
                .toList()
              ..sort((a, b) => a.progress.missing.compareTo(b.progress.missing));
            if (almost.isEmpty) return const SizedBox.shrink();
            return _Section(
              title: t.homeAlmostThere,
              child: _HRow(
                children: almost
                    .take(6)
                    .map((s) => _AlmostCard(
                        data: s,
                        onTap: () => context.push('/set/${s.set.id}')))
                    .toList(),
              ),
            );
          },
        ),

        // "Descobrir" — coleções por começar.
        setsAsync.maybeWhen(
          orElse: () => const SizedBox.shrink(),
          data: (sets) {
            final fresh =
                sets.where((s) => s.progress.owned == 0).take(8).toList();
            if (fresh.isEmpty) return const SizedBox.shrink();
            return _Section(
              title: t.homeDiscover,
              child: _HRow(
                children: fresh
                    .map((s) => _DiscoverCard(
                        data: s,
                        onTap: () => context.push('/set/${s.set.id}')))
                    .toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ---------- Componentes ----------

class _SignInCta extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: _CardBox(
        child: Row(
          children: [
            Icon(Icons.auto_awesome, color: cs.primary, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Text(t.homeSignInCta,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => context.push('/login'),
              child: Text(t.signIn),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int owned;
  final int total;
  final double percent;
  final VoidCallback onOpen;
  const _ProgressCard(
      {required this.owned,
      required this.total,
      required this.percent,
      required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: _CardBox(
        child: Row(
          children: [
            CompletionRing(percent: percent, size: 64, stroke: 8),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$owned / $total',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  Text(t.keepCompleting,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            TextButton(onPressed: onOpen, child: Text(t.openMyBinder)),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(DexRadii.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(DexRadii.lg),
          ),
          child: Column(
            children: [
              Icon(icon, color: cs.primary),
              const SizedBox(height: 6),
              Text(label,
                  style: Theme.of(context).textTheme.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
          child: Text(title.toUpperCase(),
              style: AppTheme.mono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant)),
        ),
        child,
      ],
    );
  }
}

class _HRow extends StatelessWidget {
  final List<Widget> children;
  const _HRow({required this.children});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: children,
      ),
    );
  }
}

class _AlmostCard extends StatelessWidget {
  final SetProgress data;
  final VoidCallback onTap;
  const _AlmostCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final s = data.set;
    final p = data.progress;
    return _MiniCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Logo(logo: s.logoUrl, symbol: s.symbolUrl),
          const Spacer(),
          Text(s.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(t.homeToGo(p.missing),
              style: AppTheme.mono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: DexColors.green500)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(DexRadii.pill),
            child: LinearProgressIndicator(
              value: p.percent,
              minHeight: 5,
              color: DexColors.green500,
              backgroundColor: cs.surfaceContainerHigh,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoverCard extends StatelessWidget {
  final SetProgress data;
  final VoidCallback onTap;
  const _DiscoverCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = data.set;
    return _MiniCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Logo(logo: s.logoUrl, symbol: s.symbolUrl),
          const Spacer(),
          Text(s.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(s.series,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final String logo;
  final String symbol;
  const _Logo({required this.logo, required this.symbol});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tint = Color.alphaBlend(
        cs.primary.withValues(alpha: 0.14), cs.surfaceContainerHigh);
    final url = logo.isNotEmpty ? logo : symbol;
    return Container(
      width: double.infinity,
      height: 46,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(DexRadii.md),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: url.isEmpty
          ? Icon(Icons.style, color: cs.primary, size: 22)
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              memCacheWidth: 220,
              placeholder: (_, __) => const SizedBox.shrink(),
              errorWidget: (_, __, ___) =>
                  Icon(Icons.style, color: cs.primary, size: 22),
            ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _MiniCard({required this.child, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(DexRadii.lg),
        onTap: onTap,
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(DexRadii.lg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.35 : 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _CardBox extends StatelessWidget {
  final Widget child;
  const _CardBox({required this.child});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(DexRadii.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.35 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}
