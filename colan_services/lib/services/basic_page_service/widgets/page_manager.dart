import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:store/store.dart';

import '../../camera_service/cl_camera_service.dart';
import '../../camera_service/models/default_theme.dart';

abstract class NavigatorAPI {
  void home(BuildContext context);
  void pop<T extends Object?>(BuildContext context, [T? result]);
  bool canPop(BuildContext context);
  void closeDialog<T extends Object?>(BuildContext context, [T? result]);
  Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName,
  );
}

class NavigatorAPIImpl extends Navigator implements NavigatorAPI {
  const NavigatorAPIImpl({super.key});

  @override
  void home(BuildContext context) {
    Navigator.of(context).popUntil(ModalRoute.withName('/'));
  }

  @override
  void pop<T extends Object?>(BuildContext context, [T? result]) {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.of(context).pop(result);
    }
  }

  @override
  bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }

  @override
  void closeDialog<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.of(context).pop(result);
  }

  @override
  Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName,
  ) async {
    return Navigator.pushNamed(context, routeName);
  }
}

class PageManager {
  const PageManager(
    this.context, {
    this.navigator = const NavigatorAPIImpl(),
  });
  factory PageManager.of(BuildContext context) {
    return PageManager(context);
  }
  final NavigatorAPI navigator;
  final BuildContext context;

  void home() {
    navigator.home(context);
  }

  void pop<T extends Object?>([T? result]) {
    if (context.mounted && navigator.canPop(context)) {
      navigator.pop(context, result);
    }
  }

  bool canPop() {
    return navigator.canPop(context);
  }

  void closeDialog<T extends Object?>([T? result]) {
    navigator.pop(context, result);
  }

  Future<T?> pushNamed<T extends Object?>(
    String routeName,
  ) async {
    return navigator.pushNamed(context, routeName);
  }

  Future<bool?> openCamera({
    int? collectionId,
  }) async {
    await CLCameraService0.invokeWithSufficientPermission(
      context,
      () async {
        if (context.mounted) {
          await navigator.pushNamed(
            context,
            collectionId == null
                ? '/camera'
                : '/camera?collectionId=$collectionId',
          );
        }
      },
      themeData: DefaultCLCameraIcons(),
    );
    return null;
  }

  Future<CLMedia?> openEditor(
    CLMedia media, {
    bool canDuplicateMedia = true,
  }) async {
    if (media.pin != null) {
      // FIXME Disabling notification
      /* await ref.read(notificationMessageProvider.notifier).push(
            "Unpin to edit.\n Pinned items can't be edited",
          ); */
      return media;
    } else {
      final edittedMedia = await navigator.pushNamed(
        context,
        '/mediaEditor?id=${media.id}&canDuplicateMedia=${canDuplicateMedia ? '1' : '0'}',
      );
      if (edittedMedia is CLMedia?) {
        return edittedMedia ?? media;
      } else {
        throw Exception(UnsupportedError);
      }
    }
  }

  Future<Collection?> openCollection(
    int collectionId,
  ) async {
    await navigator.pushNamed(
      context,
      '/items_by_collection?id=$collectionId',
    );
    return null;
  }

  Future<CLMedia?> openMedia(
    int mediaId, {
    required String parentIdentifier,
    int? collectionId,
  }) async {
    final queryMap = [
      'parentIdentifier="$parentIdentifier"',
      if (collectionId != null) 'collectionId=$collectionId',
    ];
    final query = queryMap.isNotEmpty ? '?${queryMap.join('&')}' : '';

    await navigator.pushNamed(context, '/media?id=$mediaId&$query');
    return null;
  }

  Future<void> openWizard(UniversalMediaSource type) async {
    await navigator.pushNamed(
      context,
      '/media_wizard?type='
      '${type.name}',
    );
  }

  Future<void> openSettings() async {
    await navigator.pushNamed(
      context,
      '/settings',
    );
  }
}
