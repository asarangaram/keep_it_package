import '../models/cl_media.dart';

extension ExtCLMedia on CLMedia {
  // replace with removeCollectionId
  CLMedia setCollectionId(int? newCollectionId) {
    return CLMedia.regid(
      id: id,
      name: name,
      type: type,
      collectionId: newCollectionId,
      md5String: md5String,
      createdDate: createdDate,
      originalDate: originalDate,
      updatedDate: updatedDate,
      ref: ref,
      isDeleted: isDeleted,
      path: path,
      isHidden: isHidden,
      pin: pin,
    );
  }

  CLMedia removePin() {
    return CLMedia.regid(
      id: id,
      name: name,
      type: type,
      collectionId: collectionId,
      md5String: md5String,
      createdDate: createdDate,
      originalDate: originalDate,
      updatedDate: updatedDate,
      ref: ref,
      isDeleted: isDeleted,
      path: path,
      isHidden: isHidden,
      pin: null,
    );
  }

  CLMedia removeId() {
    return CLMedia.regid(
      id: null,
      name: name,
      type: type,
      collectionId: collectionId,
      md5String: md5String,
      createdDate: createdDate,
      originalDate: originalDate,
      updatedDate: updatedDate,
      ref: ref,
      isDeleted: isDeleted,
      path: path,
      isHidden: isHidden,
      pin: pin,
    );
  }

  String get label => path;
}
