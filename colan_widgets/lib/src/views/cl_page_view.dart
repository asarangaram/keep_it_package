import 'package:flutter/material.dart';

class CLPageView extends StatefulWidget {
  const CLPageView({
    super.key,
    required this.pageBuilder,
    required this.pageMax,
  });
  final int pageMax;
  final Widget Function(BuildContext context, int pageNum) pageBuilder;

  @override
  CLPageViewState createState() => CLPageViewState();
}

class CLPageViewState extends State<CLPageView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.pageMax,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            double value = 1.0;
            if (_pageController.position.haveDimensions) {
              value = _pageController.page! - index;
              value = (1 - (value.abs() * 0.5)).clamp(0.0, 1.0);
            }
            return Center(
              child: child,
            );
          },
          child: widget.pageBuilder(
              context, _currentPage), // Replace with your widgets
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
