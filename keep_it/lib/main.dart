import 'dart:io';

import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:window_size/window_size.dart';

import 'modules/shared_media/incoming_media_handler.dart';
import 'pages/camera_page.dart';
import 'pages/collection_editor_page.dart';
import 'pages/collection_timeline_page.dart';
import 'pages/collections_page.dart';
import 'pages/deleted_media_page.dart';
import 'pages/item_page.dart';
import 'pages/media_editor_page.dart';
import 'pages/media_wizard_page.dart';
import 'pages/move_media_page.dart';
import 'pages/pinned_media_page.dart';
import 'pages/settings_main.dart';
import 'widgets/empty_state.dart';

class KeepItApp implements AppDescriptor {
  @override
  String get title => 'Keep It';

  @override
  CLAppInitializer get appInitializer => (ref) async {
        return true;
      };

  @override
  List<CLShellRouteDescriptor> get shellRoutes => [
        CLShellRouteDescriptor(
          name: '',
          builder: (context, GoRouterState state) => const CollectionsPage(),
          iconData: MdiIcons.home,
          label: 'main',
        ),
        CLShellRouteDescriptor(
          name: 'Pinned',
          builder: (context, state) => const PinnedMediaPage(),
          iconData: MdiIcons.pin,
          label: 'Pinned',
        ),
        CLShellRouteDescriptor(
          name: 'settings',
          builder: (context, state) => const SettingsMainPage(),
          iconData: MdiIcons.cog,
          label: 'Settings',
        ),
      ];

  @override
  List<CLRouteDescriptor> get fullscreenBuilders => [
        CLRouteDescriptor(
          name: 'camera',
          builder: (context, GoRouterState state) {
            final int? collectionId;
            if (state.uri.queryParameters.keys.contains('collectionId')) {
              collectionId =
                  int.parse(state.uri.queryParameters['collectionId']!);
            } else {
              collectionId = null;
            }
            return CameraPage(collectionId: collectionId);
          },
        ),
        CLRouteDescriptor(
          name: 'mediaEditor',
          builder: (context, GoRouterState state) {
            final int? mediaId;
            if (state.uri.queryParameters.keys.contains('id')) {
              mediaId = int.parse(state.uri.queryParameters['id']!);
            } else {
              mediaId = null;
            }

            return MediaEditorPage(
              mediaId: mediaId,
            );
          },
        ),
        CLRouteDescriptor(
          name: 'item/:collectionId/:item_id',
          builder: (context, GoRouterState state) {
            final String parentIdentifier;
            if (!state.uri.queryParameters.containsKey('parentIdentifier')) {
              parentIdentifier = 'unknown';
            } else {
              parentIdentifier = state.uri.queryParameters['parentIdentifier']!;
            }

            return CollectionItemPage(
              collectionId: int.parse(state.pathParameters['collectionId']!),
              id: int.parse(state.pathParameters['item_id']!),
              parentIdentifier: parentIdentifier,
            );
          },
        ),

        CLRouteDescriptor(
          name: 'edit/:collectionId',
          builder: (context, GoRouterState state) {
            return CollectionEditorPage(
              collectionId: int.parse(state.pathParameters['collectionId']!),
            );
          },
        ),
        CLRouteDescriptor(
          name: 'move',
          builder: (context, GoRouterState state) {
            final List<int> idsToMove;
            if (!state.uri.queryParameters.containsKey('ids')) {
              idsToMove = <int>[];
            } else {
              idsToMove = state.uri.queryParameters['ids']!
                  .split(',')
                  .map(int.parse)
                  .toList();
            }
            final unhide = state.uri.queryParameters['unhide'] == 'true';

            return MoveMediaPage(
              idsToMove: idsToMove,
              unhide: unhide,
            );
          },
        ),
        CLRouteDescriptor(
          name: 'media_wizard',
          builder: (context, GoRouterState state) {
            final typeString = state.uri.queryParameters['type'];
            final UniversalMediaTypes type;
            if (typeString != null) {
              type = UniversalMediaTypes.values.asNameMap()[typeString] ??
                  UniversalMediaTypes.staleMedia;
            } else {
              type = UniversalMediaTypes.staleMedia;
            }
            return MediaWizardPage(type: type);
          },
        ),

        CLRouteDescriptor(
          name: 'deleted_media',
          builder: (context, GoRouterState state) {
            return const DeleteMediaPage();
          },
        ),

        // For Testing
        CLRouteDescriptor(
          name: 'empty_state_page',
          builder: (context, GoRouterState state) {
            return const EmptyState();
          },
        ),
        CLRouteDescriptor(
          name: 'empty_state_view',
          builder: (context, GoRouterState state) {
            return const FullscreenLayout(child: EmptyState());
          },
        ),
      ];

  @override
  List<CLRouteDescriptor> get screenBuilders => [
        CLRouteDescriptor(
          name: 'collections',
          builder: (context, GoRouterState state) => const CollectionsPage(),
        ),
        CLRouteDescriptor(
          name: 'items_by_collection/:collectionId',
          builder: (context, GoRouterState state) => CollectionTimeLinePage(
            collectionId: int.parse(state.pathParameters['collectionId']!),
          ),
        ),
      ];

  @override
  IncomingMediaViewBuilder get incomingMediaViewBuilder => (
        BuildContext context, {
        required CLSharedMedia incomingMedia,
        required void Function({required bool result}) onDiscard,
      }) =>
          IncomingMediaHandler(
            incomingMedia: incomingMedia,
            onDiscard: onDiscard,
          );

  @override
  CLTransitionBuilder get transitionBuilder => (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        const scheme = 'fade';
        switch (scheme) {
          case 'slide':
            return SlideTransition(
              position: Tween(begin: const Offset(1, 0), end: Offset.zero)
                  .animate(animation),
              child: child,
            );
          case 'scale':
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          case 'size':
            return Align(
              child: SizeTransition(
                sizeFactor: animation,
                child: child,
              ),
            );
          case 'rotation':
            return RotationTransition(
              turns: animation,
              child: child,
            );
          case 'fade':
          default:
            return FadeTransition(opacity: animation, child: child);
        }
      };

  @override
  CLRedirector get redirector => (String location) async {
        const redirectTo = '';
        if (redirectTo.isNotEmpty) {
          if (location != redirectTo) return redirectTo;
        }

        return null;
      };
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    //setWindowTitle('My App');
    setWindowFrame(const Rect.fromLTWH(0, 0, 900, 900 * 16 / 9));

    setWindowMaxSize(const Size(900, 900 * 16 / 9));
    setWindowMinSize(const Size(450, 450 * 16 / 9));
  }
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  runApp(
    ProviderScope(
      child: AppLoader(
        appDescriptor: KeepItApp(),
      ),
    ),
  );
}

void printGoRouterState(GoRouterState state) {
  _infoLogger(' state: ${state.extra} ${state.error} ${state.fullPath}'
      ' ${state.uri} ${state.name} ${state.pageKey} ${state.pathParameters} '
      '${state.uri.queryParameters} ${state.path} ${state.matchedLocation}');
}

bool _disableInfoLogger = true;
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}
