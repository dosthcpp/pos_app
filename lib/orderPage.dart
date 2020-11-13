import 'package:flutter/material.dart';

class OrderPage extends StatelessWidget {
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
              Icons.arrow_back,
              color: Colors.black,
            ),
            onTap: () => Navigator.of(context).pop(),
          ),
          title: Transform(
            transform: Matrix4.translationValues(-60.0, 0, 0),
            child: Text(
              "Order #1001",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          actions: [
            ButtonTheme(
              minWidth: 0,
              height: 0,
              child: MaterialButton(
                materialTapTargetSize:
                MaterialTapTargetSize.shrinkWrap,
                child: Icon(
                  Icons.more_vert,
                  color: Colors.deepPurpleAccent,
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: 270.0,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      image: ExactAssetImage('assets/background.jpg'),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(
                      color: Colors.black12,
                    )),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 15.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Today at 3:43pm"),
                      Text(
                        "\$209.05",
                        style: TextStyle(fontSize: 40.0),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text("Sold by Ricardo Vazquez"),
                      SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            width: 8.0,
                            height: 8.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Colors.black45,
                            ),
                          ),
                          SizedBox(
                            width: 6.0,
                          ),
                          Text(
                            "Paid",
                            style: TextStyle(color: Colors.black45),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 140.0,
                  child: Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    height: 110.0,
                    color: Colors.white,
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Customer",
                                  style: TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(
                                  height: 25.0,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Image.asset(
                                      'assets/user.png',
                                      width: 40.0,
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text("Tobi Lutke"),
                                        SizedBox(
                                          height: 5.0,
                                        ),
                                        Text(
                                          "Ottawa, Ontario",
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.black54,
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                            ButtonTheme(
                              padding: EdgeInsets.all(0),
                              minWidth: 0,
                              height: 0,
                              child: MaterialButton(
                                materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                                onPressed: () {},
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.deepPurpleAccent,
                                        width: 1.2,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          30.0)),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5.5,
                                    ),
                                    child: Text("i"),
                                  ),
                                ),
                              ),
                            )
                          ],
                        )),
                  )),
            ],
          ),
          Expanded(
            flex: 1,
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 10.0, left: 20.0, bottom: 5.0),
                  child: Text(
                    "Items",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ),
                _ListItemInOrder(
                  title: 'Walnut Planter',
                  size: 'Tall',
                  imageUrl: 'assets/walnut planter.png',
                  num: 3,
                  price: 61.6,
                ),
                _ListItemInOrder(
                  title: 'Mug cup',
                  size: 'Tall',
                  imageUrl: 'assets/cup.jpeg',
                  num: 1,
                  price: 24.25,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}


class _ListItemInOrder extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String size;
  final int num;
  final double price;

  _ListItemInOrder({@required this.imageUrl,
    @required this.title,
    @required this.num,
    @required this.size,
    @required this.price});

  @override
  Widget build(BuildContext context) {
    double totalPrice = num * price;
    return Column(
      children: <Widget>[
        Container(
            height: 100,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Stack(
                        overflow: Overflow.visible,
                        children: <Widget>[
                          Container(
                            width: 80.0,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: ExactAssetImage(imageUrl),
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(
                                  color: Colors.black12,
                                )),
                          ),
                          Positioned(
                            top: -9.0,
                            right: -4.5,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.deepPurpleAccent,
                                    width: 1.2,
                                  ),
                                  borderRadius: BorderRadius.circular(30.0)),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.5,
                                ),
                                child: Text(num.toString()),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 10.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              title,
                              style: TextStyle(
                                  color: Colors.black, fontSize: 18.0),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            Text(
                              size,
                              style: TextStyle(color: Colors.black45),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        "\$$totalPrice",
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        "(\$$price x $num)",
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      )
                    ],
                  )
                ],
              ),
            )),
        Divider(),
      ],
    );
  }
}
