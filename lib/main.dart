import 'package:flutter/material.dart';
import 'init_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: InitPage.id,
      routes: {
        InitPage.id: (context) => InitPage(),
      }
    );
  }
}
