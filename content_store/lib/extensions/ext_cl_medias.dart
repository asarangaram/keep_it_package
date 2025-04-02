import 'package:store/store.dart';

extension StoreExtCLMedias on CLMedias {
  bool get isNotEmpty => entries.isNotEmpty;
  bool get isEmpty => entries.isEmpty;
}
