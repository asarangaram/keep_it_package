import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/views/tags_view.dart';

import 'collections_view.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  int currentIndex = 1;
  @override
  Widget build(BuildContext context) {
    return CLFullscreenBox.navBar(
      navMap: const {
        BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: 'Tags',
        ): TagsView(),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: 'Collections',
        ): CollectionsView(tagId: null),
      },
      currentIndex: currentIndex,
      onPageChange: (int val) {
        setState(() {
          currentIndex = val;
        });
      },
    );
  }
}
