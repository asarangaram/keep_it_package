import 'dart:io';

import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fvp/fvp.dart' as fvp;

import 'package:window_size/window_size.dart';

import 'pages/camera_page.dart';
import 'pages/main_view_page.dart';
import 'pages/media_editor_page.dart';
import 'pages/media_pageview_page.dart';
import 'pages/media_wizard_page.dart';
import 'pages/pinned_media_page.dart';
import 'pages/server_page.dart';
import 'pages/settings_main_page.dart';

class KeepItApp implements AppDescriptor {
  @override
  String get title => 'Keep It';

  @override
  CLAppInitializer get appInitializer => (ref) async {
        return true;
      };

  @override
  List<CLRouteDescriptor> get screens => [
        CLRouteDescriptor(
          name: '',
          builder: (context, parameters) => const MainViewPage(),
        ),
        CLRouteDescriptor(
          name: 'Pinned',
          builder: (context, parameters) => const PinnedMediaPage(),
        ),
        CLRouteDescriptor(
          name: 'settings',
          builder: (context, parameters) => const SettingsMainPage(),
        ),
        CLRouteDescriptor(
          name: 'camera',
          builder: (context, parameters) {
            final int? collectionId;
            if (parameters.keys.contains('collectionId')) {
              collectionId = int.parse(parameters['collectionId']!);
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
          builder: (context, parameters) {
            final int? mediaId;
            final bool canDuplicateMedia;
            if (parameters.keys.contains('id')) {
              mediaId = int.parse(parameters['id']!);
            } else {
              mediaId = null;
            }
            if (parameters.keys.contains('canDuplicateMedia')) {
              canDuplicateMedia = parameters['canDuplicateMedia']! == '1';
            } else {
              canDuplicateMedia = false;
            }

            return FullscreenLayout(
              backgroundColor: CLTheme.of(context).colors.editorBackgroundColor,
              child: MediaEditorPage(
                mediaId: mediaId,
                canDuplicateMedia: canDuplicateMedia,
              ),
            );
          },
        ),
        CLRouteDescriptor(
          name: 'media',
          builder: (context, parameters) {
            final String parentIdentifier;
            final int? collectionId;

            if (!parameters.containsKey('parentIdentifier')) {
              parentIdentifier = 'unknown';
            } else {
              parentIdentifier = parameters['parentIdentifier']!;
            }
            if (!parameters.containsKey('collectionId')) {
              collectionId = null;
            } else {
              collectionId = int.parse(parameters['collectionId']!);
            }

            return FullscreenLayout(
              useSafeArea: false,
              child: MediaPageViewPage(
                collectionId: collectionId,
                id: int.parse(parameters['id']!),
                parentIdentifier: parentIdentifier,
              ),
            );
          },
        ),
        CLRouteDescriptor(
          name: 'media_wizard',
          builder: (context, parameters) {
            final typeString = parameters['type'];
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
        CLRouteDescriptor(
          name: 'servers',
          builder: (context, parameters) {
            return const FullscreenLayout(child: ServersPage());
          },
        ),
        CLRouteDescriptor(
          name: 'collections',
          builder: (context, parameters) => const MainViewPage(),
        ),
        /* CLRouteDescriptor(
          name: 'items_by_collection',
          builder: (context, parameters) => CollectionTimeLinePage(
            collectionId: int.parse(parameters['id']!),
          ),
        ), */
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
        //'/collections/storage_preference';
        if (redirectTo.isNotEmpty) {
          if (location != redirectTo) return redirectTo;
        }

        return null;
      };
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrintRebuildDirtyWidgets = false;
  debugPaintSizeEnabled = false;
  debugPrintBeginFrameBanner = false;
  debugPrintLayouts = false;

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    //setWindowTitle('My App');
    setWindowFrame(const Rect.fromLTWH(0, 0, 900, 900 * 16 / 9));

    setWindowMaxSize(const Size(900, 900 * 16 / 9));
    setWindowMinSize(const Size(450, 450 * 16 / 9));
  }
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  fvp.registerWith(
    options: {
      'global': {'logLevel': 'Error'},
    },
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
