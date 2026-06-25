import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/auth_guard.dart';
import '../widgets/listing_tile.dart';
import 'my_cards_screen.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});
  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeDisclaimer());
  }

  Future<void> _maybeDisclaimer() async {
    if (ref.read(communityDisclaimerSeenProvider)) return;
    final t = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(t.communityDisclaimerTitle),
        content: Text(t.communityDisclaimerBody),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.communityDisclaimerOk),
          ),
        ],
      ),
    );
    await ref.read(prefsProvider).setBool('communityDisclaimerSeen', true);
    ref.read(communityDisclaimerSeenProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final recent = ref.watch(recentListingsProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(t.sellOrTrade),
        onPressed: () {
          if (!requireSignIn(context, ref)) return;
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const MyCardsScreen(startDuplicates: true)));
        },
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            readOnly: true,
            onTap: () => context.push('/search'),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: t.searchCardHint,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextButton.icon(
              icon: const Icon(Icons.sell),
              label: Text(t.myListings),
              onPressed: () {
                if (!requireSignIn(context, ref)) return;
                context.push('/my-listings');
              },
            ),
          ),
        ),
        Expanded(
          child: recent.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (list) => list.isEmpty
                ? Center(child: Text(t.noListings))
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) => ListingTile(
                      listing: list[i],
                      onTap: () => context.push('/listing/${list[i].id}',
                          extra: list[i]),
                    ),
                  ),
          ),
        ),
      ]),
    );
  }
}
