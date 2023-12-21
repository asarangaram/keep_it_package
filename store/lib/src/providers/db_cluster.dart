import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cluster.dart';
import '../models/db.dart';
import 'db_manager.dart';

class ClusterNotifier extends StateNotifier<AsyncValue<Clusters>> {
  DatabaseManager? databaseManager;
  int? clusterID;
  Ref ref;

  bool isLoading = false;
  ClusterNotifier({
    required this.ref,
    this.databaseManager,
    this.clusterID,
  }) : super(const AsyncValue.loading()) {
    loadClusters();
  }

  loadClusters() async {
    if (databaseManager == null) return;
    final List<Cluster> clusters;

    if (clusterID == null) {
      clusters = ClusterDB.getAll(databaseManager!.db);
    } else {
      clusters =
          ClusterDB.getClustersForCollection(databaseManager!.db, clusterID!);
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return Clusters(clusters);
    });
  }

  int upsertCluster(Cluster cluster, List<int> collectionIds) {
    if (databaseManager == null) {
      throw Exception("DB Manager is not ready");
    }

    // Save Cluster and get Cluster ID.
    // Associate it wtih all the CollectionIds
    // invalidate the clusters queries by Collection id for all CollectionIds

    final clusterId = cluster.upsert(databaseManager!.db);

    for (var id in collectionIds) {
      ClusterDB.addCollectionToCluster(databaseManager!.db, id, clusterId);
      //ref.read(clustersProvider(id));
      //ref.invalidate(clustersProvider(id));
    }

    loadClusters();
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
      throw Exception("DB Manager is not ready");
    }

    cluster.delete(databaseManager!.db);
    loadClusters();
  }

  void deleteClusters(List<Cluster> clusters) {
    if (databaseManager == null) {
      throw Exception("DB Manager is not ready");
    }
    for (var cluster in clusters) {
      cluster.delete(databaseManager!.db);
    }
    loadClusters();
  }
}

final clustersProvider =
    StateNotifierProvider.family<ClusterNotifier, AsyncValue<Clusters>, int?>(
        (ref, clusterID) {
  final dbManagerAsync = ref.watch(dbManagerProvider);
  return dbManagerAsync.when(
    data: (DatabaseManager dbManager) => ClusterNotifier(
        ref: ref, databaseManager: dbManager, clusterID: clusterID),
    error: (_, __) => ClusterNotifier(
      ref: ref,
    ),
    loading: () => ClusterNotifier(
      ref: ref,
    ),
  );
});
