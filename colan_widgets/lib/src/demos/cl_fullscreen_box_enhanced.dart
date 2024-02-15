import 'package:flutter/material.dart';

class CLFullscreenBoxEnhanced extends StatefulWidget {
  const CLFullscreenBoxEnhanced({
    required this.navMap,
    required this.currentIndex,
    super.key,
    this.useSafeArea = false,
    this.backgroundColor,
    this.hasBorder = false,
    this.onPageChange,
  });
  final bool useSafeArea;
  final Color? backgroundColor;
  final bool hasBorder;
  final int currentIndex;
  final void Function(int index)? onPageChange;

  final Map<BottomNavigationBarItem, Widget> navMap;

  @override
  State<StatefulWidget> createState() => _CLFullscreenBoxEnhancedState();
}

class _CLFullscreenBoxEnhancedState extends State<CLFullscreenBoxEnhanced> {
  late int currentIndex;
  @override
  void initState() {
    currentIndex = widget.currentIndex;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    currentIndex = widget.currentIndex;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        items: widget.navMap.keys.toList(),
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
          widget.onPageChange?.call(currentIndex);
        },
      ),
      body: SafeArea(
        top: widget.useSafeArea,
        left: widget.useSafeArea,
        right: widget.useSafeArea,
        bottom: widget.useSafeArea,
        child: ClipRect(
          clipBehavior: Clip.antiAlias,
          child: _ScaffoldBorder(
            hasBorder: widget.hasBorder,
            child: LayoutBuilder(
              builder: (context, constraints) =>
                  widget.navMap.values.toList()[currentIndex],
            ),
          ),
        ),
      ),
    );
  }
}

//Duplicated
class _ScaffoldBorder extends StatelessWidget {
  const _ScaffoldBorder({
    required this.hasBorder,
    required this.child,
  });
  final bool hasBorder;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (!hasBorder) return child;
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: child,
    );
  }
}
