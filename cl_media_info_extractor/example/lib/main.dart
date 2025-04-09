import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:cl_media_info_extractor/cl_media_info_extractor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? filename;
  String? previewFilename;
  @override
  void initState() {
    super.initState();
  }

  Future<String> generatePreview(String mediaPath) async {
    final ffProbeInfo = await FfmpegUtils.ffprobe(mediaPath);
    final tileSize = _computeTileSize(ffProbeInfo.frameCount);
    final frameFreq = (ffProbeInfo.frameCount / (tileSize * tileSize)).floor();
    return frameFreq.toString();
  }

  static int _computeTileSize(double frameCount) {
    if (frameCount >= 16) {
      return 4;
    } else if (frameCount >= 9) {
      return 3;
    } else {
      return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                FileBrowser(onDone: (file) {
                  setState(() {
                    filename = file;
                    previewFilename =
                        "/Users/anandasarangaram/Work/keep_it_package/${p.basenameWithoutExtension(filename!)}.tn.jpg";

                    print("filename: $filename");
                    print("previewFilename:$previewFilename");
                  });
                }),
                if (filename != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder(
                          future: CLMediaFile.fromPath(
                              //"'/Users/anandasarangaram/Downloads/old/Dont Upload delete after review/PHOTO-2024-11-27-11-02-58.jpg'",
                              "'$filename'"),
                          builder: (context, snapShot) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Exif Info extractor",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                if (snapShot.connectionState ==
                                    ConnectionState.waiting)
                                  const CircularProgressIndicator()
                                else if (snapShot.hasError)
                                  Text('Error: ${snapShot.error}')
                                else if (snapShot.hasData)
                                  Text(prettyJson(snapShot.data!.toMap()))
                                else
                                  const Text('No data')
                              ],
                            );
                          }),
                      FutureBuilder(future: () {
                        return FfmpegUtils.generatePreview("'$filename'",
                            // '/Users/anandasarangaram/Work/keep_it_package/VIDEO-2024-06-26-14-37-50.mp4',
                            //"'/Users/anandasarangaram/Downloads/old/Dont Upload delete after review/VIDEO-2024-06-26-14-37-50.mp4'",
                            //"'/Users/anandasarangaram/Work/keep_it_package/with space/VIDEO-2024-06-26-14-37-50.mp4'",
                            previewPath: '$previewFilename'
                            //"/Users/anandasarangaram/Work/keep_it_package/VIDEO-2024-06-26-14-37-50.tn.jpg"
                            );
                      }(), builder: (context, snapShot) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Video Preview generation",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (snapShot.connectionState ==
                                ConnectionState.waiting)
                              const CircularProgressIndicator()
                            else if (snapShot.hasError)
                              Text('Error: ${snapShot.error}')
                            else if (snapShot.hasData)
                              Text(snapShot.data!)
                            else
                              const Text('No data'),
                            if (snapShot.hasData && previewFilename != null)
                              Container(
                                  decoration:
                                      BoxDecoration(border: Border.all()),
                                  child: WatchedImage(
                                    key: ValueKey(previewFilename!),
                                    filePath: previewFilename!,
                                  ))
                          ],
                        );
                      }),
                    ].map((e) => Expanded(child: e)).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String prettyJson(dynamic json) {
  var spaces = ' ' * 4;
  var encoder = JsonEncoder.withIndent(spaces);
  String output = encoder.convert(json);

  return output;
}

class FileBrowser extends StatelessWidget {
  final void Function(String filename) onDone;

  const FileBrowser({super.key, required this.onDone});

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
        initialDirectory:
            '/Users/anandasarangaram/Downloads/old/Dont Upload delete after review');

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      onDone(path);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.folder_open),
        label: const Text('Browse Files'),
        onPressed: () => _pickFile(context),
      ),
    );
  }
}

class WatchedImage extends StatefulWidget {
  final String filePath;

  const WatchedImage({super.key, required this.filePath});

  @override
  State<WatchedImage> createState() => _WatchedImageState();
}

class _WatchedImageState extends State<WatchedImage> {
  bool fileExists = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkFilePeriodically();
  }

  void _checkFilePeriodically() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final exists = File(widget.filePath).existsSync();
      if (exists != fileExists) {
        setState(() {
          fileExists = exists;
        });
        if (exists) {
          print("file is ready!");
        }
        if (exists) _timer?.cancel(); // Stop checking once file appears
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (fileExists) {
      return Image.file(File(widget.filePath), key: ValueKey(DateTime.now()));
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
