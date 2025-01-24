import 'package:flutter_test/flutter_test.dart';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    throw UnimplementedError();
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return './integration_test/ApplicationSupportPath';
  }

  @override
  Future<String?> getLibraryPath() async {
    throw UnimplementedError();
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return './integration_test/ApplicationDocumentsPath';
  }

  @override
  Future<String?> getExternalStoragePath() async {
    throw UnimplementedError();
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    throw UnimplementedError();
  }

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> getDownloadsPath() async {
    throw UnimplementedError();
  }
}
