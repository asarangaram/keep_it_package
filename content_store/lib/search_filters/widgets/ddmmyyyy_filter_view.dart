import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';
import 'package:yet_another_date_picker/yet_another_date_picker.dart';

import '../models/filter/base_filter.dart';
import '../models/filter/ddmmyyyy_filter.dart';
import '../providers/filters.dart';

class DDMMYYYYFilterView extends ConsumerWidget {
  const DDMMYYYYFilterView({required this.filter, super.key});
  final CLFilter<CLMedia> filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = this.filter as DDMMYYYYFilter<CLMedia>;
    return ListTile(
      title: Tooltip(
        message: 'search by a month a day '
            'in any year or a specific date',
        child: CLText.large(
          filter.name,
          textAlign: TextAlign.start,
        ),
      ),
      /* trailing: CLButtonIcon.standard(
        filter.enabled ? clIcons.sea : clIcons.deselected,
        onTap: () {
          ref
              .read(filters2NotifierProvider.notifier)
              .updateFilter(filter, 'enable', !filter.enabled);
        },
      ), */
      subtitle: filter.enabled
          ? Stack(
              children: [
                DateSelector(
                  height: 80,
                  years: List.generate(
                    DateTime.now().year - 1970 + 1,
                    (index) => 1970 + index,
                  ),
                  initialDate: filter.ddmmyyyy ??
                      DDMMYYYY.fromDateTime(DateTime(2024, 11, 27)),
                  onDateChanged: (ddmmyyyy) async {
                    ref
                        .read(filtersProvider.notifier)
                        .updateFilter(filter, 'ddmmyyyy', ddmmyyyy);
                  },
                ),
                if (!filter.enabled) ...[
                  Positioned.fill(
                    child: AbsorbPointer(
                      child: ColoredBox(
                        color: Colors.grey.shade200.withAlpha(200),
                      ),
                    ),
                  ),
                ],
              ],
            )
          : null,
    );
  }
}

class DDMMYYYYFilterViewRow extends ConsumerWidget {
  const DDMMYYYYFilterViewRow({required this.filter, super.key});
  final CLFilter<CLMedia> filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = this.filter as DDMMYYYYFilter<CLMedia>;
    if (!filter.enabled) {
      return const Text('Filter not enabled!!!');
    }
    return DateSelector(
      height: 100,
      years: List.generate(
        DateTime.now().year - 1970 + 1,
        (index) => 1970 + index,
      ),
      initialDate:
          filter.ddmmyyyy ?? DDMMYYYY.fromDateTime(DateTime(2024, 11, 27)),
      onDateChanged: (ddmmyyyy) async {
        ref
            .read(filtersProvider.notifier)
            .updateFilter(filter, 'ddmmyyyy', ddmmyyyy);
      },
    );
  }
}
