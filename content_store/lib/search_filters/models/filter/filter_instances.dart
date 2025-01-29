import 'package:store/store.dart';

import '../filters.dart';
import 'base_filter.dart';
import 'ddmmyyyy_filter.dart';
import 'enum_filter.dart';
import 'string_filter.dart';

final List<CLFilter<CLMedia>> allFilters = List.unmodifiable([
  EnumFilter<CLMedia, CLMediaType>(
    name: 'Search By MediaType',
    labels: {
      for (var e in [CLMediaType.image, CLMediaType.video]) e: e.name,
    },
    fieldSelector: (media) => media.type,
    enabled: true,
  ),
  EnumFilter<CLMedia, MediaAvailability>(
    name: 'Search By Location',
    labels: {
      for (var e in MediaAvailability.values) e: e.name,
    },
    fieldSelector: (media) {
      if (media.hasServerUID && media.isMediaCached) {
        return MediaAvailability.synced;
      } else if (media.hasServerUID) {
        return MediaAvailability.coLan;
      }
      return MediaAvailability.local;
    },
    enabled: true,
  ),
  DDMMYYYYFilter<CLMedia>(
    name: 'Search by Date',
    fieldSelector: (media) => media.createdDate,
    enabled: false,
  ),
]);

Map<String, CLFilter<CLMedia>> get allFiltersMap =>
    Map.unmodifiable({for (final e in allFilters) e.name: e});

final StringFilter<CLMedia> textSearchFilter = StringFilter(
  name: 'TextSearch',
  fieldSelector: (media) => [media.name, media.ref].join(' ').toLowerCase(),
  query: '',
  enabled: true,
);
