import 'dart:collection';

import 'dart:io';
import 'dart:typed_data';

import 'package:event_bus/event_bus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart';
import 'package:iso/iso.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'io_model.dart';

class Bus {
  static final EventBus instance = EventBus();
}

class ThumbnailService {
  ThumbnailService() {
    iso = Iso(
      start,
      onDataOut: (dynamic data) {
        Bus.instance.fire(ThumbnailServiceDataOut.fromJson(data as String));
      },
    );
    iso.run();
  }
  late final Iso iso;

  static Future<void> start(IsoRunner iso) async {
    final taskQueue = Queue<ThumbnailServiceDataIn>();

    iso.receive();
    iso.dataIn?.listen((dynamic data) {
      taskQueue.add(ThumbnailServiceDataIn.fromJson(data as String));
    });

    await run(iso, taskQueue);
  }

  static Future<void> run(
    IsoRunner iso,
    Queue<ThumbnailServiceDataIn> queue,
  ) async {
    while (true) {
      if (queue.isNotEmpty) {
        final dataIn = queue.removeFirst();
        try {
          if (dataIn.isVideo) {
            await VideoThumbnail.thumbnailFile(
              video: dataIn.path,
              thumbnailPath: dataIn.thumbnailPath,
              maxWidth: dataIn.dimension,
              imageFormat: ImageFormat.JPEG,
            );
          } else {
            final inputImage = decodeImage(File(dataIn.path).readAsBytesSync());
            if (inputImage != null) {
              final thumbnailWidth = dataIn.dimension;
              final thumbnailHeight = dataIn.dimension;
              final thumbnail = copyResize(
                inputImage,
                width: thumbnailWidth,
                height: thumbnailHeight,
              );
              File(dataIn.thumbnailPath)
                  .writeAsBytesSync(Uint8List.fromList(encodeJpg(thumbnail)));
            }
          }
          final dataOut = ThumbnailServiceDataOut(
            uuid: dataIn.uuid,
          );
          iso.send(dataOut.toJson());
        } catch (e) {
          final dataOut = ThumbnailServiceDataOut(
            uuid: dataIn.uuid,
            errorMsg: e.toString(),
          );
          iso.send(dataOut.toJson());
        }
      }
      await Future<dynamic>.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<dynamic> ensureInitialized() async {
    return iso.onCanReceive;
  }

  Future<bool> createThumbnail({
    required ThumbnailServiceDataIn info,
    required void Function() onData,
    void Function(String errorString)? onError,
  }) async {
    Bus.instance.on<ThumbnailServiceDataOut>().listen((event) {
      if (event.uuid == info.uuid) {
        if (event.errorMsg != null) {
          onError?.call(event.errorMsg!);
        } else {
          onData();
        }
      }
    });

    iso.send(info.toJson());
    return true;
  }
}

/* void main() async {
  print('main');
  final service = ThumbnailService();
  await service.ensureInitialized();

  for (var i = 0; i < 100; i++) {
    final media =
        CLMedia(path: 'file.jpg', preveiwFileName: 'file.jpg.tn', id: i);
    print('Request ${media.id}');
    await service.createThumbnail(media, () {
      print('Completed ${media.id}');
    });
    await Future<dynamic>.delayed(const Duration(milliseconds: 10));
  }
}
static Future<String> get pathPrefix async =>
      _pathPrefix ??= (await getApplicationDocumentsDirectory()).path;
 */

final thumbnailServiceProvider = FutureProvider<ThumbnailService>((ref) async {
  final service = ThumbnailService();
  await service.ensureInitialized();
  return service;
});
