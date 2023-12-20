import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cluster.dart';
import '../models/db.dart';
import 'db_manager.dart';

class ClusterNotifier extends StateNotifier<AsyncValue<Clusters>> {
  DatabaseManager? databaseManager;
  int? clusterID;

  bool isLoading = false;
  ClusterNotifier({
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

  void upsertCluster(Cluster cluster) {
    if (databaseManager == null) {
      throw Exception("DB Manager is not ready");
    }

    cluster.upsert(databaseManager!.db);

    loadClusters();
  }

  void upsertClusters(List<Cluster> clusters) {
    if (databaseManager == null) {
      throw Exception("DB Manager is not ready");
    }
    for (var cluster in clusters) {
      cluster.upsert(databaseManager!.db);
    }
    loadClusters();
  }

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
        (ref, clusterId) {
  final dbManagerAsync = ref.watch(dbManagerProvider);
  return dbManagerAsync.when(
    data: (DatabaseManager dbManager) =>
        ClusterNotifier(databaseManager: dbManager, clusterID: clusterId),
    error: (_, __) => ClusterNotifier(),
    loading: () => ClusterNotifier(),
  );
});
