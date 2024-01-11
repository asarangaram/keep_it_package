import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cluster.dart';
import '../models/db.dart';
import 'db_manager.dart';

class ClustersNotifier extends StateNotifier<AsyncValue<Clusters>> {
  ClustersNotifier({
    required this.ref,
    this.databaseManager,
    this.collectionID,
  }) : super(const AsyncValue.loading()) {
    loadClusters();
  }
  DatabaseManager? databaseManager;
  int? collectionID;
  Ref ref;

  bool isLoading = false;

  Future<void> loadClusters() async {
    if (databaseManager == null) return;
    final List<Cluster> clusters;

    if (collectionID == null) {
      clusters = ClusterDB.getAll(databaseManager!.db);
    } else {
      clusters = ClusterDB.getClustersForCollection(
        databaseManager!.db,
        collectionID!,
      );
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return Clusters(clusters);
    });
  }

  Future<int> upsertCluster(Cluster cluster, List<int> collectionIds) async {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }

    // Save Cluster and get Cluster ID.
    // Associate it wtih all the CollectionIds
    // invalidate the clusters queries by Collection id for all CollectionIds

    final clusterId = cluster.upsert(databaseManager!.db);

    for (final id in collectionIds) {
      ClusterDB.addCollectionToCluster(databaseManager!.db, id, clusterId);
      //ref.read(clustersProvider(id));
      //ref.invalidate(clustersProvider(id));
      await ref.read(clustersProvider(id).notifier).loadClusters();
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
      collectionID: clusterID,
    ),
    error: (_, __) => ClustersNotifier(
      ref: ref,
    ),
    loading: () => ClustersNotifier(
      ref: ref,
    ),
  );
});
