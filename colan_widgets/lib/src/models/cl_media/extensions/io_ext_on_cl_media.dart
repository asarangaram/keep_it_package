import '../../../app_logger.dart';
import '../../cl_media.dart';

// TODO: Fix label
extension IOExtOnCLMedia on CLMedia {
  String get basename => label;

  bool get isValidMedia {
    //TODO
    /* if (collectionId == null) {
      throw Exception("Item can't be stored without collectionId");
    }
    switch (type) {
      case CLMediaType.image:
      case CLMediaType.video:
      case CLMediaType.audio:
      case CLMediaType.file:
        if (!File(_path).existsSync()) {
          return false;
        }

      case CLMediaType.url:
      case CLMediaType.text:
        break;
    } */
    return true;
  }
}

const _filePrefix = 'Media File handling: ';
bool _disableInfoLogger = true;
// ignore: unused_element
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i('$_filePrefix$msg');
  }
}
