import 'package:meta/meta.dart';

@immutable
class DownloaderStatus {
  const DownloaderStatus({
    this.running = 0,
    this.waiting = 0,
    this.completed = 0,
    this.unknown = 0,
  });
  final int running;
  final int waiting;
  final int completed;
  final int unknown;

  int get active => running + waiting;
  int get total => active + completed;

  DownloaderStatus copyWith({
    int? running,
    int? waiting,
    int? completed,
    int? unknown,
  }) {
    return DownloaderStatus(
      running: running ?? this.running,
      waiting: waiting ?? this.waiting,
      completed: completed ?? this.completed,
      unknown: unknown ?? this.unknown,
    );
  }

  @override
  bool operator ==(covariant DownloaderStatus other) {
    if (identical(this, other)) return true;

    return other.running == running &&
        other.waiting == waiting &&
        other.completed == completed &&
        other.unknown == unknown;
  }

  @override
  int get hashCode {
    return running.hashCode ^
        waiting.hashCode ^
        completed.hashCode ^
        unknown.hashCode;
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'DownloaderStatus(running: $running, waiting: $waiting, completed: $completed, unknown: $unknown)';
  }
}
