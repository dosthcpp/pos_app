import 'package:flutter/material.dart';
import 'package:pos_app/main_page.dart';

class PaymentPage extends StatelessWidget {
  final Function callback;
  final price;

  static final GlobalKey paymentButton = GlobalKey();


  PaymentPage(this.callback, {this.price});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 10.0,
        ),
        child: Column(
          children: <Widget>[
            Text(
              "Total",
              style: TextStyle(
                fontSize: 15.0,
              ),
            ),
            Text(
              "\$${price}0",
              style: TextStyle(fontSize: 45.0),
            ),
            SizedBox(
              height: 20.0,
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      key: paymentButton,
                      child: _PaymentMethod(
                        title: "Credit",
                        imageUrl: 'assets/credit-card.png',
                        callback: callback,
                      ),
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    _PaymentMethod(
                      title: "External terminal",
                      imageUrl: 'assets/pos-terminal.png',
                      callback: callback,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _PaymentMethod(
                      title: "Cash",
                      imageUrl: 'assets/money.png',
                      callback: callback,
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    _PaymentMethod(
                      title: "Gift card",
                      imageUrl: 'assets/gift-card.png',
                      callback: callback,
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _PaymentMethod extends StatelessWidget {
  final String title;
  final String imageUrl;
  final Function callback;

  _PaymentMethod({@required this.title, @required this.imageUrl, this.callback});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.0),
      child: Container(
        width: ((MediaQuery.of(context).size.width) / 3) / 2 - 25,
        height: 80.0,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 0.5,
              blurRadius: 1,
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
