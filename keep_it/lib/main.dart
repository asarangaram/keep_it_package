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

import 'pages/camera_page.dart';
import 'pages/collection_timeline_page.dart';
import 'pages/collections_page.dart';
import 'pages/media_editor_page.dart';
import 'pages/media_pageview_page.dart';
import 'pages/media_wizard_page.dart';
import 'pages/pinned_media_page.dart';
import 'pages/settings_main_page.dart';

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
            return FullscreenLayout(
              useSafeArea: false,
              child: CameraPage(collectionId: collectionId),
            );
          },
        ),
        CLRouteDescriptor(
          name: 'mediaEditor',
          builder: (context, GoRouterState state) {
            final int? mediaId;
            final bool canDuplicateMedia;
            if (state.uri.queryParameters.keys.contains('id')) {
              mediaId = int.parse(state.uri.queryParameters['id']!);
            } else {
              mediaId = null;
            }
            if (state.uri.queryParameters.keys.contains('canDuplicateMedia')) {
              canDuplicateMedia =
                  state.uri.queryParameters['canDuplicateMedia']! == '1';
            } else {
              canDuplicateMedia = false;
            }

            return FullscreenLayout(
              hasBackground: false,
              backgroundColor: CLTheme.of(context).colors.editorBackgroundColor,
              child: MediaEditorPage(
                mediaId: mediaId,
                canDuplicateMedia: canDuplicateMedia,
              ),
            );
          },
        ),
        CLRouteDescriptor(
          name: 'media/:item_id',
          builder: (context, GoRouterState state) {
            final String parentIdentifier;
            final int? collectionId;
            final String? actionControlJson;
            if (!state.uri.queryParameters.containsKey('parentIdentifier')) {
              parentIdentifier = 'unknown';
            } else {
              parentIdentifier = state.uri.queryParameters['parentIdentifier']!;
            }
            if (!state.uri.queryParameters.containsKey('collectionId')) {
              collectionId = null;
            } else {
              collectionId =
                  int.parse(state.uri.queryParameters['collectionId']!);
            }
            if (!state.uri.queryParameters.containsKey('actionControl')) {
              actionControlJson = null;
            } else {
              actionControlJson = state.uri.queryParameters['actionControl'];
            }

            final actionControl = actionControlJson != null
                ? ActionControl.fromJson(actionControlJson)
                : ActionControl.none();

            return FullscreenLayout(
              useSafeArea: false,
              child: MediaPageViewPage(
                collectionId: collectionId,
                id: int.parse(state.pathParameters['item_id']!),
                parentIdentifier: parentIdentifier,
                actionControl: actionControl,
              ),
            );
          },
        ),

        CLRouteDescriptor(
          name: 'media_wizard',
          builder: (context, GoRouterState state) {
            final typeString = state.uri.queryParameters['type'];
            final UniversalMediaSource type;
            if (typeString != null) {
              type = UniversalMediaSource.values.asNameMap()[typeString] ??
                  UniversalMediaSource.unclassified;
            } else {
              type = UniversalMediaSource.unclassified;
            }
            return FullscreenLayout(
              child: MediaWizardPage(type: type),
            );
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
            actionControl: ActionControl.full(),
          ),
        ),
      ];

  @override
  IncomingMediaViewBuilder get incomingMediaViewBuilder => (
        BuildContext context, {
        required CLMediaFileGroup incomingMedia,
        required void Function({required bool result}) onDiscard,
      }) =>
          FullscreenLayout(
            child: IncomingMediaService(
              parentIdentifier: 'IncomingMediaService',
              incomingMedia: incomingMedia,
              onDiscard: onDiscard,
            ),
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

/* void printGoRouterState(GoRouterState state) {
  _infoLogger(' state: ${state.extra} ${state.error} ${state.fullPath}'
      ' ${state.uri} ${state.name} ${state.pageKey} ${state.pathParameters} '
      '${state.uri.queryParameters} ${state.path} ${state.matchedLocation}');
}

bool _disableInfoLogger = true;
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
} */
