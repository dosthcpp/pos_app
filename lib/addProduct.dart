import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  bool _willTrack = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 10.0,
          automaticallyImplyLeading: false,
          leading: GestureDetector(
            child: Icon(
              Icons.close,
              color: Colors.purpleAccent,
            ),
            onTap: () => Navigator.of(context).pop(),
          ),
          title: Transform(
            transform: Matrix4.translationValues(-60.0, 0, 0),
            child: Text(
              "Add product",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 20.0,
        ),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width - 30,
                child: Row(
                  children: [
                    Expanded(
                      flex: 10,
                      child: TextField(
                        decoration: InputDecoration(hintText: "Title"),
                      ),
                    ),
                    Expanded(
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 30,
                child: TextField(
                  decoration: InputDecoration(hintText: "Price"),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Track inventory"),
                    CupertinoSwitch(
                      value: _willTrack,
                      onChanged: (value) {
                        setState(() {
                          _willTrack = value;
                        });
                      },
                    )
                  ],
                ),
              ),
              Visibility(
                visible: _willTrack,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 30,
                  child: TextField(
                    decoration: InputDecoration(hintText: "Inventory"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
