// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MediaFilter extends ConsumerStatefulWidget {
  const MediaFilter({super.key});

  static void showFilter(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container();
      },
    );
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => MediaFilterState();
}

class MediaFilterState extends ConsumerState<MediaFilter> {
  @override
  Widget build(BuildContext context) {
    final filterMenu = ref.watch(filterMenuProvider);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: filterMenu.showMenu
          ? const DraggableScrollableSheetExample()
          : const IgnorePointer(),
    );
  }
}

class DraggableScrollableSheetExample extends StatefulWidget {
  const DraggableScrollableSheetExample({super.key});

  @override
  State<DraggableScrollableSheetExample> createState() =>
      _DraggableScrollableSheetExampleState();
}

class _DraggableScrollableSheetExampleState
    extends State<DraggableScrollableSheetExample> {
  double _sheetPosition = 0.1;
  final double _dragSensitivity = 600;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: _sheetPosition,
      minChildSize: 0.1,
      maxChildSize: 0.8,
      builder: (BuildContext context, ScrollController scrollController) {
        return ColoredBox(
          color: colorScheme.primary,
          child: Column(
            children: <Widget>[
              Grabber(
                onVerticalDragUpdate: (DragUpdateDetails details) {
                  setState(() {
                    _sheetPosition -= details.delta.dy / _dragSensitivity;
                    if (_sheetPosition < 0.1) {
                      _sheetPosition = 0.1;
                    }
                    if (_sheetPosition > 0.8) {
                      _sheetPosition = 0.8;
                    }
                  });
                },
                isOnDesktopAndWeb: _isOnDesktopAndWeb,
              ),
              Flexible(
                child: ListView.builder(
                  controller: _isOnDesktopAndWeb ? null : scrollController,
                  itemCount: 25,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(
                        'Item $index',
                        style: TextStyle(color: colorScheme.surface),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool get _isOnDesktopAndWeb {
    if (kIsWeb) {
      return true;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return true;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return false;
    }
  }
}

/// A draggable widget that accepts vertical drag gestures
/// and this is only visible on desktop and web platforms.
class Grabber extends StatelessWidget {
  const Grabber({
    required this.onVerticalDragUpdate,
    required this.isOnDesktopAndWeb,
    super.key,
  });

  final ValueChanged<DragUpdateDetails> onVerticalDragUpdate;
  final bool isOnDesktopAndWeb;

  @override
  Widget build(BuildContext context) {
    if (!isOnDesktopAndWeb) {
      return const SizedBox.shrink();
    }
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onVerticalDragUpdate: onVerticalDragUpdate,
      child: Container(
        width: double.infinity,
        color: colorScheme.onSurface,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}

class FilterMenuButton extends ConsumerWidget {
  const FilterMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}

@immutable
class FilterMenu {
  const FilterMenu({this.showMenu = false});
  final bool showMenu;

  FilterMenu copyWith({
    bool? showMenu,
  }) {
    return FilterMenu(
      showMenu: showMenu ?? this.showMenu,
    );
  }

  @override
  bool operator ==(covariant FilterMenu other) {
    if (identical(this, other)) return true;

    return other.showMenu == showMenu;
  }

  @override
  int get hashCode => showMenu.hashCode;

  @override
  String toString() => 'FilterMenu(showMenu: $showMenu)';
}

class FilterMenuNotifier extends StateNotifier<FilterMenu> {
  FilterMenuNotifier() : super(const FilterMenu());
}

final filterMenuProvider =
    StateNotifierProvider<FilterMenuNotifier, FilterMenu>((ref) {
  return FilterMenuNotifier();
});
