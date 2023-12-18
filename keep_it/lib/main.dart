import 'dart:io';

import 'package:app_loader/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:window_size/window_size.dart';
import 'pages/page_show_image.dart';
import 'pages/page_collections.dart';
import 'pages/views/shared_items_view.dart';

class KeepItApp implements AppDescriptor {
  @override
  String get title => "Keep It";

  @override
  CLAppInitializer get appInitializer => (ref) async {
        //TODO: Delete only if saved preference is set to reset
        // ignore: dead_code
        if (false) {
          final appDir = await getApplicationDocumentsDirectory();
          final fullPath = path.join(appDir.path, 'keepIt.db');
          if (File(fullPath).existsSync()) {
            File(fullPath).delete();
          }
        }

        return true;
      };

  @override
  Map<String, CLWidgetBuilder> get screenBuilders {
    return {
      "home": (context) => const PageShowImage(
          imagePath: "assets/wallpaperflare.com_wallpaper-2.jpg"),
      "collections": (context) => const CollectionsPage()
    };
  }

  @override
  IncomingMediaViewBuilder get incomingMediaViewBuilder =>
      (BuildContext context, WidgetRef ref,
          {required Map<String, SupportedMediaType> sharedMedia,
          required Function() onDiscard}) {
        return SharedItemsView(
          media: sharedMedia,
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
        if (location == "/") return "/collections";
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
  return runApp(ProviderScope(
      child: AppLoader(
    appDescriptor: KeepItApp(),
  )));
}
