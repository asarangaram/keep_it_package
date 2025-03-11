import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:server/server.dart';

import 'package:shadcn_ui/shadcn_ui.dart';
import '../common/base_scaffold.dart';

class ServerSelectorView extends ConsumerStatefulWidget {
  const ServerSelectorView({super.key});

  @override
  ConsumerState<ServerSelectorView> createState() => _ServerSelectorViewState();
}

class _ServerSelectorViewState extends ConsumerState<ServerSelectorView> {
  late final ShadPopoverController popoverController;
  late CLServer customServer;

  @override
  void initState() {
    popoverController = ShadPopoverController();
    super.initState();
  }

  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = ShadTheme.of(context).textTheme;
    final scanner = ref.watch(networkScannerProvider);
    return BaseScaffold(
      appBarTitleWidget: ListTile(
        leading: SizedBox.shrink(),
        title: Text('KeepIt Media Viewer'),
        titleTextStyle: textTheme.h4,
      ),
      children: [
        if (!scanner.lanStatus)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ShadAlert.destructive(
              iconData: Icons.network_check, // network off !!
              title: Text('Offline'),
              description: Text(
                  'You are not connected to any Home Network. Check your connection and try again.'),
            ),
          )
        else ...[
          Text(
            "Setup a CoLAN server and connect to it. "
            "If you can't see your server, you may enter the address manually",
            style: textTheme.large,
          ),
          if (scanner.servers == null)
            const CircularProgressIndicator.adaptive()
          else
            ShadPopover(
              controller: popoverController,
              popover: (_) => SizedBox(
                  width: 288,
                  child: ServerSelectionForm(
                    onRefresh:
                        ref.watch(networkScannerProvider.notifier).search,
                    onDone: (selectedServer) {
                      ref
                          .read(serverProvider.notifier)
                          .register(selectedServer);
                      popoverController.toggle();
                    },
                  )),
              child: ShadButton.outline(
                onPressed: popoverController.toggle,
                child: const Text('Connect to server'),
              ),
            ),
        ]
      ],
    );
  }
}
