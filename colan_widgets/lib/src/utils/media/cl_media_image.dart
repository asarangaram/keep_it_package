import 'dart:io';
import 'dart:typed_data';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:image/image.dart';

class CLMediaImage extends CLMedia {
  CLMediaImage({
    required super.path,
    required super.type,
    super.url,
    super.previewPath,
  }) : super();

  @override
  CLMediaImage copyWith({
    String? path,
    CLMediaType? type,
    String? url,
    String? previewPath,
    CLDimension? previewDim,
    CLDimension? dimension,
  }) {
    return CLMediaImage(
      path: path ?? this.path,
      type: type ?? this.type,
      url: url ?? this.url,
      previewPath: previewPath ?? this.previewPath,
    );
  }

  @override
  Future<CLMediaImage> withPreview({
    bool forceCreate = false,
  }) async {
    // if previewPath is already set, and not asked to force create,
    if (previewPath != null && !forceCreate) {
      return this;
    }
    final previewFile = File(previewFileName);

    final inputFile = File(path);
    final List<int> bytes = inputFile.readAsBytesSync();

    final image = decodeImage(Uint8List.fromList(bytes));
    if (image == null) {
      throw Exception('1Unable to read file $path');
    }
    final aspectRatio = image.width / image.height;

    final thumbnailWidth = previewWidth;
    final thumbnailHeight = previewWidth ~/ aspectRatio;
    final thumbnail =
        copyResize(image, width: thumbnailWidth, height: thumbnailHeight);
    previewFile.writeAsBytesSync(encodeJpg(thumbnail));

    return copyWith(
      previewPath: previewPath ?? '$path.jpg',
    );
  }
}
