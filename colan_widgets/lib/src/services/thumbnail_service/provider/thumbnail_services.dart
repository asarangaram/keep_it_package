// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart';
import 'package:stream_channel/isolate_channel.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../model/io_model.dart';

class Bus {
  static final EventBus instance = EventBus();
}

@immutable
class ISOConfig {
  final SendPort sPort;
  final RootIsolateToken rootToken;
  const ISOConfig({
    required this.sPort,
    required this.rootToken,
  });
}

class ThumbnailService {
  ThumbnailService();
  late final IsolateChannel<String> channel;
  late final ReceivePort rPort;

  Future<void> startService() async {
    rPort = ReceivePort();
    final rootToken = RootIsolateToken.instance!;
    channel = IsolateChannel<String>.connectReceive(rPort);
    channel.stream.listen((data) {
      Bus.instance.fire(ThumbnailServiceDataOut.fromJson(data));
    });
    await Isolate.spawn<ISOConfig>(
      isoMain,
      ISOConfig(sPort: rPort.sendPort, rootToken: rootToken),
    );

    //BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
  }

  static Future<void> isoMain(ISOConfig config) async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(config.rootToken);
    final channel = IsolateChannel<String>.connectSend(config.sPort);

    final taskQueue = Queue<ThumbnailServiceDataIn>();
    channel.stream.listen((data) {
      taskQueue.add(ThumbnailServiceDataIn.fromJson(data));
    });

    await run(channel, taskQueue);
  }

  static Future<void> run(
    IsolateChannel<String> channel,
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
          channel.sink.add(dataOut.toJson());
        } catch (e) {
          final dataOut = ThumbnailServiceDataOut(
            uuid: dataIn.uuid,
            errorMsg: e.toString(),
          );
          channel.sink.add(dataOut.toJson());
        }
      } else {
        // print('Sleeping for 100 msec');
        await Future<dynamic>.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  Future<bool> createThumbnail({
    required ThumbnailServiceDataIn info,
    required void Function() onData,
    void Function(String errorString)? onError,
  }) async {
    // print(info);
    Bus.instance.on<ThumbnailServiceDataOut>().listen((event) {
      if (event.uuid == info.uuid) {
        if (event.errorMsg != null) {
          onError?.call(event.errorMsg!);
        } else {
          onData();
        }
      }
    });

    channel.sink.add(info.toJson());
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
  await service.startService();
  return service;
});
