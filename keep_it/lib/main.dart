import 'dart:io';

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_size/window_size.dart';

import 'modules/shared_media/incoming_media_handler.dart';
import 'pages/camera_page.dart';
import 'pages/collection_editor_page.dart';
import 'pages/collection_timeline_page.dart';
import 'pages/collections_page.dart';
import 'pages/item_page.dart';
import 'pages/move_media_page.dart';
import 'pages/tag_timeline_page.dart';
import 'pages/tags_page.dart';
import 'widgets/Camera/camera_example.dart';

extension ExtDirectory on Directory {
  void clear() {
    if (existsSync()) {
      final contents = listSync();
      for (final content in contents) {
        if (content is File) {
          content.deleteSync();
        } else if (content is Directory) {
          content.deleteSync(recursive: true);
        }
      }
    }
  }
}

class KeepItApp implements AppDescriptor {
  @override
  String get title => 'Keep It';

  @override
  CLAppInitializer get appInitializer => (ref) async {
        // TODO(anandas): Delete only if saved preference is set to reset.
        // ignore: dead_code, literal_only_boolean_expressions
        if (false) {
          for (final dir in [
            await getApplicationDocumentsDirectory(),
            await getApplicationCacheDirectory(),
          ]) {
            dir.clear();
          }
          await FilePicker.platform.clearTemporaryFiles();
        }
        return true;
      };

  @override
  List<CLShellRouteDescriptor> get shellRoutes => [
        CLShellRouteDescriptor(
          name: '',
          builder: (context, GoRouterState state) => const CollectionsPage(),
          iconData: Icons.home,
          label: 'Collections',
        ),
        CLShellRouteDescriptor(
          name: 'tags',
          builder: (context, state) => const TagsPage(),
          iconData: Icons.search,
          label: 'Search',
        ),
        CLShellRouteDescriptor(
          name: 'settings',
          builder: (context, state) => const Center(
            child: Text('Settings'),
          ),
          iconData: Icons.settings,
          label: 'Settings',
        ),
      ];

  @override
  List<CLRouteDescriptor> get fullscreenBuilders => [
        CLRouteDescriptor(
          name: 'camera',
          builder: (context, GoRouterState state) {
            return const CameraPage();
          },
        ),
        CLRouteDescriptor(
          name: 'cameraExample',
          builder: (context, GoRouterState state) {
            return const CameraExample();
          },
        ),
        CLRouteDescriptor(
          name: 'item/:collectionId/:item_id',
          builder: (context, GoRouterState state) {
            if (!state.uri.queryParameters.containsKey('parentIdentifier')) {
              throw Exception('missing parentIdentifier');
            }
            return CollectionItemPage(
              collectionId: int.parse(state.pathParameters['collectionId']!),
              id: int.parse(state.pathParameters['item_id']!),
              parentIdentifier: state.uri.queryParameters['parentIdentifier']!,
            );
          },
        ),
        CLRouteDescriptor(
          name: 'item_by_tag/:tagId/:item_id',
          builder: (context, GoRouterState state) {
            if (!state.uri.queryParameters.containsKey('parentIdentifier')) {
              throw Exception('missing parentIdentifier');
            }
            return TagItemPage(
              tagId: int.parse(state.pathParameters['tagId']!),
              id: int.parse(state.pathParameters['item_id']!),
              parentIdentifier: state.uri.queryParameters['parentIdentifier']!,
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
            if (!state.uri.queryParameters.containsKey('ids')) {
              throw Exception('Nothing to move');
            }
            final idsToMove = state.uri.queryParameters['ids']!
                .split(',')
                .map(int.parse)
                .toList();

            return MoveMediaPage(
              idsToMove: idsToMove,
            );
          },
        ),
      ];

  @override
  List<CLRouteDescriptor> get screenBuilders => [
        CLRouteDescriptor(
          name: 'collections/:tagId',
          builder: (context, GoRouterState state) => CollectionsPage(
            tagId: int.parse(state.pathParameters['tagId']!),
          ),
        ),
        CLRouteDescriptor(
          name: 'items_by_collection/:collectionId',
          builder: (context, GoRouterState state) => CollectionTimeLinePage(
            collectionId: int.parse(state.pathParameters['collectionId']!),
          ),
        ),
        CLRouteDescriptor(
          name: 'items_by_tag/:tagId',
          builder: (context, GoRouterState state) => TagTimeLinePage(
            tagId: int.parse(state.pathParameters['tagId']!),
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
        //if (location == '/') return '/collections';
        return '/cameraExample';
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
