import 'dart:math';

import 'package:flutter/material.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../basics/cl_text.dart';

class StreamProgressView extends StatelessWidget {
  const StreamProgressView({
    required this.stream,
    required this.onCancel,
    super.key,
  });

  final Stream<Progress> Function() stream;
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
                child: StreamBuilder<Progress>(
                  stream: stream(),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<Progress> snapshot,
                  ) {
                    if (snapshot.hasData) {
                      final double percent =
                          min(1, snapshot.data!.fractCompleted);
                      return CircularPercentIndicator(
                        radius: 100,
                        lineWidth: 13,
                        animation: true,
                        percent: percent,
                        center: CLText.veryLarge(
                          '${(percent * 100).toInt()} %',
                        ),
                        footer: CLText.large(
                          snapshot.data!.currentItem,
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: Colors.purple,
                      );
                    } else {
                      return CircularPercentIndicator(
                        radius: 100,
                        lineWidth: 13,
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: Colors.purple,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
