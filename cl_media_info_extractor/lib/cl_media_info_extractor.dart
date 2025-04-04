
import 'cl_media_info_extractor_platform_interface.dart';

class ClMediaInfoExtractor {
  Future<String?> getPlatformVersion() {
    return ClMediaInfoExtractorPlatform.instance.getPlatformVersion();
  }
}
