import 'package:flutter/widgets.dart';
import 'package:store/store.dart';

class GetSortedEntity extends StatelessWidget {
  const GetSortedEntity({
    required this.entities,
    required this.builder,
    super.key,
  });
  final List<ViewerEntityMixin> entities;
  final Widget Function(List<ViewerEntityMixin> sorted) builder;

  @override
  Widget build(BuildContext context) {
    if (entities.isEmpty) {
      return builder(entities);
    }

    final List<ViewerEntityMixin> sorted;
    if (entities.every((e) => e is StoreEntity)) {
      sorted = List<ViewerEntityMixin>.from(entities)
        ..sort(
          (a, b) => ((a as StoreEntity).data.label?.toLowerCase() ?? '')
              .compareTo((b as StoreEntity).data.label?.toLowerCase() ?? ''),
        );
    } else {
      throw UnimplementedError('unsupported entity type, mix not supported');
    }

    return builder(sorted);
  }
}
