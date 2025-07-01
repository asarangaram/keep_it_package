import 'package:meta/meta.dart';

import '../cl_basic_types.dart';

abstract class CLMediaContent {
  const CLMediaContent();

  String get identity;
}

@immutable
class CLMediaText extends CLMediaContent {
  final String text;
  final CLMediaType type;
  const CLMediaText(this.text) : type = CLMediaType.text;

  @override
  String get identity => text;
}

@immutable
class CLMediaURI extends CLMediaContent {
  final Uri uri;
  final CLMediaType type;
  const CLMediaURI(this.uri) : type = CLMediaType.uri;
  @override
  String get identity => uri.toString();
}

@immutable
class CLMediaUnknown extends CLMediaContent {
  final String path;
  final CLMediaType type;
  const CLMediaUnknown(this.path) : type = CLMediaType.unknown;

  @override
  String get identity => path;
}
