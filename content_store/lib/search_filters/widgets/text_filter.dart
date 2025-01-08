import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TextFilterView extends ConsumerStatefulWidget {
  const TextFilterView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TextFilterViewState();
}

class _TextFilterViewState extends ConsumerState<TextFilterView> {
  late final TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Text('TextFilterView');
  }
}
