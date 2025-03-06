// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:server/server.dart';
import 'package:server_test/providers/server.dart';

final serverMediaProvider =
    StateNotifierProvider<ServerMediaNotifier, ServerMedia?>((ref) {
  final server = ref.watch(serverProvider);
  return ServerMediaNotifier(server);
});
