import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddProduct extends StatefulWidget {
  final Function callback;

  AddProduct({this.callback});

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  bool _willTrack = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 10.0,
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
              Row(
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
