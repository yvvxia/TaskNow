import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_design_system.dart';

part 'theme_providers.g.dart';

@riverpod
ThemeData appLightTheme(Ref ref) =>
    AppDesignSystem.buildTheme(Brightness.light);

@riverpod
ThemeData appDarkTheme(Ref ref) => AppDesignSystem.buildTheme(Brightness.dark);
