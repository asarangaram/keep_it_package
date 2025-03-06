import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/base_scaffold.dart';
import 'widgets/registered_server.dart';

class RegisterredServerView extends ConsumerStatefulWidget {
  const RegisterredServerView({super.key});

  @override
  ConsumerState<RegisterredServerView> createState() =>
      _RegisterredServerViewState();
}

class _RegisterredServerViewState extends ConsumerState<RegisterredServerView> {
  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
        appBarTitle: 'KeepIt Media Viewer', children: [RegisterredServer()]);
  }
}
