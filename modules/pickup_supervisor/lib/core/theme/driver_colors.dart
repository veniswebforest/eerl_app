import 'package:flutter/material.dart';

/// Driver-module aliases for the shared EERL color tokens.
///
/// The values intentionally mirror `AppColors` in the host application so the
/// feature package stays independently buildable without importing its host.
abstract final class DriverColors {
  static const background = Color(0xFFFAFAF8);
  static const surface = Color(0xFFFFFFFF);
  static const primary950 = Color(0xFF0B2812);
  static const primary800 = Color(0xFF215A2D);
  static const primary500 = Color(0xFF39AE51);
  static const primary400 = Color(0xFF5FC974);
  static const primary100 = Color(0xFFE0F8E4);
  static const primary50 = Color(0xFFF2FBF3);
  static const secondary500 = Color(0xFF357AC2);
  static const secondary100 = Color(0xFFE5EDF9);
  static const neutral950 = Color(0xFF111213);
  static const neutral900 = Color(0xFF3D3D3D);
  static const neutral700 = Color(0xFF4F4F4F);
  static const neutral600 = Color(0xFF5D5D5D);
  static const neutral400 = Color(0xFF888888);
  static const cool950 = Color(0xFF333B42);
  static const cool500 = Color(0xFF92A3B0);
  static const cool200 = Color(0xFFE6EBEE);
  static const cool400 = Color(0xFFB9C5CC);
  static const cool100 = Color(0xFFF2F5F5);
  static const purple = Color(0xFF6644DD);
  static const purpleLight = Color(0xFFE4E3F3);
  static const orange = Color(0xFFFF7B33);
  static const orangeLight = Color(0xFFFFE9E3);
  static const yellow600 = Color(0xFFF9AE00);
  static const yellow400 = Color(0xFFFFBF29);
  static const yellow50 = Color(0xFFFFFBEB);
  static const red600 = Color(0xFFE22424);
  static const red500 = Color(0xFFF43F3F);
  static const red400 = Color(0xFFFC6D6D);
  static const red100 = Color(0xFFFFE1E1);
  static const shadow = Color(0x1F000000);
}
