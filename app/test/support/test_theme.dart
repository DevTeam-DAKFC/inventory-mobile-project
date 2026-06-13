import 'package:flutter/material.dart';

ThemeData buildTestTheme({bool useMaterial3 = true}) {
  return ThemeData(
    useMaterial3: useMaterial3,
    splashFactory: NoSplash.splashFactory,
  );
}
