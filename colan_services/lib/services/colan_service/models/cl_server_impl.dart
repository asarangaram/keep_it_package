// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:store/store.dart';
import 'cl_server.dart';
import 'rest_api.dart';

@immutable
class CLServerImpl extends CLServer {
  const CLServerImpl({
    required super.name,
    required super.port,
    super.id,
  });

  CLServerImpl copyWith({
    String? name,
    int? port,
    int? id,
  }) {
    return CLServerImpl(
      name: name ?? super.name,
      port: port ?? super.port,
      id: id ?? super.id,
    );
  }

  @override
  String toString() => 'CLServerImpl(name: $name, port: $port, id: $id)';

  @override
  bool operator ==(covariant CLServerImpl other) {
    if (identical(this, other)) return true;

    return other.name == name && other.port == port && other.id == id;
  }

  @override
  int get hashCode => name.hashCode ^ port.hashCode ^ id.hashCode;

  @override
  Future<CLServerImpl?> withId({http.Client? client}) async {
    try {
      final id =
          await RestApi('http://$name:$port', client: client).getURLStatus();
      if (id == null) {
        throw Exception('Missing id');
      }
      return copyWith(id: id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> hasConnection({http.Client? client}) async {
    try {
      final id =
          await RestApi('http://$name:$port', client: client).getURLStatus();
      return this.id != null && this.id == id;
    } catch (e) {
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

  factory CLServerImpl.fromMap(Map<String, dynamic> map) {
    return CLServerImpl(
      name: map['name'] as String,
      port: map['port'] as int,
      id: map['id'] != null ? map['id'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CLServerImpl.fromJson(String source) =>
      CLServerImpl.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
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

  @override
  Uri getEndpointURI(String endPoint) {
    return Uri.parse('http://$name:$port$endPoint');
  }

  @override
  Future<String> getEndpoint(
    String endPoint, {
    http.Client? client,
  }) async =>
      RestApi('http://$name:$port', client: client).get(endPoint);

  Future<Collections> downloadCollections({
    http.Client? client,
  }) async {
    if (!await hasConnection(client: client)) {
      throw Exception(DBSyncStatus.serverNotReachable.name);
    }
    final collectionJSON = await getEndpoint('/collection', client: client);
    final collections = Collections.fromJson(collectionJSON);
    return Collections(
      collections.entries
          .map(
            (e) => e.copyWith(),
          )
          .toList(),
    );
  }

  @override
  Future<String?> download(
    String endPoint,
    String targetFilePath, {
    http.Client? client,
  }) async {
    return RestApi('http://$name:$port', client: client)
        .download(endPoint, targetFilePath);
  }
}
