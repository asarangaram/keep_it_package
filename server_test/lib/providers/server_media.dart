// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:server/server.dart';

final serverMediaProvider =
    StateNotifierProvider<ServerMediaNotifier, ServerMedia?>((ref) {
  CLServer server = CLServer(address: '192.168.1.6', port: 5000);
  return ServerMediaNotifier(server);
});
