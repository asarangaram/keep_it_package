import 'dart:async';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';

import '../models/cl_route_descriptor.dart';
import 'app_theme.dart';

import 'validate_layout.dart';

class BottomNavigationPage extends ConsumerStatefulWidget {
  const BottomNavigationPage({
    required this.child,
    required this.routes,
    required this.onMedia,
    super.key,
  });

  final StatefulNavigationShell child;
  final List<CLShellRouteDescriptor> routes;
  final Widget Function(
    BuildContext context, {
    required CLMediaFileGroup incomingMedia,
    required void Function({required bool result}) onDiscard,
  }) onMedia;

  @override
  ConsumerState<BottomNavigationPage> createState() =>
      _BottomNavigationPageState();
}

class _BottomNavigationPageState extends ConsumerState<BottomNavigationPage> {
  bool showFAB = false;
  bool speeDialOpen = false;
  Timer? timer;
  void updateFAB(int nextScreen) {
    timer?.cancel();
    print('Current page is ${widget.child.currentIndex}');
    if (1 == nextScreen) {
      timer = Timer(const Duration(seconds: 1), () {
        print('timer expired');
        setState(() {
          showFAB = true;
          speeDialOpen = false;
        });
      });
    } else {
      setState(() {
        showFAB = false;
      });
    }
  }

  @override
  void initState() {
    updateFAB(widget.child.currentIndex);
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('showFAB = $showFAB');
    final fab = SpeedDial(
      isOpenOnStart: speeDialOpen,
      animationDuration: const Duration(milliseconds: 100),
      overlayOpacity: 0,
      elevation: 0,
      //buttonSize: const Size(60, 60),
      childrenButtonSize: const Size(160, 80),
      backgroundColor: const Color.fromARGB(255, 0xFF, 0xD7, 0),
      children: [
        SpeedDialChild(
          child: const ListTile(
            title: Text('Camera'),
            leading: Icon(Icons.add_a_photo),
          ),
        ),
        SpeedDialChild(
          child: const ListTile(
            title: Text('Gallery'),
            leading: Icon(Icons.add_photo_alternate),
          ),
        ),
      ],
      child: const CLIcon.tiny(Icons.add),
    );
    return AppTheme(
      child: IncomingMediaMonitor(
        onMedia: widget.onMedia,
        child: ValidateLayout(
          validLayout: true,
          child: CLFullscreenBox(
            useSafeArea: true,
            /* bottomSheet: BottomSheet(
              shape: const RoundedRectangleBorder(),
              backgroundColor: Theme.of(context).colorScheme.surfaceTint,
              onClosing: () {},
              builder: (context) => const ServerControl(),
            ), */
            // floatingActionButton: showFAB ? fab : null,
            bottomNavigationBar: BottomAppBar(
              //color: Theme.of(context).colorScheme.surface,
              color: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,

              shape: const CircularNotchedRectangle(),
              padding: EdgeInsets.zero,
              elevation: 0,
              height: 60,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: SizedBox.square(
                      dimension: 40,
                      child: Image.asset(
                        'assets/icon/cloud_on_lan_128px_color.png',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox.square(
                          dimension: 40,
                          child: CLButtonIconLabelled.tiny(
                            widget.routes[0].iconData,
                            widget.routes[0].label ?? '',
                            onTap: () {
                              widget.child.goBranch(
                                0,
                                initialLocation: 0 == widget.child.currentIndex,
                              );
                              updateFAB(0);
                            },
                            color: 0 == widget.child.currentIndex
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                        ),
                        if (showFAB)
                          SizedBox.square(
                            child: fab,
                          ) //SizedBox.square(child: Container())
                        else
                          SizedBox.square(
                            child: GestureDetector(
                              onDoubleTap: () {
                                widget.child.goBranch(
                                  1,
                                  initialLocation:
                                      1 == widget.child.currentIndex,
                                );
                                setState(() {
                                  speeDialOpen = true;
                                  showFAB = true;
                                });
                              },
                              child: CLButtonIconLabelled.tiny(
                                widget.routes[1].iconData,
                                widget.routes[1].label ?? '',
                                onTap: () {
                                  widget.child.goBranch(
                                    1,
                                    initialLocation:
                                        1 == widget.child.currentIndex,
                                  );
                                  updateFAB(1);
                                },
                                color: 1 == widget.child.currentIndex
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                            ),
                          ),
                        SizedBox.square(
                          child: CLButtonIconLabelled.tiny(
                            widget.routes[2].iconData,
                            widget.routes[2].label ?? '',
                            onTap: () {
                              widget.child.goBranch(
                                2,
                                initialLocation: 2 == widget.child.currentIndex,
                              );
                              updateFAB(2);
                            },
                            color: 2 == widget.child.currentIndex
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                        ),
                      ],
                    ),
                    /* BottomNavigationBar(
                      useLegacyColorScheme: false,
                      type: BottomNavigationBarType.fixed,
                      /* backgroundColor:
                          Theme.of(context).colorScheme.surfaceTint,
                      selectedItemColor: Theme.of(context).colorScheme.surface,
                      unselectedItemColor:
                          Theme.of(context).colorScheme.onSurface, */
                      currentIndex: widget.child.currentIndex,
                      onTap: (index) {
                        if (index != widget.child.currentIndex) {
                          widget.child.goBranch(
                            index,
                            initialLocation: index == widget.child.currentIndex,
                          );
                          setState(() {});
                        }
                      },
                      elevation: 0,
                      iconSize: 20,
                      items: [
                        BottomNavigationBarItem(
                          icon: Icon(widget.routes[0].iconData),
                          label: widget.routes[0].label,
                        ),
                        if (widget.child.currentIndex != 1)
                          BottomNavigationBarItem(
                            icon: Icon(widget.routes[1].iconData),
                            label: widget.routes[1].label,
                          )
                        else
                          BottomNavigationBarItem(icon: Icons.),
                        BottomNavigationBarItem(
                          icon: Icon(widget.routes[2].iconData),
                          label: widget.routes[2].label,
                        ),
                      ],
                    ), */
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: SizedBox.square(
                      dimension: 40,
                    ),
                  ),
                ],
              ),
              /* useLegacyColorScheme: false,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Theme.of(context).colorScheme.surfaceTint,
              selectedItemColor: Theme.of(context).colorScheme.surface,
              unselectedItemColor: Theme.of(context).colorScheme.onSurface,
              currentIndex: widget.child.currentIndex,
              onTap: (index) {
                widget.child.goBranch(
                  index,
                  initialLocation: index == widget.child.currentIndex,
                );
                setState(() {});
              },
              items: [
                ...widget.routes.map((e) {
                  return BottomNavigationBarItem(
                    icon: Icon(e.iconData),
                    label: e.label,
                  );
                }),
              ], */
            ),
            child: NotificationService(
              child: CLPopScreen.onSwipe(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(child: widget.child),
                    const StaleMediaIndicator(),
                    // const ServerControl(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
