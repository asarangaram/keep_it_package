import 'cl_media_info_extractor_platform_interface.dart';

Future<String?> getPlatformVersion() {
  return ClMediaInfoExtractorPlatform.instance.getPlatformVersion();
}
