import 'dart:io';

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:window_size/window_size.dart';

import 'views/collections_view.dart';

import 'views/item_view.dart';
import 'views/items_view.dart';
import 'views/shared_items_view.dart';
import 'views/tags_view.dart';
import 'widgets/app_theme.dart';

class KeepItApp implements AppDescriptor {
  @override
  String get title => 'Keep It';

  @override
  CLAppInitializer get appInitializer => (ref) async {
        // TODO(anandas): Delete only if saved preference is set to reset.

        // ignore: dead_code, literal_only_boolean_expressions
        if (false) {
          final appDir = await getApplicationDocumentsDirectory();
          final fullPath = path.join(appDir.path, 'keepIt.db');
          if (File(fullPath).existsSync()) {
            await File(fullPath).delete();
          }
          for (final dir in ['keep_it', 'Incoming']) {
            final folder = path.join(appDir.path, dir);
            if (Directory(folder).existsSync()) {
              Directory(folder).deleteSync(recursive: true);
            }
          }
        }

        return true;
      };

  @override
  Map<String, CLWidgetBuilder> get shellRoutes {
    return {
      '': (context, GoRouterState state) => const CollectionsView(),

      //'home': (context, state) => const AppTheme(child: HomeView()),
      'tags': (context, state) => const AppTheme(child: TagsView()),
      'settings': (context, state) => const AppTheme(
            child: Center(
              child: Text('Settings'),
            ),
          ),
    };
  }

  @override
  Map<String, CLWidgetBuilder> get screenBuilders {
    return {
      'collections/:tag_id': (context, GoRouterState state) =>
          CollectionsView(tagId: int.parse(state.pathParameters['tag_id']!)),
      'items/:collection_id': (context, GoRouterState state) => ItemsView(
            collectionID: int.parse(state.pathParameters['collection_id']!),
          ),
      'item/:collection_id/:item_id': (context, GoRouterState state) =>
          ItemViewByID(
            collectionId: int.parse(state.pathParameters['collection_id']!),
            id: int.parse(state.pathParameters['item_id']!),
          ),
    };
  }

  @override
  IncomingMediaViewBuilder get incomingMediaViewBuilder => (
        BuildContext context,
        WidgetRef ref, {
        required CLMediaInfoGroup media,
        required void Function(CLMediaInfoGroup media) onDiscard,
      }) {
        return SharedItemsView(
          media: media,
          onDiscard: onDiscard,
        );
      };

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
