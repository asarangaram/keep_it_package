import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:store_revised/store_revised.dart';

import 'cl_server_status.dart';
import 'rest_api.dart';

@immutable
class CLServer implements Comparable<CLServer> {
  const CLServer({
    required this.address,
    required this.port,
    this.name,
    this.id,
    this.status,
  });
  factory CLServer.fromMap(Map<String, dynamic> map) {
    return CLServer(
      address: map['address'] as String,
      port: map['port'] as int,
      name: map['name'] != null ? map['name'] as String : null,
      id: map['id'] != null ? map['id'] as int : null,
      status: map['status'] != null
          ? ServerTimeStamps.fromMap(
              map['status'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  factory CLServer.fromJson(String source) =>
      CLServer.fromMap(json.decode(source) as Map<String, dynamic>);

  final String address;
  final int port;
  final String? name;
  final int? id;
  final ServerTimeStamps? status;

  void log(
    String message, {
    int level = 0,
    Object? error,
    StackTrace? stackTrace,
  }) {
    /* dev.log(
      message,
      level: level,
      error: error,
      stackTrace: stackTrace,
      name: 'Online Service: Registered Server',
    ); */
  }

  CLServer copyWith({
    String? address,
    int? port,
    ValueGetter<String?>? name,
    ValueGetter<int?>? id,
    ValueGetter<ServerTimeStamps?>? status,
  }) {
    return CLServer(
      address: address ?? this.address,
      port: port ?? this.port,
      name: name != null ? name.call() : this.name,
      id: id != null ? id.call() : this.id,
      status: status != null ? status.call() : this.status,
    );
  }

  @override
  String toString() {
    return 'CLServer(address: $address, port: $port, name: $name, id: $id, status: $status)';
  }

  @override
  bool operator ==(covariant CLServer other) {
    if (identical(this, other)) return true;

    return other.address == address &&
        other.port == port &&
        other.name == name &&
        other.id == id &&
        other.status == status;
  }

  @override
  int get hashCode {
    return address.hashCode ^
        port.hashCode ^
        name.hashCode ^
        id.hashCode ^
        status.hashCode;
  }

  Future<CLServer?> withId({http.Client? client}) async {
    try {
      final map = await RestApi(baseURL, client: client).getURLStatus();
      final serverMap = toMap()..addAll(map);
      final server = CLServer.fromMap(serverMap);
      if (server.hasID) {
        return server;
      }
      throw Exception('Missing id');
    } catch (e) {
      return null;
    }
  }

  Future<CLServer?> getServerLiveStatus({http.Client? client}) async {
    try {
      final server = await withId(client: client);
      final hasId = server != null && id != null && id == server.id;
      log('has id: $hasId');
      return hasId ? server : null;
    } catch (e) {
      log('has id: failed $e');
      return null;
    }
  }

  bool get hasID => id != null;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'address': address,
      'port': port,
      'name': name,
      'id': id,
      'status': status?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  String get identifier {
    const separator = '_';
    if (id == null) return 'Unknown';

    var hexString = id!.toRadixString(16).toUpperCase();
    hexString = hexString.padLeft(4, '0');
    final formattedHex = hexString.replaceAllMapped(
      RegExp('.{4}'),
      (match) => '${match.group(0)}$separator',
    );
    final identifierString = formattedHex.endsWith(separator)
        ? formattedHex.substring(0, formattedHex.length - 1)
        : formattedHex;
    return identifierString;
  }

  Uri getEndpointURI(String endPoint) {
    return Uri.parse('$baseURL$endPoint');
  }

  Future<String> getEndpoint(
    String endPoint, {
    http.Client? client,
  }) async =>
      RestApi(baseURL, client: client).get(endPoint);

  Future<String> post(
    String endPoint, {
    http.Client? client,
    String? json,
    Map<String, dynamic>? form,
  }) async =>
      RestApi(baseURL, client: client)
          .post(endPoint, json: json ?? '', form: form);

  Future<String> put(
    String endPoint, {
    http.Client? client,
    String? json,
    Map<String, dynamic>? form,
  }) async =>
      RestApi(baseURL, client: client)
          .put(endPoint, json: json ?? '', form: form);

  Future<String> delete(
    String endPoint, {
    http.Client? client,
  }) async =>
      RestApi(baseURL, client: client).delete(endPoint);

  Future<String?> download(
    String endPoint,
    String targetFilePath, {
    http.Client? client,
  }) async {
    return RestApi(baseURL, client: client).download(endPoint, targetFilePath);
  }

  Future<List<Map<String, dynamic>>> downloadMediaInfo({
    http.Client? client,
    List<String>? types,
  }) async {
    try {
      final mediaMapList = [
        for (final mediaType in types ?? ['image', 'video'])
          ...jsonDecode(
            await getEndpoint('/media?type=$mediaType', client: client),
          ) as List<dynamic>,
      ];
      return mediaMapList.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      log('error when downloading $e');
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> downloadCollectionInfo({
    http.Client? client,
  }) async {
    try {
      final mapList = jsonDecode(
        await getEndpoint('/collection', client: client),
      ) as List<dynamic>;
      return mapList.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      log('error when downloading $e');
    }
    return [];
  }

  Future<Map<String, dynamic>> fetchMediaPage({
    String endPoint = '/media/page',
    http.Client? client,
    int page = 1,
    int perPage = 20,
    List<String> types = const [],
    int? currentVersion,
    int? lastSyncedVersion,
  }) async {
    String endPoint0 = "$endPoint?";
    endPoint0 = endPoint0 + types.map((type) => 'type=$type').join('&');
    endPoint0 = '$endPoint0&per_page=$perPage';
    endPoint0 = '$endPoint0&page=$page';
    endPoint0 = '$endPoint0&current_version=$currentVersion';
    endPoint0 = '$endPoint0&last_synced_version=$lastSyncedVersion';

    final response = await getEndpoint(endPoint0, client: client);

    try {
      return jsonDecode(response) as Map<String, dynamic>;
    } catch (e) {
      log('error when fetching $e');
    }
    return {};
  }

  String get baseURL => 'http://$address:$port';

  @override
  int compareTo(CLServer other) {
    if (id != null && other.id != null) {
      return id!.compareTo(other.id!);
    }
    return baseURL.compareTo(other.baseURL);
  }
}
