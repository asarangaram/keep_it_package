// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:photo_manager/photo_manager.dart';

class AlbumManager {
  String albumName;
  AlbumManager({
    required this.albumName,
  });

  static Future<bool> checkRequest() async {
    final state = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        iosAccessLevel: IosAccessLevel.addOnly,
      ),
    );
    return state.isAuth;
  }

  Future<AssetPathEntity?> retriveAlbum() async {
    AssetPathEntity? targetAlbum;
    final assetPathList = await PhotoManager.getAssetPathList();
    try {
      targetAlbum = assetPathList.firstWhere((path) => path.name == albumName);
    } catch (e) {
      try {
        targetAlbum = await PhotoManager.editor.darwin.createAlbum(albumName);
      } catch (e) {
        /** */
      }
    }
    return targetAlbum;
  }

  Future<String?> addMedia(
    File mediaPath, {
    required String title,
    String? desc,
  }) async {
    final auth = await checkRequest();
    if (!auth) return null;

    try {
      final album = await retriveAlbum();
      if (album == null) return null;

      final assetEntity = await PhotoManager.editor.saveImageWithPath(
        mediaPath.path,
        title: title,
        desc: desc,
      );
      if (assetEntity == null) return null;
      await PhotoManager.editor
          .copyAssetToPath(asset: assetEntity, pathEntity: album);
      return assetEntity.id;
    } catch (e) {
      return null;
    }
  }

  Future<bool> removeMedia(String id) async {
    final auth = await checkRequest();
    if (!auth) return false;
    try {
      await PhotoManager.editor.deleteWithIds([id]);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeMultipleMedia(List<String> ids) async {
    final auth = await checkRequest();
    if (!auth) return false;
    try {
      await PhotoManager.editor.deleteWithIds(ids);
      return true;
    } catch (e) {
      return false;
    }
  }
}
