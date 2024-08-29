import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heif_converter/heif_converter.dart';
import 'package:image/image.dart' as img;
import 'package:mime/mime.dart';
import 'package:stream_channel/isolate_channel.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

@immutable
class ThumbnailServiceDataIn {
  const ThumbnailServiceDataIn({
    required this.uuid,
    required this.path,
    required this.thumbnailPath,
    required this.isVideo,
    required this.dimension,
  });

  factory ThumbnailServiceDataIn.fromMap(Map<String, dynamic> map) {
    return ThumbnailServiceDataIn(
      uuid: map['uuid'] as String,
      path: map['inPath'] as String,
      thumbnailPath: map['outPath'] as String,
      isVideo: map['isVideo'] as bool,
      dimension: map['dimension'] as int,
    );
  }

  factory ThumbnailServiceDataIn.fromJson(String source) =>
      ThumbnailServiceDataIn.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );
  final String uuid;
  final String path;
  final String thumbnailPath;
  final bool isVideo;
  final int dimension;

  ThumbnailServiceDataIn copyWith({
    String? uuid,
    String? inPath,
    String? outPath,
    bool? isVideo,
    int? dimension,
  }) {
    return ThumbnailServiceDataIn(
      uuid: uuid ?? this.uuid,
      path: inPath ?? path,
      thumbnailPath: outPath ?? thumbnailPath,
      isVideo: isVideo ?? this.isVideo,
      dimension: dimension ?? this.dimension,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uuid': uuid,
      'inPath': path,
      'outPath': thumbnailPath,
      'isVideo': isVideo,
      'dimension': dimension,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  bool operator ==(covariant ThumbnailServiceDataIn other) {
    if (identical(this, other)) return true;

    return other.uuid == uuid &&
        other.path == path &&
        other.thumbnailPath == thumbnailPath &&
        other.isVideo == isVideo &&
        other.dimension == dimension;
  }

  @override
  int get hashCode {
    return uuid.hashCode ^
        path.hashCode ^
        thumbnailPath.hashCode ^
        isVideo.hashCode ^
        dimension.hashCode;
  }

  @override
  String toString() {
    return 'ThumbnailServiceDataIn(uuid: $uuid, path: $path,'
        ' thumbnailPath: $thumbnailPath, isVideo: $isVideo,'
        ' dimension: $dimension)';
  }
}

@immutable
class ThumbnailServiceDataOut {
  const ThumbnailServiceDataOut({
    required this.uuid,
    this.errorMsg,
  });

  factory ThumbnailServiceDataOut.fromMap(Map<String, dynamic> map) {
    return ThumbnailServiceDataOut(
      uuid: map['uuid'] as String,
      errorMsg: map['errorMsg'] != null ? map['errorMsg'] as String : null,
    );
  }

  factory ThumbnailServiceDataOut.fromJson(String source) =>
      ThumbnailServiceDataOut.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );
  final String uuid;

  final String? errorMsg;

  ThumbnailServiceDataOut copyWith({
    String? uuid,
    String? errorMsg,
  }) {
    return ThumbnailServiceDataOut(
      uuid: uuid ?? this.uuid,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uuid': uuid,
      'errorMsg': errorMsg,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'ThumbnailServiceDataOut(uuid: $uuid, errorMsg: $errorMsg)';

  @override
  bool operator ==(covariant ThumbnailServiceDataOut other) {
    if (identical(this, other)) return true;

    return other.uuid == uuid && other.errorMsg == errorMsg;
  }

  @override
  int get hashCode => uuid.hashCode ^ errorMsg.hashCode;
}

class Bus {
  static final EventBus instance = EventBus();
}

@immutable
class ISOConfig {
  const ISOConfig({
    required this.sPort,
    required this.rootToken,
  });
  final SendPort sPort;
  final RootIsolateToken rootToken;
}

class ThumbnailService {
  ThumbnailService();
  late final IsolateChannel<String> channel;
  late final ReceivePort rPort;
  Map<String, StreamSubscription<ThumbnailServiceDataOut>> subscriptions = {};

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
          if (File(dataIn.path).existsSync()) {
            if (dataIn.isVideo) {
              if (File(dataIn.thumbnailPath).existsSync()) {
                File(dataIn.thumbnailPath).deleteSync();
              }
              if (Platform.isIOS || Platform.isAndroid) {
                final path = await VideoThumbnail.thumbnailFile(
                  video: dataIn.path,
                  //thumbnailPath: dataIn.thumbnailPath,
                  maxWidth: dataIn.dimension,
                  imageFormat: ImageFormat.JPEG,
                );
                if (path == null) {
                  throw const FileSystemException(
                    'Unable to create video thumbnail',
                  );
                }
                File(path).copySync(dataIn.thumbnailPath);
                File(path).deleteSync();
              } else {
                /* print(
                  'thumnail support not avaialble '
                  'for ${Platform.operatingSystem}',
                ); */
                throw Exception(
                  'thumnail support not avaialble '
                  'for ${Platform.operatingSystem}',
                );
              }
            } else {
              final img.Image? inputImage;
              if (lookupMimeType(dataIn.path) == 'image/heic') {
                final jpegPath = await HeifConverter.convert(
                  dataIn.path,
                  output: '${dataIn.path}.jpeg',
                );
                if (jpegPath == null) {
                  throw Exception(' Failed to convert HEIC file to JPEG');
                }
                inputImage = img.decodeImage(File(jpegPath).readAsBytesSync());
              } else {
                inputImage =
                    img.decodeImage(File(dataIn.path).readAsBytesSync());
              }
              if (inputImage != null) {
                final int thumbnailHeight;
                final int thumbnailWidth;
                if (inputImage.height > inputImage.width) {
                  thumbnailHeight = dataIn.dimension;
                  thumbnailWidth =
                      (thumbnailHeight * inputImage.width) ~/ inputImage.height;
                } else {
                  thumbnailWidth = dataIn.dimension;
                  thumbnailHeight =
                      (thumbnailWidth * inputImage.height) ~/ inputImage.width;
                }
                final thumbnail = img.copyResize(
                  inputImage,
                  width: thumbnailWidth,
                  height: thumbnailHeight,
                );
                File(dataIn.thumbnailPath).writeAsBytesSync(
                  Uint8List.fromList(img.encodeJpg(thumbnail)),
                );
              } else {
                throw Exception('unable to decode');
              }
            }
            final dataOut = ThumbnailServiceDataOut(
              uuid: dataIn.uuid,
            );
            channel.sink.add(dataOut.toJson());
          } else {
            throw Exception('file ${dataIn.path} not found');
          }
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
    // Don't request multiple time
    if (subscriptions.containsKey(info.uuid)) {
      return true;
    }

    subscriptions[info.uuid] =
        Bus.instance.on<ThumbnailServiceDataOut>().listen((event) {
      if (event.uuid == info.uuid) {
        if (event.errorMsg != null) {
          onError?.call(event.errorMsg!);
        } else {
          onData();
        }
        // Cancel subscription once received
        subscriptions.remove(info.uuid)?.cancel();
      }
    });

    channel.sink.add(info.toJson());
    return true;
  }
}
