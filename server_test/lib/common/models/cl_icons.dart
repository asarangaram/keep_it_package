import 'package:flutter/material.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

extension IconOnIconData on IconData {
  Widget iconFormatted({
    double? size,
    double? fill,
    double? weight,
    double? grade,
    double? opticalSize,
    Color? color,
    List<Shadow>? shadows,
    String? semanticLabel,
    TextDirection? textDirection,
    bool? applyTextScaling,
  }) {
    return Icon(
      this,
      size: size,
      fill: fill,
      weight: weight,
      grade: grade,
      opticalSize: opticalSize,
      color: color,
      shadows: shadows,
      semanticLabel: semanticLabel,
      textDirection: textDirection,
    );
  }
}

class CameraIcons {}

class MediaEditorIcons {}

class MediaViewerIcons {}

class PageNavigateIcons {}

class NodeNavigateIcons {}

@immutable
class SyncIcons {
  final disconnectIconData = MdiIcons.lanDisconnect;
  final connectIconData = MdiIcons.lanConnect;
  final syncIconData = MdiIcons.syncCircle;
  final attachIconData = MdiIcons.plusCircle;
  final detachIconData = MdiIcons.minusCircle;
  final syncOptionsIconData = Symbols.format_list_bulleted_add;
  final refreshIndicator = Symbols.refresh_sharp;

  final Widget inSync = Center(
    child: Symbols.cloud_done_sharp.iconFormatted(
      //size: CLScaleType.veryLarge.iconSize,
      weight: 700,
      grade: 100,
      color: const Color.fromARGB(
        0xFF,
        0x00,
        0xFF,
        0xEC,
      ),
    ),
  );
  final Widget disconnect = Center(
    child: MdiIcons.lanDisconnect.iconFormatted(
      //size: CLScaleType.veryLarge.iconSize,
      weight: 700,
      grade: 100,
      color: const Color.fromARGB(255, 242, 51, 64),
    ),
  );
}

@immutable
class CLIcons {
  final SyncIcons syncIcons = SyncIcons();
  final placeHolder = Icons.device_unknown_outlined;
  final filter = Symbols.filter_list_sharp;
  final camera = LucideIcons.camera;
  final microphone = MdiIcons.microphone;
  final location = MdiIcons.mapMarker;
  final imageCapture = MdiIcons.camera;
  final videoRecordingStart = MdiIcons.video;
  final videoRecordingPause = MdiIcons.pause;
  final videoRecordingResume = MdiIcons.circle;
  final videoRecordingStop = Icons.stop;
  final flashModeOff = Icons.flash_off;
  final flashModeAuto = Icons.flash_auto;
  final flashModeAlways = Icons.flash_on;
  final flashModeTorch = Icons.highlight;
  final recordingAudioOn = MdiIcons.volumeHigh;
  final recordingAudioOff = MdiIcons.volumeMute;
  final switchCamera = Icons.cameraswitch;
  final exitCamera = MdiIcons.arrowLeft;
  final invokeCamera = MdiIcons.camera;
  final popMenuAnchor = MdiIcons.dotsVertical;
  final popMenuSelectedItem = MdiIcons.checkCircle;
  final pagePop = MdiIcons.arrowLeft;
  final navigateHome = MdiIcons.home;
  final serversList = MdiIcons.accessPointNetwork;
  final noNetwork = MdiIcons.accessPointNetworkOff;
  final connectToServer = MdiIcons.accessPointNetwork;
  final searchForServers = MdiIcons.rotate3DVariant;
  final openNotes = MdiIcons.notebookEdit;
  final closeNotes = MdiIcons.notebookCheck;
  final closeFullscreen = MdiIcons.close;
  final imageEdit = MdiIcons.pencil;
  final imageMove = MdiIcons.imageMove;
  final imageMoveAll = MdiIcons.imageMove;
  final imageShare = MdiIcons.share;
  final imageShareAll = MdiIcons.shareAll;
  final pin = MdiIcons.pin;
  final unPin = MdiIcons.pinOff;
  final pinned = MdiIcons.pin;
  final notPinned = MdiIcons.pinOff;
  final brokenPin = MdiIcons.pinOff;
  final editCollectionLabel = MdiIcons.pencil;
  final next = MdiIcons.arrowRight;
  final deleteNote = MdiIcons.delete;
  final undoNote = MdiIcons.undoVariant;
  final save = MdiIcons.contentSave;
  final discardChangeNote = MdiIcons.close;
  final hideKeyboard = MdiIcons.keyboardClose;
  final navigatePinPage = MdiIcons.pin;
  final navigateSettings = MdiIcons.cog;
  final gotoPage = MdiIcons.arrowRight;
  final recycleBin = MdiIcons.delete;
  final doneEditMedia = MdiIcons.check;
  final imageEditRotateRight = MdiIcons.rotateRight;
  final imageEditRotateLeft = MdiIcons.rotateLeft;
  final imageEditFlipHirizontal = MdiIcons.flipHorizontal;
  final imageEditFlipVertical = MdiIcons.flipVertical;
  final imageDelete = Icons.delete_rounded;
  final audioMuted = MdiIcons.volumeOff;
  final audioUnmuted = MdiIcons.volumeHigh;
  final itemSelected = LucideIcons.squareCheckBig;
  final itemSelected2 = LucideIcons.check;
  final itemNotSelected = Icons.square_outlined;
  final itemPartiallySelected = Icons.indeterminate_check_box_outlined;

  final error = Icons.warning;
  final insertItem = Icons.add;
  final deleteItem = Icons.delete;
  final down = Icons.arrow_circle_down;
  final up = Icons.arrow_circle_up;
  final brokenImage = Icons.broken_image_outlined;
  final playerPause = Icons.pause;
  final playerPlay = Icons.play_arrow;
  final playerStop = Icons.stop;
  final mediaOrientation = Icons.image;

  final extraMenu = Icons.more_vert;
  final cameraSettings = Icons.settings;
  final collectionsSelect = Symbols.list_alt;
  final searchRequest = Symbols.search;
  final searchOpened = Symbols.search_check_2;
  final selected = Symbols.select_check_box_rounded;
  final deselected = Symbols.check_box_outline_blank_rounded;
}

CLIcons clIcons = CLIcons();
