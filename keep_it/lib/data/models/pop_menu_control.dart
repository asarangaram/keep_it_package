// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/widgets.dart';

class ItemModel {
  String title;
  IconData icon;
  void Function()? action;
  ItemModel(this.title, this.icon, {this.action});
}

class PopMenuControl {
  final bool isMenuShowing;
  final Size? region;
  final Size? anchorSize;
  final Offset? anchorOffset;

  final bool edit;

  PopMenuControl({
    this.isMenuShowing = false,
    this.region,
    this.anchorSize,
    this.anchorOffset,
    this.edit = false,
  }) {
    //print(bBox?.id);
  }
  PopMenuControl copyWith(
      {bool? isMenuShowing,
      Size? region,
      Size? anchorSize,
      Offset? anchorOffset,
      bool? edit}) {
    return PopMenuControl(
        isMenuShowing: isMenuShowing ?? this.isMenuShowing,
        region: region ?? this.region,
        anchorSize: anchorSize ?? this.anchorSize,
        anchorOffset: anchorOffset ?? this.anchorOffset,
        edit: edit ?? this.edit);
  }

  PopMenuControl showMenu({
    Size? region,
    required Size anchorSize,
    required Offset anchorOffset,
  }) {
    return copyWith(
        region: region,
        anchorSize: anchorSize,
        anchorOffset: anchorOffset,
        isMenuShowing: true);
  }

  PopMenuControl hideMenu() => copyWith(
        region: null,
        anchorSize: null,
        anchorOffset: null,
        isMenuShowing: false,
      );

/*   PopMenuControl editText(bool enable) => copyWith(
        edit: enable,
      ); */

  @override
  String toString() {
    return 'PopMenuControl(isMenuShowing: $isMenuShowing, region: $region, '
        'anchorSize: $anchorSize, anchorOffset: $anchorOffset, '
        ' edit: $edit)';
  }
}
