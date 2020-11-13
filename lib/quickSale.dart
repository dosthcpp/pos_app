import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class QuickSale extends StatefulWidget {
  @override
  _QuickSaleState createState() => _QuickSaleState();
}

class _QuickSaleState extends State<QuickSale> {
  bool _tax = false;

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
              "Quick sale",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 5.0,
        ),
        child: Center(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 150.0,
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 1.0), //(x,y)
                    blurRadius: 1.0,
                  )
                ]),
                child: Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 30,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Title",
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 30,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(hintText: "Price"),
                            ),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(hintText: "Quantity"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 50.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 1.0,
                    )
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Track inventory"),
                      CupertinoSwitch(
                        value: _tax,
                        onChanged: (value) {
                          setState(() {
                            _tax = value;
                          });
                        },
                      )
                    ],
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
