extension ExtIntOnStringNullable on String? {
  int? toInt() {
    if (this == null) return null;
    return int.parse(this!);
  }
}
