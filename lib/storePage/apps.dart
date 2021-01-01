import 'package:flutter/material.dart';
import 'package:pos_app/storePage/hardware.dart';

class Apps extends StatelessWidget {
  static const id = 'apps';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(15.0),
        child: Text(
            "This is a list of apps that can be linked with Pos. It will be supported later. CCTV cameras and fingerprint recognition will be updated."),
      ),
    );
  }
}
