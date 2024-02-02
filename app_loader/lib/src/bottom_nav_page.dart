// TODO(anandas): an we avoid this?
import 'package:app_loader/src/app_descriptor.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'incoming_progress.dart';
import 'providers/incoming_media.dart';

class StandalonePage extends ConsumerWidget {
  const StandalonePage({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CLFullscreenBox(
      child: CLBackground(child: child),
    );
  }
}

class BottomNavigationPage extends ConsumerStatefulWidget {
  const BottomNavigationPage({
    required this.child,
    required this.incomingMediaViewBuilder,
    super.key,
  });

  final StatefulNavigationShell child;
  final IncomingMediaViewBuilder incomingMediaViewBuilder;
  @override
  ConsumerState<BottomNavigationPage> createState() =>
      _BottomNavigationPageState();
}

class _BottomNavigationPageState extends ConsumerState<BottomNavigationPage> {
  @override
  Widget build(BuildContext context) {
    final incomingMedia = ref.watch(incomingMediaStreamProvider);

    if (incomingMedia.isNotEmpty) {
      return StandalonePage(
        child: IncomingProgress(
          incomingMediaViewBuilder: widget.incomingMediaViewBuilder,
          onDone: () {
            ref.read(incomingMediaStreamProvider.notifier).pop();
          },
        ),
      );
    }

    return Scaffold(
      body: CLBackground(
        child: SafeArea(
          child: widget.child,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: widget.child.currentIndex,
        onTap: (index) {
          widget.child.goBranch(
            index,
            initialLocation: index == widget.child.currentIndex,
          );
          setState(() {});
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_special_rounded),
            label: 'Collections',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'settings',
          ),
        ],
      ),
    );
  }
}
