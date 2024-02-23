// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';

@immutable
class DeviceDirectories {
  final Directory container;
  final Directory docDir;
  final Directory cacheDir;
  const DeviceDirectories({
    required this.container,
    required this.docDir,
    required this.cacheDir,
  });
}
