/// Store Implemented using riverpod
/// This has only abstract, you must provide the actual implementation
/// for the store class as specified in store.dart'
library;

export 'app_logger.dart';
export 'extensions.dart';
export 'src/extensions/ext_list.dart';
export 'src/extensions/map_operations.dart' show MapDiff;
export 'src/models/cl_entity.dart' show CLEntity;
export 'src/models/data_types.dart' show EntityQuery, UpdateStrategy;

export 'src/models/gallery_group.dart';
export 'src/models/store.dart' show NotNullValues, Shortcuts, StoreQuery;
export 'src/models/viewer_entity_mixin.dart'
    show EntityFilter, ViewerEntityMixin;
