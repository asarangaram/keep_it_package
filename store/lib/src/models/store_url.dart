import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:store/extensions.dart';

import 'data_types.dart';

@immutable
class StoreURL {
  const StoreURL(this.uri, {required this.identity});

  factory StoreURL.fromMap(Map<String, dynamic> map) {
    return StoreURL(
      Uri.parse(map['uri'] as String),
      identity: map['identity'] != null ? map['identity'] as String : null,
    );
  }

  factory StoreURL.fromJson(String source) =>
      StoreURL.fromMap(json.decode(source) as Map<String, dynamic>);

  factory StoreURL.fromString(String url, {required String? identity}) {
    return StoreURL(Uri.parse(url), identity: identity);
  }
  final Uri uri;
  final String? identity;
  String get scheme => uri.scheme;
  String get name =>
      identity?.capitalizeFirstLetter() ??
      (uri.host.isNotEmpty ? uri.host : uri.path);

  @override
  bool operator ==(covariant StoreURL other) {
    if (identical(this, other)) return true;

    return other.uri == uri && other.identity == identity;
  }

  @override
  int get hashCode => uri.hashCode ^ identity.hashCode;

  @override
  String toString() => 'StoreURL(uri: $uri, identity: $identity)';

  StoreURL copyWith({
    Uri? uri,
    ValueGetter<String?>? identity,
  }) {
    return StoreURL(
      uri ?? this.uri,
      identity: identity != null ? identity.call() : this.identity,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uri': '$uri',
      if (identity != null) 'identity': identity
    };
  }

  String toJson() => json.encode(toMap());
}
