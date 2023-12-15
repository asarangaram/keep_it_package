import 'package:flutter/material.dart';

class CLQuickMenuItem {
  String title;
  IconData icon;
  void Function()? onTap;
  CLQuickMenuItem(this.title, this.icon, {this.onTap});
}
