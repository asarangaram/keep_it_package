import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/server.dart';
import '../models/server_media.dart';
import 'server.dart';

class ServerMediaNotifier extends StateNotifier<ServerMedia> {
  ServerMediaNotifier(this.server, {int perPage = 5})
      : super(ServerMedia.reset(perPage)) {
    initialize();
  }
  final ServerBasic server;

  Future<void> initialize() async {
    if (server.canSync) {
      state = state.copyWith(isLoading: true);
      final map = await server.identity!
          .fetchMediaPage(perPage: 5, page: 1, types: ['image']);
      state = ServerMedia.fromMap(map);
    }
  }

  Future<void> fetchNextPage() async {
    if (server.canSync &&
        state.metaInfo.pagination.hasNext &&
        !state.isLoading) {
      state = state.copyWith(isLoading: true);
      final map = await server.identity!.fetchMediaPage(
          perPage: state.metaInfo.pagination.perPage,
          page: state.metaInfo.pagination.currentPage + 1,
          currentVersion: state.metaInfo.currentVersion,
          lastSyncedVersion: state.metaInfo.lastSyncedVersion,
          types: ['image']);
      final currentPage = ServerMedia.fromMap(map);

      state = state.copyWith(
          items: [...state.items, ...currentPage.items],
          metaInfo: currentPage.metaInfo,
          isLoading: false);
    }
  }

  Future<void> refresh() async {
    if (server.canSync && !state.isLoading) {
      final map = await server.identity!.fetchMediaPage(
          perPage: 5,
          page: 1,
          types: ['image'],
          currentVersion: state.metaInfo.latestVersion);
      state = ServerMedia.fromMap(map);
    }
  }

  static void log(
    String message, {
    int level = 0,
    Object? error,
    StackTrace? stackTrace,
  }) {
    dev.log(
      message,
      level: level,
      error: error,
      stackTrace: stackTrace,
      name: 'Online Service: Network Scanner',
    );
  }
}

final serverMediaProvider =
    StateNotifierProvider<ServerMediaNotifier, ServerMedia>((ref) {
  final server = ref.watch(serverProvider);
  // ignore: deprecated_member_use
  ref.listenSelf((prev, curr) {
    ServerMediaNotifier.log(curr.items.length.toString());
  });
  return ServerMediaNotifier(server);
});
