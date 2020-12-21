import 'package:flutter/material.dart';
import 'package:pos_app/main_page.dart';
import 'package:pos_app/storePage/apps.dart';
import 'package:pos_app/storePage/hardware.dart';
import 'package:pos_app/storePage/location.dart';
import 'package:pos_app/storePage/payment.dart';
import 'package:pos_app/storePage/settings.dart';
import 'package:pos_app/storePage/support.dart';
import 'package:pos_app/storePage/tips.dart';
import 'init_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(initialRoute: MainPage.id, routes: {
      MainPage.id: (context) => MainPage(),
      InitPage.id: (context) => InitPage(),
      Hardware.id: (context) => Hardware(),
      ConnectCardReader.id: (context) => ConnectCardReader(),
      ScanCode.id: (context) => ScanCode(),
      DummyPage.id: (context) => DummyPage(),
      Location.id: (context) => Location(),
      Payment.id: (context) => Payment(),
      Apps.id: (context) => Apps(),
      Tips.id: (context) => Tips(),
      Settings.id: (context) => Settings(),
    });
  }
}
