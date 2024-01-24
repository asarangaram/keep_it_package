import 'package:flutter/material.dart';

class CLPageView extends StatefulWidget {
  const CLPageView({
    required this.pageBuilder,
    required this.pageMax,
    super.key,
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
        return widget.pageBuilder(
          context,
          _currentPage,
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
