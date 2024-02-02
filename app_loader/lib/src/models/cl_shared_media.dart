
/* class CLIncomingItem {
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

  void destroy() {
    if (File(content).existsSync()) {
      File(content).deleteIfExists();
    }
  }
} */
/* 
class CLIncomingMedia {
  CLIncomingMedia(
    this.attachments, {
    this.targetId,
  });
  final List<CLMedia> attachments;
  int? targetId;

  void destroy() {
    for (final item in attachments) {
      item.deleteFile();
    }
  }
}
 */
