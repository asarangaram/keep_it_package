import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecorder extends StatefulWidget {
  const AudioRecorder({super.key});

  @override
  AudioRecorderState createState() => AudioRecorderState();
}

class AudioRecorderState extends State<AudioRecorder> {
  late FlutterAudioRecorder2? _recorder;
  Recording? _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  final List<double> _waveData = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      if (await FlutterAudioRecorder2.hasPermissions ?? false) {
        var customPath = '/flutter_audio_recorder_';
        Directory appDocDirectory;

        appDocDirectory = await getApplicationDocumentsDirectory();

        customPath = appDocDirectory.path +
            customPath +
            DateTime.now().millisecondsSinceEpoch.toString();
        _recorder =
            FlutterAudioRecorder2(customPath, audioFormat: AudioFormat.WAV);
        await _recorder!.initialized;
        final current = await _recorder!.current();
        setState(() {
          _current = current;
          _currentStatus = current!.status!;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You must accept permissions')),
          );
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: SizedBox(
            height: 128,
            child: ClipRect(
              child: CustomPaint(
                painter: WaveformPainter(_waveData),
                child: Container(
                  decoration:
                      BoxDecoration(color: Colors.red.shade100.withAlpha(100)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                switch (_currentStatus) {
                  case RecordingStatus.Initialized:
                  case RecordingStatus.Stopped:
                    _start();
                  case RecordingStatus.Recording:
                    _pause();
                  case RecordingStatus.Paused:
                    _resume();

                  case RecordingStatus.Unset:
                    break;
                }
              },
              child: Text(
                _currentStatus == RecordingStatus.Recording
                    ? 'Pause'
                    : _currentStatus == RecordingStatus.Paused
                        ? 'Resume'
                        : 'Record',
              ),
            ),
            const SizedBox(width: 20),
            if (_currentStatus == RecordingStatus.Recording ||
                _currentStatus == RecordingStatus.Paused)
              ElevatedButton(
                onPressed: _stop,
                child: const Text('Stop'),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _start() async {
    try {
      await _recorder!.start();
      final recording = await _recorder!.current();
      setState(() {
        _current = recording;
      });
      const tick = Duration(milliseconds: 50);
      Timer.periodic(tick, (Timer t) async {
        if (_currentStatus == RecordingStatus.Stopped) {
          t.cancel();
        }
        final current = await _recorder!.current();
        setState(() {
          _current = current;
          _currentStatus = _current!.status!;
          if (_current!.metering!.averagePower != null) {
            _waveData.add(_current!.metering!.averagePower!);
          }
        });
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _pause() async {
    await _recorder!.pause();
    setState(() {
      _currentStatus = RecordingStatus.Paused;
    });
  }

  Future<void> _resume() async {
    await _recorder!.resume();
    setState(() {
      _currentStatus = RecordingStatus.Recording;
    });
  }

  Future<void> _stop() async {
    final result = await _recorder!.stop();
    setState(() {
      _current = result;
      _currentStatus = _current!.status!;
    });
  }
}

class WaveformPainter extends CustomPainter {
  WaveformPainter(this.waveData);
  final List<double> waveData;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    final centerY = size.height / 2;
    final scaleX = size.width / (waveData.length - 1);
    final scaleY = size.height / 2;

    for (var i = 0; i < waveData.length; i++) {
      final x = i * scaleX;
      final y = centerY + waveData[i] * scaleY;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
