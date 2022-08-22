import 'package:flutter/material.dart';

Color hexToColor(String hexString) {
  var hexColor = hexString;
  if (hexColor.length == 6) {
    hexColor = 'FF$hexColor';
  }
  if (hexColor.length == 8) {
    return Color(int.parse('0x$hexColor'));
  }

  throw Exception('Unable to pass color $hexString');
}
