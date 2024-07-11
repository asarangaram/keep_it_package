import 'dart:ui';

import 'package:share_plus/share_plus.dart';

class ShareManager {
  static Future<bool> onShareFiles(
    List<String> files, {
    Rect? sharePositionOrigin,
  }) async {
    final xFiles = files.map(XFile.new).toList();

    final shareResult = await Share.shareXFiles(
      xFiles,
      subject: 'from KeepIt',
      sharePositionOrigin: sharePositionOrigin,
    );
    return switch (shareResult.status) {
      ShareResultStatus.dismissed => false,
      ShareResultStatus.unavailable => false,
      ShareResultStatus.success => true,
    };
  }
}
