import 'package:flutter/material.dart';

class CLMenuItem {
  CLMenuItem(this.title, this.icon, {this.onTap});
  String title;
  IconData icon;
  void Function()? onTap;
}
