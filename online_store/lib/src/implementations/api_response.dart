import 'package:meta/meta.dart';

@immutable
abstract class StoreReply<T> {
  StoreReply<M> cast<M>();

  T? getResult() =>
      switch (this) { (final StoreResult<T> t) => t.result, _ => null };

  M when<M>(
      {required M Function(T response) validResponse,
      required M Function(StoreError<T> error) errorResponse}) {
    return switch (this) {
      (final StoreResult<T> response) => validResponse(response.result),
      (final StoreError<T> error) => errorResponse(error),
      StoreReply<T>() => throw UnimplementedError(
          "This can't occur as ServerReply is a abstract  class"),
    };
  }
}

@immutable
class StoreResult<T> extends StoreReply<T> {
  StoreResult(this.result);
  final T result;

  @override
  StoreReply<M> cast<M>() {
    return StoreResult<M>(result as M);
  }
}

@immutable
class StoreError<T> extends StoreReply<T> {
  StoreError(this.error, {this.st, this.errorCode});
  final String error;
  final StackTrace? st;
  final int? errorCode;

  @override
  StoreReply<M> cast<M>() {
    return StoreError<M>(error, st: st, errorCode: errorCode);
  }
}
