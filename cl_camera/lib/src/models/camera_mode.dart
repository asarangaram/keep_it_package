enum CameraMode {
  photo,
  video;

  bool get isVideo => [video].contains(this);
}
