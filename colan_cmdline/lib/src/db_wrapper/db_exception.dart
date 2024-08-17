import 'package:meta/meta.dart';

enum DBErrorCode {
  unknownDBException,
  autoIncrementIdViolationException,
  updateWithoutIdException,
  deleteWithoutIdException
}

@immutable
class DBException implements Exception {
  const DBException([this.errorCode = DBErrorCode.unknownDBException]);
  final DBErrorCode errorCode;

  @override
  String toString() => 'DBException: ${errorCode.name}';
}
