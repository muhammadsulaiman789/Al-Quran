import 'package:flutter/material.dart';
import 'package:quran_app/pages/bookmarks/bookmarks_widget.dart';
import 'package:quran_app/pages/home/home_widget.dart';
import 'package:quran_app/pages/quran/quran_widget.dart';
import 'package:quran_app/pages/quran_settings/quran_settings_widget.dart';
import 'package:quran_app/pages/splash/splash_widget.dart';

class Routes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => SplashWidget(),
    '/home': (context) => HomeWidget(),
    '/quran': (context) => QuranWidget(),
    '/bookmark' : (context) => BookmarksWidget(),
    '/setting' : (context) => QuranSettingsWidget(),
  };
}
