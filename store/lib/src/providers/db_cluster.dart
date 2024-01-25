import 'package:flutter_riverpod/flutter_riverpod.dart';



import '../models/cluster.dart';
import '../models/db.dart';
import '../models/db_queries.dart';
import '../models/tag.dart';
import 'db_manager.dart';
import 'db_queries.dart';

class ClustersNotifier extends StateNotifier<AsyncValue<Clusters>> {
  ClustersNotifier({
    required this.ref,
    this.databaseManager,
    this.tagID,
  }) : super(const AsyncValue.loading()) {
    loadClusters();
  }
  DatabaseManager? databaseManager;
  int? tagID;
  Ref ref;

  bool isLoading = false;

  Future<void> loadClusters() async {
    if (databaseManager == null) return;
    final List<Cluster> clusters;
    final Tag? tag;
    if (tagID == null) {
      clusters = ClusterDB.getAll(databaseManager!.db);
      tag = null;
    } else {
      clusters = ClusterDB.getClustersForTag(
        databaseManager!.db,
        tagID!,
      );
      tag = TagDB.getById(databaseManager!.db, tagID!);
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return Clusters(clusters, tag: tag);
    });
  }

  Future<int> upsertCluster(Cluster cluster, List<int> tagIds) async {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }

    // Save Cluster and get Cluster ID.
    // Associate it wtih all the TagIds
    // invalidate the clusters queries by Tag id for all TagIds

    final clusterId = cluster.upsert(databaseManager!.db);

    for (final id in tagIds) {
      ClusterDB.addTagToCluster(databaseManager!.db, id, clusterId);

      //await ref.read(clustersProvider(id).notifier).loadClusters();
      ref
        ..invalidate(clustersProvider(null))
        ..invalidate(clustersProvider(id))
        ..invalidate(itemsByTagIdProvider(DBQueries.byTagID(id)));
    }

    await loadClusters();
    return clusterId;
  }

  /*  void upsertClusters(List<Cluster> clusters) {
    if (databaseManager == null) {
      throw Exception("DB Manager is not ready");
    }
    for (var cluster in clusters) {
      cluster.upsert(databaseManager!.db);
    }
    loadClusters();
  } */

  void deleteCluster(Cluster cluster) {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }

    cluster.delete(databaseManager!.db);
    loadClusters();
  }

  void deleteClusters(List<Cluster> clusters) {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }
    for (final cluster in clusters) {
      cluster.delete(databaseManager!.db);
    }
    loadClusters();
  }
}

final clustersProvider =
    StateNotifierProvider.family<ClustersNotifier, AsyncValue<Clusters>, int?>(
        (ref, clusterID) {
  final dbManagerAsync = ref.watch(dbManagerProvider);
  return dbManagerAsync.when(
    data: (DatabaseManager dbManager) => ClustersNotifier(
      ref: ref,
      databaseManager: dbManager,
      tagID: clusterID,
    ),
    error: (_, __) => ClustersNotifier(
      ref: ref,
    ),
    loading: () => ClustersNotifier(
      ref: ref,
    ),
  );
});
