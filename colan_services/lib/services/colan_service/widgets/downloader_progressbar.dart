import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pie_chart/pie_chart.dart';

import '../providers/server.dart';

class DownloaderProgressbar extends ConsumerWidget {
  const DownloaderProgressbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloaderStatus = ref.watch(downloaderStatusProvider);
    final colors = <Color>[
      Colors.green,
      Colors.blue,
      Colors.grey,
    ];
    const height = 10.0;

    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final (i, val) in [
            downloaderStatus.completed,
            downloaderStatus.running,
            downloaderStatus.waiting,
          ].indexed)
            Expanded(
              flex: val,
              child: Container(
                color: colors[i],
              ),
            ),
        ],
      ),
    );
  }
}

class DownloaderProgressPie extends ConsumerWidget {
  const DownloaderProgressPie({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloaderStatus = ref.watch(downloaderStatusProvider);
    final total = downloaderStatus.total.toDouble();
    if (total < 1) {
      return const SizedBox.shrink();
    }
    final dataMap = <String, double>{
      'completed': downloaderStatus.completed.toDouble(),
      'running': downloaderStatus.running.toDouble(),
      'waiting': downloaderStatus.waiting.toDouble(),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Center(
        child: SizedBox.square(
          dimension: 20,
          child: FittedBox(
            fit: BoxFit.cover,
            child: PieChart(
              dataMap: dataMap,
              animationDuration: const Duration(milliseconds: 800),
              chartRadius: 12,
              colorList: const [Colors.green, Colors.blue, Colors.grey],
              initialAngleInDegree: 0,
              chartType: ChartType.ring,
              //ringStrokeWidth: 4,
              legendOptions: const LegendOptions(showLegends: false),
              chartValuesOptions: const ChartValuesOptions(
                showChartValues: false,
                showChartValueBackground: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
