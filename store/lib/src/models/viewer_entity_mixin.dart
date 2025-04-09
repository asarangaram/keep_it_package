/* import 'package:store/src/extensions/ext_datetime.dart';
import 'package:store/src/extensions/ext_list.dart';

import 'gallery_group.dart'; */

abstract class ViewerEntityMixin {
  int? get id;
  bool get isCollection;
  DateTime get sortDate;
  int? get parentId;
  Uri? get mediaUri;
  Uri? get previewUri;
}
