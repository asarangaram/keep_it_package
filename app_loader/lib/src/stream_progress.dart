import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class StreamProgress extends StatelessWidget {
  const StreamProgress({
    required this.stream,
    required this.onCancel,
    super.key,
  });

  final Stream<double> Function() stream;
  final void Function() onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: SizedBox.expand(
          child: Stack(
            children: [
              Center(
                child: StreamBuilder<double>(
                  stream: stream(),
                  builder:
                      (BuildContext context, AsyncSnapshot<double> snapshot) {
                    final double? percent;
                    if (snapshot.hasData) {
                      percent = min(1, snapshot.data!);
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
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(8),
                    /* boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ], */
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: CLButtonText.large(
                      'Discard',
                      onTap: onCancel,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
