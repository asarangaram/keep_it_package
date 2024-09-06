import 'package:store/store.dart';

class StoreModel {
  List<Collection> getCollections({bool excludeEmpty = true}) {
    return [];
  }

  Collection? getCollectionById(int? id) {
    return null;
  }

  List<CLMedia> getStaleMedia() {
    return [];
  }

  List<CLMedia> getPinnedMedia() {
    return [];
  }

  List<CLMedia> getDeletedMedia() {
    return [];
  }

  CLMedia? getMediaById(int? id) {
    return null;
  }

  List<CLMedia> getMediaMultipleByIds(List<int> idList) {
    return [];
    /*
    .where((e) => e != null)
                      .map((e) => e)
                      .toList() */
  }

  List<CLMedia> getMediaByCollectionId(
    int? collectionId, {
    int maxCount = 0,
    bool isRandom = false,
  }) {
    /**
     * final availableList = mediaList
                .where(
                  (e) => File(theStore.getPreviewAbsolutePath(e)).existsSync(),
                )
                .toList()
                .pickRandomItems(4);
     */
    return [];
  }

  String getText(CLMedia? media) {
    return '';
  }

  Uri getValidMediaUri(CLMedia? media) {
    return Uri.file('');
  }

  Uri getValidPreviewUri(CLMedia? media) {
    return Uri.file('');
  }

  Future<String> createTempFile({required String ext}) async {
    return '';
  }
}
