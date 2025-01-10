import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../navigation/providers/active_collection.dart';

class WhenEmpty extends ConsumerWidget {
  const WhenEmpty({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionId = ref.watch(activeCollectionProvider);
    return EmptyState(
      menuItems: [
        if (collectionId != null)
          CLMenuItem(
            title: 'Reset',
            icon: clIcons.navigateHome,
            onTap: () async {
              ref.read(activeCollectionProvider.notifier).state = null;
              return true;
            },
          ),
        // add takeonline icon here if not online
      ],
      message: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CLText.large('Empty'),
            /* if (!isAllAvailable)  */ ...[
              SizedBox(
                height: 32,
              ),
              CLText.standard(
                'Go Online to view collections '
                'in the server',
                color: Colors.grey,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
