import 'package:flutter/material.dart';

class AddInventory extends StatefulWidget {
  final Function callback;

  AddInventory({this.callback});

  @override
  _AddInventoryState createState() => _AddInventoryState();
}

class _AddInventoryState extends State<AddInventory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 20.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Inventory",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              width: MediaQuery.of(context).size.width - 20,
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2.0,
                  spreadRadius: 0.0,
                  offset: Offset(1.0, 1.0),
                )
              ]),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 50.0,
                ),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/inventory.png',
                      width: 75.0,
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      "Keep track of your inventory",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    SizedBox(
                      width: 250.0,
                      child: Text(
                        "When you enable inventory tracking on your products, you can view and adjust their inventory counts here.",
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    MaterialButton(
                      child: Container(
                        width: 120.0,
                        height: 30.0,
                        child: Center(
                          child: Text(
                            "Go to products",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purpleAccent,
                        ),
                      ),
                      onPressed: () {},
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            Center(
              child: Container(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Learn more about ",
                      ),
                      Text(
                        "managing inventory",
                        style: TextStyle(
                          color: Colors.blueAccent,
                        ),
                      ),
                      Icon(
                        Icons.link,
                        color: Colors.blueAccent,
                      )
                    ],
                  ),
                ),
                height: 50.0,
                width: MediaQuery.of(context).size.width - 30,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black12,
                    ),
                    borderRadius: BorderRadius.circular(30.0)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
