import 'package:flutter/material.dart';

class CLMenuItem {
  String title;
  IconData icon;
  void Function()? onTap;
  CLMenuItem(this.title, this.icon, {this.onTap});
}
