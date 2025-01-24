import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pie_chart/pie_chart.dart';

import '../builders/get_downloader.dart';

class DownloaderProgressbar extends ConsumerWidget {
  const DownloaderProgressbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetDownloaderStatus(
      errorBuilder: (_, __) {
        return const SizedBox.shrink();
        // ignore: dead_code
      },
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GetDownloaderStatus',
      ),
      builder: (downloaderStatus) {
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
      },
    );
  }
}

class DownloaderProgressPie extends ConsumerWidget {
  const DownloaderProgressPie({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetDownloaderStatus(
      errorBuilder: (_, __) {
        return const SizedBox.shrink();
      },
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GetDownloaderStatus',
      ),
      builder: (downloaderStatus) {
        final total = downloaderStatus.total.toDouble();

        if (total < 1) {
          return const SizedBox.shrink();
        }

        final dataMap =
            downloaderStatus.toMap().map((k, v) => MapEntry(k, v as double));

        final colorList = downloaderStatus
            .toMap()
            .keys
            .map((k) => downloaderStatus.colorMap[k] ?? Colors.red)
            .toList();

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
                  colorList: colorList,
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
      },
    );
  }
}

class ActiveDownloadIndicator extends ConsumerWidget {
  const ActiveDownloadIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetDownloaderStatus(
      errorBuilder: (_, __) {
        return const SizedBox.shrink();
        // ignore: dead_code
      },
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GetDownloaderStatus',
      ),
      builder: (downloaderStatus) {
        if (downloaderStatus.running == 0) {
          return Container();
        }
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Center(
            child: SizedBox.square(
              dimension: 20,
              child: FittedBox(
                fit: BoxFit.cover,
                child: CLIcon.standard(Icons.download),
              ),
            ),
          ),
        );
      },
    );
  }
}
