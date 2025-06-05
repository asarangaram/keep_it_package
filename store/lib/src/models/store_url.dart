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
  String toString() => '$uri';
}
