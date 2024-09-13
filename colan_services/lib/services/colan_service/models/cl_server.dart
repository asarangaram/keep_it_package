import 'package:http/http.dart' as http;

import 'package:meta/meta.dart';

enum DBSyncStatus {
  success,
  partial,
  serverNotConfigured,
  serverNotReachable,
}

@immutable
abstract class CLServer {
  const CLServer({
    required this.name,
    required this.port,
    this.id,
  });
  final String name;
  final int port;
  final int? id;
  Future<CLServer?> withId({http.Client? client});
  Future<bool> hasConnection({http.Client? client});
  String get identifier;
  Future<String> getEndpoint(String endPoint, {http.Client? client});
  Uri getEndpointURI(String endPoint);

  Future<String?> download(
    String endPoint,
    String targetFilePath, {
    http.Client? client,
  });
}
