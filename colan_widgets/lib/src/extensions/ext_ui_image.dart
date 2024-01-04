import 'dart:typed_data';
import 'dart:ui' as ui;

extension EXTImage on ui.Image {
  Future<ui.Color> getDominantColor() async {
    final ByteData? byteData = await toByteData();

    if (byteData != null) {
      final Map<int, int> historgram = {};
      for (var pixel in byteData.buffer.asUint8List()) {
        historgram[pixel] = (historgram[pixel] ?? 0) + 1;
      }
      int maxValue = historgram.values
          .reduce((value, element) => value > element ? value : element);

      return ui.Color(historgram.entries
          .firstWhere((entry) => entry.value == maxValue)
          .key);
    }
    return const ui.Color(0xFFFFFFFF);
  }
}
