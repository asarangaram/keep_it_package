import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart';

class KeepItTopBar extends ConsumerWidget {
  const KeepItTopBar({required this.parentIdentifier, super.key});
  final String parentIdentifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionId = ref.watch(activeCollectionProvider);
    final identifier = ref.watch(mainPageIdentifierProvider);
    return GetCollection(
      id: collectionId,
      loadingBuilder: () => CLLoader.hide(
        debugMessage: 'GetCollection',
      ),
      errorBuilder: (p0, p1) => const SizedBox.shrink(),
      builder: (collection) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!ColanPlatformSupport.isMobilePlatform)
              const SizedBox(
                height: 8,
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (collectionId != null)
                  CLButtonIcon.small(
                    clIcons.pagePop,
                    onTap: () {
                      ref.read(selectModeProvider(identifier).notifier).state =
                          false;
                      ref.read(activeCollectionProvider.notifier).state = null;
                    },
                  ),
                Flexible(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        collection?.label.capitalizeFirstLetter() ??
                            'Collection',
                        style: Theme.of(context).textTheme.headlineLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                PopOverMenu(
                  parentIdentifier: parentIdentifier,
                ),
                const ExtraActions(),
                const SizedBox(width: 8),
              ],
            ),
            TextFilterBox(
              parentIdentifier: parentIdentifier,
            ),
          ],
        );
      },
    );
  }
}

class ExtraActions extends ConsumerWidget {
  const ExtraActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final method = ref.watch(groupMethodProvider);

    final collectionId = ref.watch(activeCollectionProvider);
    final identifier = ref.watch(mainPageIdentifierProvider);

    final selectionMode = ref.watch(selectModeProvider(identifier));

    final popupActionItems = [
      if (collectionId != null) ...[
        PopupMenuEntryBuilder(
          titleBuilder: (context, ref) => const Text('Group By Date'),
          iconBuilder: (context, ref) => switch (method) {
            GroupTypes.byOriginalDate => const Icon(Icons.check),
            _ => null
          },
          onTap: () {
            final updatedMethod = switch (method) {
              GroupTypes.byOriginalDate => GroupTypes.none,
              GroupTypes.none => GroupTypes.byOriginalDate,
            };
            ref.read(groupMethodProvider.notifier).state = updatedMethod;
          },
        ),
        PopupMenuEntryBuilder(
          titleBuilder: (context, ref) => const Text('Select'),
          iconBuilder: (context, ref) => switch (selectionMode) {
            true => const Icon(Icons.check),
            false => null
          },
          onTap: () {
            ref.watch(selectModeProvider(identifier).notifier).state =
                !selectionMode;
          },
        ),
      ],
      PopupMenuEntryBuilder(
        titleBuilder: (context, ref) => const Text('Settings'),
        iconBuilder: (context, ref) => Icon(clIcons.navigateSettings),
        onTap: () {
          PageManager.of(context).openSettings();
        },
      ),
    ];
    return PopupMenuButton<PopupMenuEntryBuilder>(
      onSelected: (PopupMenuEntryBuilder item) {
        item.onTap.call();
      },
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<PopupMenuEntryBuilder>>[
          for (final item in popupActionItems) ...[
            PopupMenuItem<PopupMenuEntryBuilder>(
              value: item,
              child: ListTile(
                leading:
                    item.iconBuilder(context, ref) ?? const SizedBox.shrink(),
                title: item.titleBuilder(context, ref),
              ),
            ),
          ],
        ];
      },
      child: const Icon(
        Icons.more_vert,
        size: 25,
      ),
    );
  }
}

class PopupMenuEntryBuilder {
  PopupMenuEntryBuilder({
    required this.titleBuilder,
    required this.iconBuilder,
    required this.onTap,
  });
  Widget? Function(BuildContext context, WidgetRef ref) titleBuilder;
  Widget? Function(BuildContext context, WidgetRef ref) iconBuilder;
  void Function() onTap;
}
