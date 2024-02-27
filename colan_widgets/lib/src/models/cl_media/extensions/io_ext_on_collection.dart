import 'dart:io';

import 'package:colan_widgets/src/models/cl_media/extensions/io_ext_on_cl_media.dart';

import 'package:path/path.dart' as path_handler;

import '../../../views/stream_progress_view.dart';
import '../../cl_media.dart';
import '../../collection.dart';

extension IOExtOnCollection on Collection {
  String get path => 'keep_it/cluster_${id!}';

  void deleteDir(String pathPrefix) {
    final targetDir = path_handler.join(
      pathPrefix,
      path,
    );
    Directory(targetDir).deleteSync(recursive: true);
  }

  Future<List<CLMedia>?> addMedia({
    required List<CLMedia>? media,
    required String pathPrefix,
  }) async {
    if (id == null) {
      throw Exception("can't add media to non existing collection");
    }
    final targetDir = path_handler.join(pathPrefix, path);
    if (media?.isEmpty ?? false) {
      final updated = <CLMedia>[];
      for (final item0 in media!) {
        final item1 =
            await item0.setCollectionId(id).moveFile(targetDir: targetDir);
        updated.add(item1);
      }
      return updated;
    }
    return null;
  }

  Stream<Progress> addMediaWithProgress({
    required List<CLMedia> media,
    required String pathPrefix,
    required void Function(List<CLMedia>) onDone,
  }) async* {
    if (media.isEmpty) {
      onDone([]);
    }
    final targetDir = path_handler.join(pathPrefix, path);

    yield Progress(
      currentItem: 'processing ${media[0].basename}',
      fractCompleted: 0,
    );
    final updated = <CLMedia>[];
    for (final (i, item0) in media.indexed) {
      final item =
          await item0.setCollectionId(id).moveFile(targetDir: targetDir);
      updated.add(item);

      if (i + 1 < media.length) {
        yield Progress(
          currentItem: 'processing ${media[i + 1].basename}',
          fractCompleted: (i + 1) / media.length,
        );
      }
    }
    yield const Progress(
      currentItem: 'Successfully Completed',
      fractCompleted: 1,
    );
    onDone.call(updated);
  }
}
