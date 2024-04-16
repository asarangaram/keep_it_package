import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'crop_orientation_control.dart';
import 'models/aspect_ratio.dart' as aratio;

class CropperControls extends StatelessWidget {
  const CropperControls({
    required this.rotateAngle,
    required this.aspectRatio,
    required this.onChangeAspectRatio,
    super.key,
    this.saveWidget,
  });

  final double rotateAngle;
  final aratio.AspectRatio? aspectRatio;
  final void Function(aratio.AspectRatio? aspectRatio) onChangeAspectRatio;
  final Widget? saveWidget;

  // TODO(anandas): Move to settings
  static List<aratio.AspectRatio> get availableAspectRatio => const [
        //  aratio.AspectRatio(title: 'Freeform'),
        aratio.AspectRatio(title: '1:1', ratio: 1),
        aratio.AspectRatio(title: '4:3', ratio: 4 / 3),
        aratio.AspectRatio(title: '5:4', ratio: 5 / 4),
        aratio.AspectRatio(title: '7:5', ratio: 7 / 5),
        aratio.AspectRatio(title: '16:9', ratio: 16 / 9),
      ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .onBackground
            .withAlpha(128), // Color for the circular container
      ),
      child: Row(
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: CLText.large(
                          'Crop',
                          color: Colors.white,
                        ),
                      ),
                      Align(
                        child: CropOrientation(
                          rotateAngle: rotateAngle,
                          aspectRatio: aspectRatio,
                          onToggleCropOrientation: () {
                            onChangeAspectRatio(
                              aspectRatio?.copyWith(
                                isLandscape:
                                    !(aspectRatio?.isLandscape ?? false),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(),
                    ].map((e) => Expanded(child: e)).toList(),
                  ),
                ),
                Container(
                  // height: 80,
                  alignment: Alignment.center,

                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 16,
                            top: 4,
                            bottom: 4,
                          ),
                          child: Column(
                            children: [
                              CLButtonText.standard(
                                'Free form',
                                color: aspectRatio == null
                                    ? Colors.white
                                    : Colors.grey,
                                onTap: () {
                                  onChangeAspectRatio(
                                    null,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        for (final ratio in availableAspectRatio)
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 16,
                              top: 4,
                              bottom: 4,
                            ),
                            child: Column(
                              children: [
                                CLButtonText.standard(
                                  ratio.title,
                                  color: aspectRatio?.ratio == ratio.ratio
                                      ? Colors.white
                                      : Colors.grey,
                                  onTap: () {
                                    onChangeAspectRatio(
                                      ratio.copyWith(
                                        isLandscape: aspectRatio?.isLandscape,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 4,
            child: DecoratedBox(decoration: BoxDecoration(color: Colors.white)),
          ),
          if (saveWidget != null) saveWidget!,
        ],
      ),
    );
  }
}
