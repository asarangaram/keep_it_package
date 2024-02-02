import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:share_handler/share_handler.dart';

class CLIncomingItem {
  CLIncomingItem({
    required this.content,
    this.type,
  });
  factory CLIncomingItem.fromSharedAttachment(
    SharedAttachment attachment,
  ) {
    return CLIncomingItem(
      content: attachment.path,
      type: toCLMediaType(attachment.type),
    );
  }
  final String content;
  final CLMediaType? type;

  static CLMediaType toCLMediaType(SharedAttachmentType type) {
    return switch (type) {
      SharedAttachmentType.image => CLMediaType.image,
      SharedAttachmentType.video => CLMediaType.video,
      SharedAttachmentType.audio => CLMediaType.audio,
      SharedAttachmentType.file => CLMediaType.file,
    };
  }

  void destroy() {
    if (File(content).existsSync()) {
      File(content).deleteIfExists();
    }
  }
}

class CLIncomingMedia {
  CLIncomingMedia(
    this.attachments, {
    this.targetId,
  });
  final List<CLIncomingItem> attachments;
  int? targetId;

  void destroy() {
    for (final item in attachments) {
      item.destroy();
    }
  }
}
