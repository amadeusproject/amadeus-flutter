import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:amadeus/localizations.dart';

import 'package:amadeus/res/colors.dart';

import 'package:amadeus/pages/login_page.dart';
import 'package:amadeus/pages/splash_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final routes = <String, WidgetBuilder>{
    SplashPage.tag: (context) => SplashPage(),
    LoginPage.tag: (context) => LoginPage(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: MyColors.colorPrimary,
        primaryColorDark: MyColors.colorPrimaryDark,
        accentColor: MyColors.colorAccent,
        hintColor: MyColors.primaryWhite,
        iconTheme: IconThemeData(
          color: MyColors.primaryWhite,
        ),
      ),
      title: 'Amadeus LMS',
      home: SplashPage(),
      routes: routes,
      localizationsDelegates: [
        const TranslationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        const FallbackMaterialLocalisationsDelegate(),
        GlobalCupertinoLocalizations.delegate,
        const FallbackCupertinoLocalisationsDelegate()
      ],
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('pt-BR', 'BR'),
      ],
      localeResolutionCallback:
          (Locale locale, Iterable<Locale> supportedLocales) {
        for (Locale supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode ||
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
    );
  }
}
