import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateCollection extends ConsumerStatefulWidget {
  const UpdateCollection({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewCollectionState();
}

class _NewCollectionState extends ConsumerState<UpdateCollection> {
  final PageController pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      itemCount: 2,
      itemBuilder: (context, pageNum) {
        return Center(
          child: Text('Page $pageNum'),
        );
      },
    );
  }
}
