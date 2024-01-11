import 'dart:ui' as ui;

extension EXTImage on ui.Image {
  Future<ui.Color> getDominantColor() async {
    final byteData = await toByteData();

    if (byteData != null) {
      final historgram = <int, int>{};
      for (final pixel in byteData.buffer.asUint8List()) {
        historgram[pixel] = (historgram[pixel] ?? 0) + 1;
      }
      final maxValue = historgram.values
          .reduce((value, element) => value > element ? value : element);

      return ui.Color(
        historgram.entries.firstWhere((entry) => entry.value == maxValue).key,
      );
    }
    return const ui.Color(0xFFFFFFFF);
  }
}
