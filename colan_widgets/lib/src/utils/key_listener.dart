import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CLKeyListener extends StatefulWidget {
  const CLKeyListener({required this.child, required this.onEsc, super.key});
  final Widget child;
  final VoidCallback? onEsc;

  @override
  CLKeyListenerState createState() => CLKeyListenerState();
}

class CLKeyListenerState extends State<CLKeyListener> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          if (widget.onEsc != null) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              widget.onEsc!();
            }
          }
        }
      },
      child: widget.child,
    );
  }
}
