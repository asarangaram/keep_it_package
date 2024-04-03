enum CameraMode {
  photo,
  video;

  bool get isVideo => [video].contains(this);

  String get capitalizedName => '${name[0].toUpperCase()}${name.substring(1)}';
}
