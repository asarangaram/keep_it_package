// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:store/store.dart';

import 'album_manager_helper.dart';

@immutable
class MediaActions {
  final Future<bool> Function() move;
  final Future<bool> Function() delete;
  final Future<bool> Function() share;
  final Future<bool> Function() togglePin;
  final Future<bool> Function() edit;

  final Future<bool> Function(String outFile) replaceMedia;

  final Future<bool> Function(String outFile) cloneAndReplaceMedia;

  final Stream<Progress> Function({
    required Collection collection,
    required void Function() onDone,
  }) moveToCollection;

  const MediaActions({
    required this.move,
    required this.delete,
    required this.share,
    required this.togglePin,
    required this.edit,
    required this.replaceMedia,
    required this.cloneAndReplaceMedia,
    required this.moveToCollection,
  });
}

class OnGetMedia extends StatelessWidget {
  factory OnGetMedia({
    required int id,
    required Widget Function(CLMedia media, {required MediaActions action})?
        builder,
    Key? key,
  }) {
    return OnGetMedia._(
      idList: [id],
      builder: builder,
      builderList: null,
      key: key,
    );
  }
  factory OnGetMedia.multiple({
    required List<int> idList,
    required Widget Function(
      List<CLMedia> media, {
      required MediaActions action,
    })? builder,
    Key? key,
  }) {
    return OnGetMedia._(
      idList: idList,
      builder: null,
      builderList: builder,
      key: key,
    );
  }
  const OnGetMedia._({
    required this.idList,
    required this.builder,
    required this.builderList,
    super.key,
  });

  final List<int> idList;
  final Widget Function(CLMedia media, {required MediaActions action})? builder;
  final Widget Function(List<CLMedia> media, {required MediaActions action})?
      builderList;
  @override
  Widget build(BuildContext context) {
    return GetDBManager(
      builder: (dbManager) {
        if (builder != null) {
          return GetMedia(
            id: idList[0],
            buildOnData: (media) {
              if (media == null) {
                return BasicPageService.message(message: 'Media not found');
              }
              return MediaHandlerWidget(
                media: media,
                dbManager: dbManager,
                builder: builder,
              );
            },
          );
        }
        return GetMediaMultiple(
          idList: idList,
          buildOnData: (media) {
            return MediaHandlerWidget.multiple(
              media: media,
              dbManager: dbManager,
              builderList: builderList,
            );
          },
        );
      },
    );
  }
}

class MediaHandlerWidget extends ConsumerStatefulWidget {
  MediaHandlerWidget({
    required CLMedia media,
    required this.builder,
    required this.dbManager,
    super.key,
  })  : media = [media],
        isList = false,
        builderList = null;

  const MediaHandlerWidget.multiple({
    required this.media,
    required this.dbManager,
    this.builderList,
    super.key,
  })  : isList = true,
        builder = null;
  final List<CLMedia> media;
  final DBManager dbManager;
  final Widget Function(CLMedia media, {required MediaActions action})? builder;
  final Widget Function(List<CLMedia> media, {required MediaActions action})?
      builderList;
  final bool isList;
  @override
  ConsumerState<MediaHandlerWidget> createState() => _MediaHandlerWidgetState();
}

class _MediaHandlerWidgetState extends ConsumerState<MediaHandlerWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.isList) {
      return widget.builderList!(
        widget.media,
        action: MediaActions(
          move: move,
          delete: delete,
          share: share,
          togglePin: togglePin,
          edit: edit,
          replaceMedia: replaceMedia,
          cloneAndReplaceMedia: cloneAndReplaceMedia,
          moveToCollection: moveToCollection,
        ),
      );
    } else {
      return widget.builder!(
        widget.media[0],
        action: MediaActions(
          move: move,
          delete: delete,
          share: share,
          togglePin: togglePin,
          edit: edit,
          replaceMedia: replaceMedia,
          cloneAndReplaceMedia: cloneAndReplaceMedia,
          moveToCollection: moveToCollection,
        ),
      );
    }
  }

  Future<bool> move() async {
    if (widget.media.isEmpty) {
      return true;
    }

    await MediaWizardService.addMedia(
      context,
      ref,
      media: CLSharedMedia(entries: widget.media, type: MediaSourceType.move),
    );
    if (mounted) {
      await context.push(
        '/media_wizard?type='
        '${MediaSourceType.move.name}',
      );
    }

    return true;
  }

  Future<bool> delete() async {
    if (widget.media.isEmpty) {
      return true;
    }
    if (widget.media.length == 1) {
      final confirmed = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return CLConfirmAction(
                title: 'Confirm delete',
                message: 'Are you sure you want to delete '
                    'this ${widget.media[0].type.name}?',
                child: PreviewService(media: widget.media[0]),
                onConfirm: ({required confirmed}) async {
                  if (context.mounted) {
                    Navigator.of(context).pop(confirmed);
                  }
                },
              );
            },
          ) ??
          false;
      if (confirmed) {
        await widget.dbManager.deleteMedia(
          widget.media[0],
          onDeleteFile: (f) async => f.deleteIfExists(),
          onRemovePin: (id) async =>
              AlbumManagerHelper().removeMedia(context, ref, id),
        );
        return true;
      }
      return false;
    } else {
      final confirmed = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return CLConfirmAction(
                title: 'Confirm delete',
                message: 'Are you sure you want to delete '
                    '${widget.media.length} items?',
                child: null,
                onConfirm: ({required confirmed}) =>
                    Navigator.of(context).pop(confirmed),
              );
            },
          ) ??
          false;
      if (confirmed) {
        await widget.dbManager.deleteMediaMultiple(
          widget.media,
          onDeleteFile: (f) async => f.deleteIfExists(),
          onRemovePinMultiple: (id) async =>
              AlbumManagerHelper().removeMultipleMedia(context, ref, id),
        );
      }
      return confirmed;
    }
  }

  Future<bool> share() async {
    if (widget.media.isEmpty) {
      return true;
    }

    final box = context.findRenderObject() as RenderBox?;
    final files = widget.media.map((e) => XFile(e.path)).toList();
    final shareResult = await Share.shareXFiles(
      files,
      // text: 'Share from KeepIT',
      subject: 'Exporting media from KeepIt',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
    return switch (shareResult.status) {
      ShareResultStatus.dismissed => false,
      ShareResultStatus.unavailable => false,
      ShareResultStatus.success => true,
    };
  }

  Future<bool> edit() async {
    if (widget.media.isEmpty) {
      return true;
    }
    if (widget.media.length == 1) {
      if (widget.media[0].pin != null) {
        await ref.read(notificationMessageProvider.notifier).push(
              "Unpin to edit.\n Pinned items can't be edited",
            );
        return false;
      } else {
        // TODO(anandas):  Try moving this to app
        await context.push('/mediaEditor?id=${widget.media[0].id}');
        return true;
      }
    }
    return false;
  }

  Future<bool> togglePin() async {
    if (widget.media.isEmpty) {
      return true;
    }
    if (widget.media.length == 1) {
      await widget.dbManager.togglePin(
        widget.media[0],
        onPin: AlbumManagerHelper().albumManager.addMedia,
        onRemovePin: (id) async =>
            AlbumManagerHelper().removeMedia(context, ref, id),
      );
      return true;
    } else {
      await widget.dbManager.pinMediaMultiple(
        widget.media,
        onPin: AlbumManagerHelper().albumManager.addMedia,
        onRemovePin: (id) async =>
            AlbumManagerHelper().removeMedia(context, ref, id),
      );
      return true;
    }
  }

  Future<bool> replaceMedia(String outFile) {
    return save(outFile, duplicate: false);
  }

  Future<bool> cloneAndReplaceMedia(String outFile) {
    return save(outFile, duplicate: true);
  }

  Future<bool> save(
    String outFile, {
    required bool duplicate,
  }) async {
    final overwrite = !duplicate;
    if (widget.media.isEmpty) {
      return true;
    }
    if (widget.media.length == 1) {
      if (overwrite) {
        final confirmed = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return CLConfirmAction(
                  title: 'Confirm '
                      '${overwrite ? "Replace" : "Save New"} ',
                  message: '',
                  child: PreviewService(
                    media: CLMedia(
                      path: outFile,
                      type: widget.media[0].type,
                    ),
                    keepAspectRatio: false,
                  ),
                  onConfirm: ({required confirmed}) =>
                      Navigator.of(context).pop(confirmed),
                );
              },
            ) ??
            false;
        if (!confirmed) return false;
      }
      final md5String = await File(outFile).checksum;
      final CLMedia updatedMedia;
      if (overwrite) {
        updatedMedia = widget.media[0]
            .copyWith(path: outFile, md5String: md5String)
            .removePin();
      } else {
        updatedMedia = CLMedia(
          path: outFile,
          md5String: md5String,
          type: widget.media[0].type,
          collectionId: widget.media[0].collectionId,
          originalDate: widget.media[0].originalDate,
          createdDate: widget.media[0].createdDate,
          isDeleted: widget.media[0].isDeleted,
          isHidden: widget.media[0].isHidden,
          updatedDate: widget.media[0].updatedDate,
        );
      }
      await widget.dbManager.upsertMedia(
        collectionId: widget.media[0].collectionId!,
        media: updatedMedia,
        onPrepareMedia: (m, {required targetDir}) async {
          final updated = await m.moveFile(targetDir: targetDir);

          return updated;
        },
      );
      if (overwrite) {
        await File(widget.media[0].path).deleteIfExists();
      }
    }
    return false;
  }

  //Can be converted to non static
  Stream<Progress> moveToCollection({
    required Collection collection,
    required void Function() onDone,
  }) async* {
    final Collection updatedCollection;
    if (collection.id == null) {
      yield const Progress(
        fractCompleted: 0,
        currentItem: 'Creating new collection',
      );
      updatedCollection = await widget.dbManager.upsertCollection(
        collection: collection,
      );
    } else {
      updatedCollection = collection;
    }

    if (widget.media.isNotEmpty) {
      final streamController = StreamController<Progress>();
      var completedMedia = 0;
      unawaited(
        widget.dbManager
            .upsertMediaMultiple(
          media: widget.media.map((e) => e.copyWith(isHidden: false)).toList(),
          collectionId: updatedCollection.id!,
          onPrepareMedia: (m, {required targetDir}) async {
            final updated =
                (await m.moveFile(targetDir: targetDir)).getMetadata();
            completedMedia++;

            streamController.add(
              Progress(
                fractCompleted: completedMedia / widget.media.length,
                currentItem: m.basename,
              ),
            );
            await Future<void>.delayed(const Duration(microseconds: 1));
            return updated;
          },
        )
            .then((updatedMedia) async {
          streamController.add(
            const Progress(
              fractCompleted: 1,
              currentItem: 'Successfully Imported',
            ),
          );
          await Future<void>.delayed(const Duration(microseconds: 10));
          await streamController.close();
          onDone();
        }),
      );
      yield* streamController.stream;
    }
  }
}
