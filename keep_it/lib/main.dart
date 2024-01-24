import 'dart:io';

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keep_it/pages/page_items.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:window_size/window_size.dart';

import 'pages/page_clusters.dart';
import 'pages/page_collections.dart';
import 'pages/page_show_image.dart';
import 'widgets/app_theme.dart';
import 'views/shared_items_view.dart';

class KeepItApp implements AppDescriptor {
  @override
  String get title => 'Keep It';

  @override
  CLAppInitializer get appInitializer => (ref) async {
        // TODO(asarangaram): Delete only if saved preference is set to reset.

        // ignore: dead_code, literal_only_boolean_expressions
        if (false) {
          final appDir = await getApplicationDocumentsDirectory();
          final fullPath = path.join(appDir.path, 'keepIt.db');
          if (File(fullPath).existsSync()) {
            await File(fullPath).delete();
          }
        }

        return true;
      };

  @override
  Map<String, CLWidgetBuilder> get screenBuilders {
    return {
      'home': (context, state) => const PageShowImage(
            imagePath: 'assets/wallpaperflare.com_wallpaper-2.jpg',
          ),
      'collections': (context, state) =>
          const AppTheme(child: CollectionsPage()),
      'demo': (context, state) => const DemoMain(),
      'clusters': (context, GoRouterState state) =>
          const ClustersPage(collectionId: null),
      'clusters/by_collection_id/:id': (context, GoRouterState state) =>
          ClustersPage(collectionId: int.parse(state.pathParameters['id']!)),
      'items/by_cluster_id/:id': (context, GoRouterState state) =>
          ItemsPage(clusterID: int.parse(state.pathParameters['id']!)),
    };
  }

  @override
  IncomingMediaViewBuilder get incomingMediaViewBuilder => (
        BuildContext context,
        WidgetRef ref, {
        required AsyncValue<CLMediaInfoGroup> mediaAsync,
        required void Function(CLMediaInfoGroup media) onDiscard,
      }) {
        return SharedItemsView(
          mediaAsync: mediaAsync,
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
        return SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: Offset.zero)
              .animate(animation),
          child: child,
        );
      };

  @override
  CLRedirector get redirector => (String location) async {
        if (location == '/') return '/collections';
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
  return runApp(
    ProviderScope(
      child: AppLoader(
        appDescriptor: KeepItApp(),
      ),
    ),
  );
}
