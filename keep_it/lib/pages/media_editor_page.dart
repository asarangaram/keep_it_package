import 'dart:io';
import 'dart:typed_data';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:keep_it/modules/shared_media/cl_media_process.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:store/store.dart';

import '../widgets/editors/video/video_trimmer.dart';

class MediaEditorPage extends ConsumerWidget {
  const MediaEditorPage({
    required this.mediaId,
    super.key,
  });
  final int? mediaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (mediaId == null) {
      return const CLErrorView(errorMessage: 'No Media Provided');
    }
    return GetDBManager(
      builder: (dbManager) {
        return GetMedia(
          id: mediaId!,
          buildOnData: (media) {
            if (media.isValidMedia && media.type == CLMediaType.image) {
              return ImageCropperWrap(
                File(media.path),
                onSave: (c, outFile, {required overwrite}) async {
                  await onSave(
                    c,
                    overwrite: overwrite,
                    dbManager: dbManager,
                    originalMedia: media,
                    editedFile: outFile,
                  );
                  if (context.mounted) {
                    if (context.canPop()) {
                      context.pop();
                    }
                  }
                },
                onDiscard: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
              );
            }
            if (media.isValidMedia && media.type == CLMediaType.video) {
              return TrimmerView(
                File(media.path),
                onSave: (context, outFile, {required overwrite}) async {
                  await onSave(
                    context,
                    overwrite: overwrite,
                    dbManager: dbManager,
                    originalMedia: media,
                    editedFile: outFile,
                  );
                },
                onDiscard: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
              );
            }
            return const CLErrorView(errorMessage: 'Not supported yet');
          },
        );
      },
    );
  }

  Future<void> onSave(
    BuildContext context, {
    required bool overwrite,
    required CLMedia originalMedia,
    required DBManager dbManager,
    required String editedFile,
  }) async {
    final md5String = await File(editedFile).checksum;
    final CLMedia updatedMedia;
    if (overwrite) {
      updatedMedia =
          originalMedia.copyWith(path: editedFile, md5String: md5String);
    } else {
      updatedMedia = CLMedia(
        path: editedFile,
        type: originalMedia.type,
        collectionId: originalMedia.collectionId,
        md5String: md5String,
        originalDate: originalMedia.originalDate,
        createdDate: originalMedia.createdDate,
      );
    }
    await dbManager.upsertMedia(
      collectionId: originalMedia.collectionId!,
      media: updatedMedia,
      onPrepareMedia: (m, {required targetDir}) async {
        final updated = (await m.moveFile(targetDir: targetDir)).getMetadata();

        return updated;
      },
    );
  }
}

class ImageCropperWrap extends StatelessWidget {
  const ImageCropperWrap(
    this.image, {
    required this.onDiscard,
    required this.onSave,
    super.key,
  });
  final File image;
  final void Function(
    BuildContext context,
    String, {
    required bool overwrite,
  }) onSave;
  final void Function() onDiscard;

  static Future<Uint8List?> editImage(BuildContext c, File file) async {
    final bytes = await file.readAsBytes();
    if (c.mounted) {
      return editMemoryImage(c, bytes);
    }
    return null;
  }

  static Future<Uint8List?> editMemoryImage(
    BuildContext c,
    Uint8List bytes,
  ) async {
    return Navigator.push<Uint8List>(
      c,
      MaterialPageRoute(
        builder: (context) => ImageEditor(
          image: Uint8List.fromList(bytes), // <-- Uint8List of image
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FullscreenLayout(
      child: FutureBuilder(
        future: editImage(context, image).then((value) {
          if (value == null) {
            onDiscard();
          }
          return value!;
        }),
        builder: (context, snapShot) {
          if (snapShot.hasData && snapShot.data != null) {
            return HandleEdittedImage(
              originalImage: image,
              edittedImage: snapShot.data!,
              onSave: onSave,
              onDiscard: onDiscard,
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class HandleEdittedImage extends StatefulWidget {
  const HandleEdittedImage({
    required this.originalImage,
    required this.onSave,
    required this.onDiscard,
    required this.edittedImage,
    super.key,
  });
  final Uint8List edittedImage;
  final File originalImage;
  final void Function(
    BuildContext context,
    String, {
    required bool overwrite,
  }) onSave;
  final void Function() onDiscard;
  @override
  State<HandleEdittedImage> createState() => _HandleEdittedImageState();
}

class _HandleEdittedImageState extends State<HandleEdittedImage> {
  late Uint8List? edittedImage;
  @override
  void initState() {
    edittedImage = widget.edittedImage;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Image image;
    if (edittedImage == null) {
      image = Image.file(widget.originalImage);
    } else {
      image = Image.memory(edittedImage!);
    }
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: image),
            Row(
              children: [
                Expanded(
                  child: CLButtonIconLabelled.small(
                    MdiIcons.pencil,
                    edittedImage == null ? 'Edit' : 'Edit More',
                    onTap: () async {
                      final Uint8List? updatedImage;
                      if (edittedImage == null) {
                        updatedImage = await ImageCropperWrap.editImage(
                          context,
                          widget.originalImage,
                        );
                      } else {
                        updatedImage = await ImageCropperWrap.editMemoryImage(
                          context,
                          edittedImage!,
                        );
                      }
                      setState(() {
                        edittedImage = updatedImage;
                      });
                    },
                  ),
                ),
                if (edittedImage == null)
                  Container()
                else
                  Expanded(
                    child: CLButtonIconLabelled.small(
                      MdiIcons.origin,
                      'Restore Original',
                      onTap: () async {
                        setState(() {
                          edittedImage = null;
                        });
                      },
                    ),
                  ),
                if (edittedImage == null)
                  Container()
                else
                  Expanded(
                    child: PopupMenuButton<String>(
                      child: CLIcon.standard(
                        MdiIcons.check,
                      ),
                      onSelected: (String value) async {
                        if (value == 'Replace Original') {
                          final file = await saveImageToCache(edittedImage!);
                          if (context.mounted) {
                            if (file != null) {
                              widget.onSave(
                                context,
                                file,
                                overwrite: true,
                              );
                            }
                          }
                        } else if (value == 'Save Copy') {
                          final file = await saveImageToCache(edittedImage!);
                          if (context.mounted) {
                            if (file != null) {
                              widget.onSave(
                                context,
                                file,
                                overwrite: false,
                              );
                            }
                          }
                        } else if (value == 'Discard') {
                          widget.onDiscard();
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return {'Replace Original', 'Save Copy', 'Discard'}
                            .map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
        if (edittedImage == null)
          const Align(
            alignment: Alignment.topLeft,
            child: CLButtonIcon.small(Icons.arrow_back),
          ),
      ],
    );
  }

  Future<String?> saveImageToCache(Uint8List imageBytes) async {
    try {
      final cacheDir = await getTemporaryDirectory();

      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageFile = File('${cacheDir.path}/$fileName');

      await imageFile.writeAsBytes(imageBytes);
      return imageFile.path;
    } catch (e) {
      /*** */
      return null;
    }
  }
}
