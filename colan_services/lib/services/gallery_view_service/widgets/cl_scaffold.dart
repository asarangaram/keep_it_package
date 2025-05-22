import 'package:flutter/material.dart';

class CLScaffold extends StatelessWidget {
  const CLScaffold({
    required this.topMenu,
    required this.bottomMenu,
    required this.banners,
    required this.body,
    super.key,
  });
  final PreferredSizeWidget topMenu;
  final PreferredSizeWidget bottomMenu;
  final List<Widget> banners;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: topMenu,
      body: Column(
        children: [
          ...banners,
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: (MediaQuery.of(context).viewInsets.bottom == 0)
          ? SizedBox.fromSize(
              size: bottomMenu.preferredSize,
              child: ColoredBox(
                color: Colors.amber,
                child: bottomMenu,
              ),
            )
          : null,
    );
  }
}
