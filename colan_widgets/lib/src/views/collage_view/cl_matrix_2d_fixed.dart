import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'compute_size_and_build.dart';

class Matrix2DNew extends StatelessWidget {
  const Matrix2DNew({
    required this.itemBuilder,
    required this.hCount,
    required int vCount,
    required this.itemCount,
    this.strictMartrix = true,
    super.key,
  }) : vCount_ = vCount;
  const Matrix2DNew.scrollable({
    required this.itemBuilder,
    required this.hCount,
    required this.itemCount,
    this.strictMartrix = true,
    super.key,
  }) : vCount_ = null;

  final Widget Function(BuildContext context, int index) itemBuilder;

  final int hCount;
  final int? vCount_;
  final int itemCount;
  final bool strictMartrix;

  @override
  Widget build(BuildContext context) {
    final numRows = vCount_ ?? (itemCount + hCount - 1) ~/ hCount;
    final lastCount = (strictMartrix
        ? hCount
        : (hCount * numRows > itemCount)
            ? itemCount - hCount * (numRows - 1)
            : hCount);
    if (vCount_ == null) {
      return ComputeSizeAndBuild(
        builder: (context, size) {
          return ListView.builder(
            itemCount: numRows,
            itemBuilder: (context, r) {
              return SizedBox(
                height: size.width / hCount,
                width: size.width / hCount,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var c = 0;
                        c < (r == (numRows - 1) ? lastCount : hCount);
                        c++)
                      SizedBox.square(
                        dimension: size.width / hCount,
                        child: ((r * hCount + c) >= itemCount)
                            ? strictMartrix
                                ? Container()
                                : throw Exception('Unexpected')
                            : itembuilderWrapper(context, r * hCount + c),
                      ),
                  ],
                ),
              );
            },
          );
        },
      );
    }
    return ComputeSizeAndBuild(
      builder: (context, size) {
        final width = size.width / hCount;
        final height = size.height / numRows;

        return Column(
          children: [
            for (var r = 0; r < numRows; r++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var c = 0;
                      c < (r == (numRows - 1) ? lastCount : hCount);
                      c++)
                    SizedBox(
                      width: width,
                      height: height,
                      child: ((r * hCount + c) >= itemCount)
                          ? strictMartrix
                              ? Container()
                              : throw Exception('Unexpected')
                          : itembuilderWrapper(context, r * hCount + c),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget itembuilderWrapper(BuildContext context, int index) {
    index.toString().printString(prefix: 'index = ');
    return itemBuilder(context, index);
  }
}
