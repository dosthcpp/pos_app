import 'package:flutter/material.dart';
import 'package:pos_app/main_page.dart';

class PaymentResult extends StatelessWidget {
  final callback;
  final callback2;
  final price;

  static final printReceiptKey = GlobalKey();

  PaymentResult(this.callback, this.callback2, this.price);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 10.0,
            ),
            child: Column(
              children: <Widget>[
                Text(
                  "Change due",
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
                Text(
                  "\$0.00",
                  style: TextStyle(fontSize: 45.0),
                ),
                Text(
                  "Total \$${price}0",
                  style: TextStyle(fontSize: 15.0),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      key: printReceiptKey,
                      child: _PaymentMethod(
                        title: "Print receipt",
                        imageUrl: 'assets/printer.png',
                        callback: callback,
                      ),
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    _PaymentMethod(
                      title: "Gift receipt",
                      imageUrl: 'assets/gift-box.png',
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _PaymentMethod(
                      title: "Email receipt",
                      imageUrl: 'assets/email.png',
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    _PaymentMethod(
                      title: "Text receipt",
                      imageUrl: 'assets/chat.png',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width + 20,
            height: 60,
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 0.2,
                blurRadius: 0.5,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ]),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Image.asset(
                        'assets/gift-card.png',
                        width: 30.0,
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      Text(
                        "755F 47HB 2B7A 98C9",
                        style: TextStyle(
                          fontSize: 18.0,
                          letterSpacing: 0.2,
                        ),
                      )
                    ],
                  ),
                  Text(
                    "\$20.00",
                    style: TextStyle(
                      fontSize: 18.0,
                      letterSpacing: -1.0,
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 15.0,
          ),
          Container(
            width: MediaQuery.of(context).size.width + 20,
            height: 100,
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 0.2,
                blurRadius: 0.5,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ]),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 30.0,
                        height: 24.0,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage('assets/mastercard.png'),
                              fit: BoxFit.cover,
                            ),
                            border: Border.all(
                              color: Colors.black45,
                            )),
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      Text(
                        "Mastercard - ending with 4588",
                        style: TextStyle(
                          fontSize: 14.0,
                          letterSpacing: 0.2,
                        ),
                      )
                    ],
                  ),
                  Text(
                    "\$${price - 20.0}0",
                    style: TextStyle(
                      fontSize: 18.0,
                      letterSpacing: -1.0,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
      floatingActionButton: Container(
        height: 50.0,
        width: (MediaQuery.of(context).size.width / 3) - 20,
        child: Transform(
          transform: Matrix4.translationValues(8, 0, 0),
          child: FloatingActionButton.extended(
            onPressed: callback2,
            backgroundColor: Colors.deepPurpleAccent,
            label: Center(
              child: Text(
                "DONE",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                ),
              ),
            ),
            shape: RoundedRectangleBorder(),
          ),
        ),
      ),
    );
  }
}

class _PaymentMethod extends StatelessWidget {
  final String title;
  final String imageUrl;
  final callback;

  _PaymentMethod(
      {@required this.title, @required this.imageUrl, this.callback});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.0),
      child: Container(
        width: (MediaQuery.of(context).size.width / 3) / 2 - 25,
        height: 80.0,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 0.2,
              blurRadius: 0.5,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: MaterialButton(
          elevation: 5.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                imageUrl,
                width: 45.0,
              ),
              Text(title),
            ],
          ),
          onPressed: callback,
        ),
      ),
    );
  }
}
