import 'package:cl_entity_viewers/cl_entity_viewers.dart' show CLMediaViewer;
import 'package:flutter/widgets.dart';

class MediaViewService extends StatelessWidget {
  const MediaViewService({required this.parentIdentifier, super.key});
  final String parentIdentifier;
  @override
  Widget build(BuildContext context) {
    return CLMediaViewer(
      parentIdentifier: parentIdentifier,
    );
  }
}
