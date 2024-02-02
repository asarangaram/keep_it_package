import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class IncomingProgress extends StatefulWidget {
  const IncomingProgress({super.key});

  @override
  State<StatefulWidget> createState() => _IncomingProgressState();
}

class _IncomingProgressState extends State<IncomingProgress> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SizedBox.expand(
            child: Stack(
              children: [
                Center(
                  child: StreamBuilder<int>(
                    stream: getNumberStream(),
                    builder:
                        (BuildContext context, AsyncSnapshot<int> snapshot) {
                      final double? percent;
                      if (snapshot.hasData) {
                        percent = min(100, snapshot.data!.toDouble() / 100.0);
                        return CircularPercentIndicator(
                          radius: 100,
                          lineWidth: 13,
                          animation: true,
                          percent: percent,
                          center: CLText.veryLarge(
                            '${(percent * 100).toInt()} %',
                          ),
                          footer: const CLText.large(
                            'Please wait while analysing media files',
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: Colors.purple,
                        );
                      } else {
                        return CircularPercentIndicator(
                          radius: 100,
                          lineWidth: 13,
                          footer: const CLText.large(
                            'Please wait while analysing media files',
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: Colors.purple,
                        );
                      }
                    },
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CLButtonText.large(
                    'Discard',
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Stream<int> getNumberStream() {
    return Stream.periodic(const Duration(seconds: 1), (int count) {
      return count;
    });
  }
}
