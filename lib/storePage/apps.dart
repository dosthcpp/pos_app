import 'package:flutter/material.dart';
import 'package:pos_app/storePage/hardware.dart';

class Apps extends StatelessWidget {
  static const id = 'apps';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: Container(),
      ),
    );
  }
}
