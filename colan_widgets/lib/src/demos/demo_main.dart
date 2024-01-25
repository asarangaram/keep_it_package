import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cl_buttons_grid_demo.dart';

Map<String, Widget Function(BuildContext context)> demos = {
  'EmptyViewtag': (BuildContext context) {
    return const CLButtonsGridDemo();
  },
};

class DemoMain extends ConsumerStatefulWidget {
  const DemoMain({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => DemoMainState();
}

class DemoMainState extends ConsumerState<DemoMain> {
  late String demoID;

  late Widget currWidget;
  late Widget currDialog;
  int currentIndex = 0;
  @override
  void initState() {
    demoID = demos.keys.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    currWidget = demos[demoID]!.call(context);
    currDialog = TestButton(
      dialog: CLDialogWrapper(
        onCancel: () {
          Navigator.of(context).pop();
        },
        child: demos[demoID]!.call(context),
      ),
    );
    return CLFullscreenBox.navBar(
      key: ValueKey('$demoID $currentIndex'),
      useSafeArea: true,
      currentIndex: currentIndex,
      onPageChange: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      navMap: {
        const BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: 'Demo List',
        ): Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              const Center(child: CLText.veryLarge('Demos')),
              Expanded(
                child: ListView(
                  children: demos.keys
                      .map(
                        (e) => ListTile(
                          shape: const ContinuousRectangleBorder(
                            side: BorderSide(),
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          title: CLText.large(e),
                          onTap: () {
                            setState(() {
                              demoID = e;
                              currentIndex = 1;
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.widgets),
          label: 'Widget',
        ): currWidget,
        const BottomNavigationBarItem(
          icon: Icon(Icons.open_in_new),
          label: 'Dialog',
        ): currDialog,
      },
    );
  }
}

class TestButton extends ConsumerWidget {
  const TestButton({required this.dialog, super.key});
  final Widget dialog;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: CLButtonElevatedText.large(
        'show Dialog',
        boxDecoration: const BoxDecoration(),
        onTap: () => showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return dialog;
          },
        ),
      ),
    );
  }
}

/*
tagListViewDialog.fromDBSelectable(
              clusterID: null,
              onSelectionDone: (l) {
                debugPrint(l.map((e) => e.label).join(","));
                Navigator.of(context).pop();
              },
              onSelectionCancel: () {
                debugPrint("dialog cancelled");
                Navigator.of(context).pop();
              },
            )
*/
