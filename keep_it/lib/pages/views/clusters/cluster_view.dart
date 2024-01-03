import 'dart:io';

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../load_from_store/load_items.dart';

class ClusterView extends ConsumerWidget {
  const ClusterView({super.key, required this.cluster});
  final Cluster cluster;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes =
        (cluster.description.isEmpty) ? "No Description" : cluster.description;
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AspectRatio(
              aspectRatio: 1.0,
              child: LoadItems(
                clusterID: cluster.id,
                hasBackground: false,
                buildOnData: (items) {
                  return FutureBuilder(
                      future: FileHandler.getDocumentsDirectory(null),
                      builder: ((context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        final docDirectory = snapshot.data;
                        final File f;

                        f = File("$docDirectory/${items.entries[0].path}");
                        if (!f.existsSync()) {
                          return Text("${items.entries[0].path} not found");
                        }
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: FittedBox(
                                  fit: BoxFit.fitWidth, child: Image.file(f))),
                        );
                      }));
                },
              )),
          Padding(
            padding:
                const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: CLText.standard(
                notes,
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
