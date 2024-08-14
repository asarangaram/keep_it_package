// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:meta/meta.dart';

import 'rest_api.dart';

@immutable
class CLServer {
  const CLServer({
    required this.name,
    required this.port,
    this.id,
  });

  final String name;
  final int port;
  final int? id;

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
  String toString() => 'CLServer(name: $name, port: $port, id: $id)';

  @override
  bool operator ==(covariant CLServer other) {
    if (identical(this, other)) return true;

    return other.name == name && other.port == port && other.id == id;
  }

  @override
  int get hashCode => name.hashCode ^ port.hashCode ^ id.hashCode;

  Future<CLServer?> get withId async {
    try {
      final id = await RestApi('http://$name:$port').getURLStatus();
      if (id == null) {
        throw Exception('Missing id');
      }
      return copyWith(id: id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> get hasConnection async {
    try {
      final id = await RestApi('http://$name:$port').getURLStatus();
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

  factory CLServer.fromMap(Map<String, dynamic> map) {
    return CLServer(
      name: map['name'] as String,
      port: map['port'] as int,
      id: map['id'] != null ? map['id'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CLServer.fromJson(String source) =>
      CLServer.fromMap(json.decode(source) as Map<String, dynamic>);

  Future<String> getEndpoint(String endPoint) async {
    return await RestApi('http://$name:$port').get(endPoint);
  }
}
