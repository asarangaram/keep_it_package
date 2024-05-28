import 'dart:async';

import 'package:flutter/material.dart';

const int _standardWaitTime = 5;

class ActOnLongPress extends StatefulWidget {
  const ActOnLongPress({
    required this.action,
    this.buttonLabel = 'Press me long',
    this.waitLabel = 'Please wait',
    super.key,
  });
  final String waitLabel;
  final String buttonLabel;
  final Future<void> Function() action;

  @override
  State<ActOnLongPress> createState() => ActOnLongPressState();
}

class ActOnLongPressState extends State<ActOnLongPress> {
  bool isResetting = false;
  @override
  Widget build(BuildContext context) {
    if (isResetting) {
      return Text(widget.waitLabel);
    }
    return LongPressButton(
      onLongPress: () async {
        setState(() {
          isResetting = true;
        });
        await widget.action();
        setState(() {
          isResetting = false;
        });
      },
      seconds: _standardWaitTime,
      child: Text(widget.buttonLabel),
    );
  }
}

class LongPressButton extends StatefulWidget {
  const LongPressButton({
    required this.onLongPress,
    required this.child,
    required this.seconds,
    super.key,
  });
  final VoidCallback onLongPress;
  final Widget child;
  final int seconds;

  @override
  LongPressButtonState createState() => LongPressButtonState();
}

class LongPressButtonState extends State<LongPressButton> {
  Timer? _timer;
  late int _remainingTime;

  @override
  void initState() {
    _remainingTime = widget.seconds;
    super.initState();
  }

  void _startTimer() {
    setState(() {
      _remainingTime = widget.seconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer!.cancel();
          widget.onLongPress();
        }
      });
    });
  }

  void _cancelTimer() {
    if (_timer != null) {
      _timer!.cancel();
      setState(() {
        _remainingTime = widget.seconds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) => _startTimer(),
      onLongPressEnd: (details) => _cancelTimer(),
      onLongPressCancel: _cancelTimer,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: widget.onLongPress,
            child: widget.child,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Continue pressing for $_remainingTime seconds',
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}
