import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smigoal/resources/app_resources.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import './widgets/smigoal.dart';

var kColorScheme = ColorScheme.fromSeed(
  seedColor: AppColors.contentColorBlue,
);
var kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 5, 99, 155),
);

void initApp() async {
  WidgetsFlutterBinding.ensureInitialized();
}

void main() async {
  initApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((fn) {
    runApp(MaterialApp(
      theme: ThemeData().copyWith(
        colorScheme: kColorScheme,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', 'US'), // 영어
        Locale('ko', 'KR'), // 한국어
        // 다른 지원 언어 추가
      ],
      home: SmiGoal(),
    ));
  });
}
