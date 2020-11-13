import 'package:flutter/material.dart';
import 'package:pos_app/payment_result.dart';

class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 10.0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon:Icon(Icons.arrow_back,
            color: Colors.deepPurpleAccent,
          ),
            onPressed:() => Navigator.pop(context, false),
          ),
          title: Transform(
            transform: Matrix4.translationValues(-60.0, 0, 0),
            child: Text(
              "Select payment",
              style: TextStyle(
                color: Colors.black,
                fontSize: 17.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
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
              "\$185.00",
              style: TextStyle(
                fontSize: 45.0
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(
              children: <Widget>[
                _PaymentMethod(title: "Credit", imageUrl: 'assets/credit-card.png',),
                SizedBox(width: 20.0,),
                _PaymentMethod(title: "External terminal", imageUrl: 'assets/pos-terminal.png',),
              ],
            ),
            Row(
              children: <Widget>[
                _PaymentMethod(title: "Cash", imageUrl: 'assets/money.png',),
                SizedBox(width: 20.0,),
                _PaymentMethod(title: "Gift card", imageUrl: 'assets/gift-card.png',),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethod extends StatelessWidget {
  final String title;
  final String imageUrl;
  _PaymentMethod({@required this.title, @required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.0),
      child: Container(
        width: (MediaQuery.of(context).size.width - 40) / 2,
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
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentResult()));
          },
        ),
      ),
    );
  }
}

