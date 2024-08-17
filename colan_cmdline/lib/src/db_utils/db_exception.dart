import 'package:meta/meta.dart';

enum DBErrorCode {
  unknownDBException,
  autoIncrementIdViolationException,
  updateWithoutIdException,
  deleteWithoutIdException,
  mergeFailedException,
  executionFailed,
}

@immutable
class DBException implements Exception {
  const DBException([this.errorCode = DBErrorCode.unknownDBException]);
  final DBErrorCode errorCode;

  @override
  String toString() => 'DBException: ${errorCode.name}';
}
