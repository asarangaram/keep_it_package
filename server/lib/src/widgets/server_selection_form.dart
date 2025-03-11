import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store_revised/store_revised.dart';

import '../models/cl_server.dart';
import '../providers/scanner.dart';

class ServerSelectionForm extends ConsumerStatefulWidget {
  const ServerSelectionForm(
      {super.key, required this.onRefresh, required this.onDone});
  final VoidCallback onRefresh;
  final void Function(CLServer selectedServer) onDone;

  @override
  ConsumerState<ServerSelectionForm> createState() =>
      _ServerSelectionFormState();
}

class _ServerSelectionFormState extends ConsumerState<ServerSelectionForm> {
  bool enabled = true;
  var autovalidateMode = ShadAutovalidateMode.onUserInteraction;
  Map<Object, dynamic> formValue = {};
  final formKey = GlobalKey<ShadFormState>();
  CLServer? selectedServer;
  String? error;

  @override
  Widget build(BuildContext context) {
    final scanner = ref.watch(networkScannerProvider);
    final List<CLServer> servers = [
      ...([
        ...scanner.servers!,
      ]..sort()),
      CLServer(address: 'myserver.local', port: -1)
    ];
    final textTheme = ShadTheme.of(context).textTheme;
    return ShadForm(
      key: formKey,
      enabled: enabled,
      autovalidateMode: autovalidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...[
            Align(
              alignment: Alignment.centerRight,
              child: ShadButton.ghost(
                onPressed: widget.onRefresh,
                child: Text('\u21BA Refresh',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
            ...[
              ShadRadioGroupFormField<CLServer>(
                enabled: true,
                initialValue: null,
                id: 'server',
                onChanged: (v) {
                  if (v != selectedServer) {
                    setState(() {
                      selectedServer = v;
                    });
                  }
                },
                validator: (v) {
                  if (v == null) {
                    return 'You have not selected any server';
                  }
                  return null;
                },
                axis: Axis.vertical,
                items: servers.map(
                  (e) => ShadRadio(
                    enabled: e.id != null || e.port == -1,
                    value: e,
                    label: Text(
                      e.port == -1
                          ? "Enter Manually"
                          : "${e.id?.toString() ?? "???"}(${e.baseURL})",
                      style: (e.id != null || e.port == -1)
                          ? textTheme.small
                          : textTheme.muted,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: ShadInputFormField(
                  id: "manualEntry",
                  placeholder: const Text('Server URL'),
                  enabled: isManual,
                  keyboardType: TextInputType.url,
                  validator: (v) {
                    if (isManual) {
                      if (v.isEmpty) {
                        return "http://host:port";
                      }
                      if (v.isURL()) {
                        return null;
                      }

                      return "invalid address";
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              ShadButton(
                child: const Text('Connect'),
                onPressed: () async {
                  if (formKey.currentState!.saveAndValidate()) {
                    formValue = formKey.currentState!.value;

                    if (formValue.containsKey("server")) {
                      var server = formValue["server"] as CLServer;
                      if (server.port == -1) {
                        final serverurl = Uri.parse(formValue["manualEntry"]);
                        server = CLServer(
                            address: serverurl.host, port: serverurl.port);
                      }
                      //
                      final serverWithID = await server.withId();
                      if (serverWithID != null) {
                        widget.onDone(serverWithID);

                        return;
                      }
                    } else {
                      if (kDebugMode) {
                        print(formValue);
                      }
                    }
                  } else {
                    error = "serverNotfound";
                  }
                },
              ),
              if (error != null)
                ShadBadge.destructive(child: Text("Failed to connect to host")),
              if (formValue.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 24, left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FormValue', style: textTheme.p),
                      const SizedBox(height: 4),
                      SelectableText(
                        const JsonEncoder.withIndent('    ').convert(formValue),
                        style: textTheme.small,
                      ),
                    ],
                  ),
                ),
            ]
          ]
        ],
      ),
    );
  }

  bool get isManual => selectedServer?.port == -1;
}
