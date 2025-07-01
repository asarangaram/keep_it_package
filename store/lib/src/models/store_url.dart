import 'dart:convert';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:meta/meta.dart';
import 'package:store/extensions.dart';

@immutable
class StoreURL {
  const StoreURL(this.uri, {required this.identity, required this.label});

  factory StoreURL.fromMap(Map<String, dynamic> map) {
    return StoreURL(
      Uri.parse(map['uri'] as String),
      identity: map['identity'] != null ? map['identity'] as String : null,
      label: map['label'] != null ? map['label'] as String : null,
    );
  }

  factory StoreURL.fromJson(String source) =>
      StoreURL.fromMap(json.decode(source) as Map<String, dynamic>);

  factory StoreURL.fromString(String url,
      {required String? identity, required String? label}) {
    return StoreURL(Uri.parse(url), identity: identity, label: label);
  }
  final Uri uri;
  final String? identity;
  final String? label;
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
  String toString() =>
      'StoreURL(uri: $uri, identity: $identity, label: $label)';

  StoreURL copyWith({
    Uri? uri,
    ValueGetter<String?>? identity,
    ValueGetter<String?>? label,
  }) {
    return StoreURL(
      uri ?? this.uri,
      identity: identity != null ? identity.call() : this.identity,
      label: label != null ? label.call() : this.label,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uri': '$uri',
      'identity': identity,
      'label': label,
    };
  }

  String toJson() => json.encode(toMap());
}
