/* import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';

@immutable
class NotesTheme {
  const NotesTheme({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.borderRadius,
    required this.margin,
    required this.padding,
    required this.borderStyle,
    required this.textStyle,
    required this.playerWaveStyle,
    required this.continuousWaveform,
  });
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final double borderRadius;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final BorderStyle borderStyle;
  final TextStyle textStyle;
  final PlayerWaveStyle playerWaveStyle;
  final bool continuousWaveform;

  NotesTheme copyWith({
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    double? borderRadius,
    EdgeInsets? margin,
    EdgeInsets? padding,
    BorderStyle? borderStyle,
    TextStyle? textStyle,
    PlayerWaveStyle? playerWaveStyle,
    bool? continuousWaveform,
  }) {
    return NotesTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderRadius: borderRadius ?? this.borderRadius,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      borderStyle: borderStyle ?? this.borderStyle,
      textStyle: textStyle ?? this.textStyle,
      playerWaveStyle: playerWaveStyle ?? this.playerWaveStyle,
      continuousWaveform: continuousWaveform ?? this.continuousWaveform,
    );
  }

  @override
  String toString() {
    return 'NotesTheme(backgroundColor: $backgroundColor, foregroundColor: $foregroundColor, borderColor: $borderColor, borderRadius: $borderRadius, margin: $margin, padding: $padding, borderStyle: $borderStyle, textStyle: $textStyle, playerWaveStyle: $playerWaveStyle, continuousWaveform: $continuousWaveform)';
  }

  @override
  bool operator ==(covariant NotesTheme other) {
    if (identical(this, other)) return true;

    return other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.borderColor == borderColor &&
        other.borderRadius == borderRadius &&
        other.margin == margin &&
        other.padding == padding &&
        other.borderStyle == borderStyle &&
        other.textStyle == textStyle &&
        other.playerWaveStyle == playerWaveStyle &&
        other.continuousWaveform == continuousWaveform;
  }

  @override
  int get hashCode {
    return backgroundColor.hashCode ^
        foregroundColor.hashCode ^
        borderColor.hashCode ^
        borderRadius.hashCode ^
        margin.hashCode ^
        padding.hashCode ^
        borderStyle.hashCode ^
        textStyle.hashCode ^
        playerWaveStyle.hashCode ^
        continuousWaveform.hashCode;
  }
}

class DefaultNotesTheme extends NotesTheme {
  const DefaultNotesTheme()
      : super(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF343145),
          borderColor: const Color(0xFF343145),
          borderRadius: 8,
          margin: const EdgeInsets.only(left: 20, bottom: 10, right: 20),
          padding: const EdgeInsets.only(
            bottom: 9,
            top: 8,
            left: 14,
            right: 12,
          ),
          borderStyle: BorderStyle.solid,
          textStyle: const TextStyle(fontSize: 20),
          playerWaveStyle: const PlayerWaveStyle(
            spacing: 6,
            liveWaveColor: Colors.brown,
            fixedWaveColor: Colors.green,
            seekLineColor: Colors.red,
            backgroundColor: Colors.blue,
          ),
          continuousWaveform: true,
        );
}

class DefaultNotesInputTheme extends NotesTheme {
  const DefaultNotesInputTheme()
      : super(
          backgroundColor: const Color(0xFF343145),
          foregroundColor: Colors.white,
          borderColor: Colors.transparent,
          borderRadius: 8,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          borderStyle: BorderStyle.none,
          textStyle: const TextStyle(fontSize: 20),
          playerWaveStyle: const PlayerWaveStyle(
            spacing: 6,
          ),
          continuousWaveform: true,
        );
}
 */
