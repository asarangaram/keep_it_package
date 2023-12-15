enum CLScaleType {
  veryLarge,
  large,
  standard,
  small,
  verySmall,
  tiny;

  double get fontSize => switch (this) {
        CLScaleType.veryLarge => 32,
        CLScaleType.large => 24,
        CLScaleType.standard => 20,
        CLScaleType.small => 16,
        CLScaleType.verySmall => 12,
        CLScaleType.tiny => 10,
      };

  double get iconSize {
    final double size = switch (this) {
      CLScaleType.veryLarge => 32,
      CLScaleType.large => 24,
      CLScaleType.standard => 20,
      CLScaleType.small => 16,
      CLScaleType.verySmall => 12,
      CLScaleType.tiny => 10,
    };
    return size * 2;
  }
}
/*
   CLScaleType.veryLarge => 32,
        CLScaleType.large => 28,
        CLScaleType.standard => 24,
        CLScaleType.small => 20,
        CLScaleType.verySmall => 16,
        CLScaleType.tiny => 12,
        */