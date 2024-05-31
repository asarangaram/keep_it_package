// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
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
    CLMedia media, {
    required String title,
    String? desc,
  }) async {
    final auth = await checkRequest();
    if (!auth) return null;

    /// Unfortunately, it is not possible to keep inside a FOLDER OR ALBUM
    /// with this approach. Lets investigate later
    // TODO(anandas): : Investigate album in Android
    final AssetEntity? assetEntity;
    if (media.type == CLMediaType.image) {
      assetEntity = await PhotoManager.editor.saveImageWithPath(
        media.path,
        title: title,
        desc: desc,
      );
    } else if (media.type == CLMediaType.video) {
      assetEntity =
          await PhotoManager.editor.saveVideo(File(media.path), title: title);
    } else {
      assetEntity = null;
    }

    if (assetEntity == null) return null;

    if (Platform.isIOS || Platform.isMacOS) {
      try {
        final album = await retriveAlbum();
        if (album != null) {
          await PhotoManager.editor
              .copyAssetToPath(asset: assetEntity, pathEntity: album);
        }
      } catch (e) {
        /** */
      }
    }
    return assetEntity.id;
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
