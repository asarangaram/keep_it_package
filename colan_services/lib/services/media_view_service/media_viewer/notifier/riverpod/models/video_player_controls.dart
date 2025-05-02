abstract class VideoPlayerControls {
  Future<void> setVideo(
    Uri uri, {
    required bool autoPlay,
    required bool forced,
  });
  Future<void> resetVideo({
    required bool autoPlay,
  });

  Future<void> play();
  Future<void> pause();
  Future<void> onPlayPause(
    Uri uri, {
    bool autoPlay = true,
    bool forced = false,
  });

  Future<void> removeVideo();

  Uri? get uri;

  Future<void> onAdjustVolume(
    double value,
  );
  Future<void> onToggleAudioMute();

  Future<void> seekTo(Duration position);
}
