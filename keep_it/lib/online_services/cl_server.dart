import 'package:flutter/foundation.dart';

@immutable
class CLServer {
  const CLServer({required this.name, required this.port});

  final String name;
  final int port;

  CLServer copyWith({
    String? name,
    int? port,
  }) {
    return CLServer(
      name: name ?? this.name,
      port: port ?? this.port,
    );
  }

  @override
  String toString() => 'CLServer(name: $name, port: $port)';

  @override
  bool operator ==(covariant CLServer other) {
    if (identical(this, other)) return true;

    return other.name == name && other.port == port;
  }

  @override
  int get hashCode => name.hashCode ^ port.hashCode;

  Future<bool> get hasResonse async {
    return true;
  }
}
