import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final uuidProvider = StateProvider<Uuid>((ref) {
  return const Uuid();
});
