import 'package:flutter/widgets.dart';
import 'package:store/store.dart';

class GetSortedEntity extends StatelessWidget {
  const GetSortedEntity({
    required this.entities,
    required this.builder,
    super.key,
  });
  final List<CLEntity> entities;
  final Widget Function(List<CLEntity> sorted) builder;

  @override
  Widget build(BuildContext context) {
    final List<CLEntity> sorted;
    if (entities.every((e) => e is CLMedia)) {
      sorted = List<CLEntity>.from(entities)
        ..sort(
          (a, b) => ((a as CLMedia).label?.toLowerCase() ?? '')
              .compareTo((b as CLMedia).label?.toLowerCase() ?? ''),
        );
    } else if (entities.every((e) => e is CLMedia)) {
      sorted = List<CLEntity>.from(entities)
        ..sort(
          (a, b) => ((a as CLMedia).label?.toLowerCase() ?? '')
              .compareTo((b as CLMedia).label?.toLowerCase() ?? ''),
        );
    } else {
      throw UnimplementedError('unsupported entity type, mix not supported');
    }

    return builder(sorted);
  }
}
