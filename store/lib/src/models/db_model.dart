import 'package:meta/meta.dart';

@immutable
// ignore: one_member_abstracts need this class
abstract class DBModel {
  const DBModel();

  Future<void> dispose();
}
