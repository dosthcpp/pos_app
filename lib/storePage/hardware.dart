import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Hardware extends StatelessWidget {
  static const id = 'hardware';

  final Function callback;

  Hardware({this.callback});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _StorePage(callback),
    );
  }
}

class _StorePage extends StatelessWidget {
  final Function callback;

  _StorePage(this.callback);

  List<String> _menuTitle = [
    'Connect Pos Printer',
    'Connect Customer View',
    'Other hardware',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: 225.0,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0.0, 1.0), //(x,y)
                blurRadius: 6.0,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 10.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  "Hardware",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18.0,
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      height: 50.0,
                      width: double.infinity,
                      child: MaterialButton(
                        onPressed: () {
                          callback(index);
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _menuTitle[index],
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: _menuTitle.length,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ConnectCardReader extends StatelessWidget {
  final Widget bluetoothConnection;
  bool isConnected;

  ConnectCardReader({this.bluetoothConnection, this.isConnected});

  static const id = 'connect_card_reader';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: 400.0,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 10.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "POS printer",
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Text(
                    "Accepts pos printer. Please bond your pos printer with bluetooth. Commonly, it displays as 'SPP-R200II'",
                  ),
                ],
              ),
              Center(
                child: Image.asset(
                  'assets/pos_printer.png',
                  width: 250.0,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: 5.0,
                ),
                child: Column(
                  children: [
                    bluetoothConnection,
                    isConnected
                        ? Text(
                            "Your pos printer has successfully been connected!")
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScanCode extends StatelessWidget {
  static const id = 'scan_code';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        overflow: Overflow.visible,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height / 4,
            ),
            child: Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  QrImage(
                    data: "http://www.example.com",
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                  SizedBox(
                    child: Text(
                      "Use the Customer View app to scan this code.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Transform(
            transform: Matrix4.translationValues(0, -50, 0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: MaterialButton(
                onPressed: () {},
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("LEARN MORE"),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Transform(
            transform: Matrix4.translationValues(0, -15, 0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                "Need help paring?\nVisit the Gabin Help Center.",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DummyPage extends StatelessWidget {
  static const id = 'dummy_page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 10.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Home - Chip & POS Printer",
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Image.asset('assets/pos_printer.png'),
              SizedBox(
                height: 30.0,
              ),
              Text(
                "POS Printer",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              Text(
                "Whether you use it as part of your on-the-go mobile point of sale solution or integrate it with your permanent retail setup, this mobile pos printer provides you with a flexible, reliable and secure POS experience.",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w300,
                  color: Colors.black54,
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Text(
                "\$29",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              Text(
                "Quantity",
                style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w300,
                    color: Colors.black45),
              ),
              SizedBox(
                width: 100.0,
                child: TextField(
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black54,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black54,
                        width: 1,
                      ),
                    ),
                    hintText: 'Quantity',
                  ),
                ),
              ),
              SizedBox(
                height: 40.0,
              ),
              Container(
                height: 50.0,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black54,
                  ),
                ),
                child: Center(
                  child: RichText(
                    text: TextSpan(children: <TextSpan>[
                      TextSpan(
                        text:
                            "To use this device, you need to enable Gabin Payments on your store. ",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      TextSpan(
                        text: "Learn more.",
                        style: TextStyle(
                          color: Colors.purple,
                          decoration: TextDecoration.underline,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
              SizedBox(
                height: 50.0,
              ),
              MaterialButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Alert!'),
                          content: Text(
                              "Please contact customer service."),
                          actions: [
                            FlatButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.pop(context, "OK");
                              },
                            ),
                          ],
                        );
                      });
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.purple,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Add to cart",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              MaterialButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Alert!'),
                          content: Text(
                              "Please contact customer service."),
                          actions: [
                            FlatButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.pop(context, "OK");
                              },
                            ),
                          ],
                        );
                      });
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.purple,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Buy it now",
                      style: TextStyle(
                        color: Colors.purple,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 50.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
