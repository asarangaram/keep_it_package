import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import 'rest_api.dart';

@immutable
class CLServer {
  const CLServer({
    required this.name,
    required this.port,
    this.id,
  });
  factory CLServer.fromMap(Map<String, dynamic> map) {
    return CLServer(
      name: map['name'] as String,
      port: map['port'] as int,
      id: map['id'] != null ? map['id'] as int : null,
    );
  }

  factory CLServer.fromJson(String source) =>
      CLServer.fromMap(json.decode(source) as Map<String, dynamic>);

  final String name;
  final int port;
  final int? id;

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
    String? name,
    int? port,
    int? id,
  }) {
    return CLServer(
      name: name ?? this.name,
      port: port ?? this.port,
      id: id ?? this.id,
    );
  }

  @override
  String toString() => 'Server : ${toJson()}';

  @override
  bool operator ==(covariant CLServer other) {
    if (identical(this, other)) return true;

    return other.name == name && other.port == port && other.id == id;
  }

  @override
  int get hashCode => name.hashCode ^ port.hashCode ^ id.hashCode;

  Future<CLServer?> withId({http.Client? client}) async {
    try {
      final id = await RestApi(baseURL, client: client).getURLStatus();
      if (id == null) {
        throw Exception('Missing id');
      }
      return copyWith(id: id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> hasConnection({http.Client? client}) async {
    try {
      final id = await RestApi(baseURL, client: client).getURLStatus();
      final hasId = this.id != null && this.id == id;
      log('has id: $hasId');
      return hasId;
    } catch (e) {
      log('has id: failed $e');
      return false;
    }
  }

  bool get hasID => id != null;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'port': port,
      'id': id,
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
      final mapList = [
        jsonDecode(
          await getEndpoint('/collection', client: client),
        ) as List<dynamic>,
      ];
      return mapList.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      log('error when downloading $e');
    }
    return [];
  }

  String get baseURL => 'http://$name:$port';
}
