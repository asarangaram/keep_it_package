// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:meta/meta.dart';

@immutable
class StoreURL {
  const StoreURL(this.uri);
  factory StoreURL.fromString(String url) {
    return StoreURL(Uri.parse(url));
  }
  final Uri uri;
  String get scheme => uri.scheme;
  String get name => uri.host.isNotEmpty ? uri.host : uri.path;

  @override
  bool operator ==(covariant StoreURL other) {
    if (identical(this, other)) return true;

    return other.uri == uri;
  }

  @override
  int get hashCode => uri.hashCode;

  @override
  String toString() => 'StoreURL(uri: $uri)';

  StoreURL copyWith({
    Uri? uri,
  }) {
    return StoreURL(
      uri ?? this.uri,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uri': '$uri',
    };
  }

  factory StoreURL.fromMap(Map<String, dynamic> map) {
    return StoreURL(
      Uri.parse(map['uri'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory StoreURL.fromJson(String source) =>
      StoreURL.fromMap(json.decode(source) as Map<String, dynamic>);
}
