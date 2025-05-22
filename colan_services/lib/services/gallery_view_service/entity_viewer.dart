import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'gallery_view_service.dart';

class EntityViewer extends ConsumerWidget {
  const EntityViewer({
    required this.parentIdentifier,
    required this.storeIdentity,
    required this.id,
    super.key,
  });
  final String parentIdentifier;
  final String storeIdentity;
  final int? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      child: AppTheme(
        child: Scaffold(
          appBar: AppBar(),
          body: OnSwipe(
            child: SafeArea(
              bottom: false,
              child: GalleryViewService0(
                parentIdentifier: parentIdentifier,
                storeIdentity: storeIdentity,
                id: id,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
