import 'package:flutter/material.dart';

class MyGridView extends StatelessWidget {
  final int itemCount = 50;

  const MyGridView({super.key}); // Number of items

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      scrollDirection: Axis.horizontal,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: 20,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {},
          onLongPress: () {},
          child: Text("item ${index + 1} ${"sfds " * (index % 3 + 1)}"),
        );
      },
    );
  }
}
