import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../camera_service/cl_camera_service.dart';
import '../camera_service/theme/default_theme.dart';
import '../notification_services/provider/notify.dart';

class PageManager extends Navigator {
  const PageManager(this.context, this.ref, {super.key});

  factory PageManager.of(BuildContext context, WidgetRef ref) {
    return PageManager(context, ref);
  }
  final BuildContext context;
  final WidgetRef ref;

  void home() {
    Navigator.of(context).popUntil(ModalRoute.withName('/'));
  }

  void pop<T extends Object?>([T? result]) {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.of(context).pop(result);
    }
  }

  bool canPop() {
    return Navigator.canPop(context);
  }

  void closeDialog<T extends Object?>([T? result]) {
    Navigator.of(context).pop(result);
  }

  Future<bool?> openCamera({
    int? collectionId,
  }) async {
    await CLCameraService.invokeWithSufficientPermission(
      context,
      () async {
        if (context.mounted) {
          await Navigator.pushNamed(
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
      await ref.read(notificationMessageProvider.notifier).push(
            "Unpin to edit.\n Pinned items can't be edited",
          );
      return media;
    } else {
      final edittedMedia = await Navigator.of(context).pushNamed(
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
    await Navigator.pushNamed(
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

    await Navigator.pushNamed(context, '/media?id=$mediaId&$query');
    return null;
  }

  Future<void> openWizard(UniversalMediaSource type) async {
    await Navigator.pushNamed(
      context,
      '/media_wizard?type='
      '${type.name}',
    );
  }

  Future<void> openSettings() async {
    await Navigator.pushNamed(
      context,
      '/settings',
    );
  }
}

enum CLScreenPopGesture { swipeLeft, onTap }

class CLPopScreen extends ConsumerWidget {
  const CLPopScreen._({
    required this.child,
    required this.popGesture,
    required this.result,
    super.key,
  });

  factory CLPopScreen.onSwipe({
    required Widget child,
    Key? key,
    bool? result,
  }) {
    return CLPopScreen._(
      popGesture: CLScreenPopGesture.swipeLeft,
      key: key,
      result: result,
      child: child,
    );
  }
  factory CLPopScreen.onTap({
    required Widget child,
    Key? key,
    bool? result,
  }) {
    return CLPopScreen._(
      popGesture: CLScreenPopGesture.onTap,
      key: key,
      result: result,
      child: child,
    );
  }

  final Widget? child;
  final CLScreenPopGesture popGesture;
  final bool? result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CLKeyListener(
      onEsc: (popGesture == CLScreenPopGesture.swipeLeft) &&
              !ColanPlatformSupport.isMobilePlatform
          ? () => PageManager.of(context, ref).pop(result)
          : null,
      child: GestureDetector(
        onTap: popGesture == CLScreenPopGesture.onTap
            ? () => PageManager.of(context, ref).pop
            : null,
        onHorizontalDragEnd: popGesture == CLScreenPopGesture.swipeLeft
            ? (DragEndDetails details) {
                if (details.primaryVelocity == null) return;
                // pop on Swipe
                if (details.primaryVelocity! > 0) {
                  PageManager.of(context, ref).pop(result);
                }
              }
            : null,
        child: child,
      ),
    );
  }
}
