import 'package:colan_widgets/colan_widgets.dart';
import 'package:media_editors/media_editors.dart';
import 'package:store/store.dart';

extension AccessControlExt on ActionControl {
  static ActionControl actionControlNone() {
    return const ActionControl();
  }

  static ActionControl onGetMediaActionControl(CLMedia media) {
    final editSupported = switch (media.type) {
      CLMediaType.text => false,
      CLMediaType.image => true,
      CLMediaType.video => VideoEditor.isSupported,
      CLMediaType.url => false,
      CLMediaType.audio => false,
      CLMediaType.file => false,
    };
    final isAFile = media.isMediaCached;

    return ActionControl(
      allowEdit: editSupported && isAFile,
      allowDelete: true,
      allowMove: true,
      allowShare: isAFile,
      allowPin: ColanPlatformSupport.isMobilePlatform,
      canDuplicateMedia: true,
    );
  }
}
