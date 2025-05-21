import 'dart:io';

import 'package:colan_services/colan_services.dart';
import 'package:flutter/material.dart';

import 'package:fvp/fvp.dart' as fvp;

import 'package:window_size/window_size.dart';

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
          builder: (context, parameters) => const GalleryViewService(
            parentIdentifier: 'KeepIt Viewer',
            storeIdentity: 'local',
          ),
        ),
        CLRouteDescriptor(
          name: 'settings',
          builder: (context, parameters) => const SettingsService(
            storeIdentity: 'local',
          ),
        ),
        CLRouteDescriptor(
          name: 'camera',
          builder: (context, parameters) {
            final int? parentId;
            if (parameters.keys.contains('parentId')) {
              parentId = int.parse(parameters['parentId']!);
            } else {
              parentId = null;
            }
            return CLCameraService(
              parentId: parentId,
              storeIdentity: 'local',
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

            return MediaEditService(
              storeIdentity: 'local',
              mediaId: mediaId,
              canDuplicateMedia: canDuplicateMedia,
            );
          },
        ),
        CLRouteDescriptor(
          name: 'media',
          builder: (context, parameters) {
            final String parentIdentifier;
            // ignore: unused_local_variable for now
            final int? parentId;

            if (!parameters.containsKey('parentIdentifier')) {
              parentIdentifier = 'unknown';
            } else {
              parentIdentifier = parameters['parentIdentifier']!;
            }
            if (!parameters.containsKey('parentId')) {
              parentId = 0;
            } else {
              parentId = int.parse(parameters['parentId']!);
            }

            return MediaViewService(
              parentIdentifier: parentIdentifier,
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
            return MediaWizardService(
              type: type,
              storeIdentity: 'local',
            );
          },
        ),
      ];

  @override
  IncomingMediaViewBuilder get incomingMediaViewBuilder => (
        BuildContext context, {
        required CLMediaFileGroup incomingMedia,
        required void Function({required bool result}) onDiscard,
      }) =>
          IncomingMediaService(
            storeIdentity: 'local',
            parentIdentifier: 'IncomingMediaService',
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
    setWindowFrame(const Rect.fromLTWH(0, 0, 900, 900 * 16 / 9));

    setWindowMaxSize(const Size(900, 900 * 16 / 9));
    setWindowMinSize(const Size(450, 450 * 16 / 9));
  }
  /* SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  ); */
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  fvp.registerWith(
    options: {
      'global': {'logLevel': 'Error'},
    },
  );
  runApp(AppStartService(appDescriptor: KeepItApp()));
}
