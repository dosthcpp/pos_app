import 'package:flutter/material.dart';
import 'package:pos_app/main.dart' show orderProvider, OrderProvider;
import 'package:pos_app/main_page.dart';
import 'package:provider/provider.dart';

class OrderPage extends StatelessWidget {
  final Function callback;
  final int orderForRenderIdx;

  OrderPage(this.callback, {this.orderForRenderIdx});

  _renderTime() {
    final _date = orderProvider.orders?.length == 0
        ? DateTime.now()
        : orderProvider.orders.elementAt(orderForRenderIdx).date;
    if (_date != null) {
      final hour = _date.hour > 12 ? _date.hour - 12 : _date.hour;
      final hourString = hour < 10 ? "0$hour" : hour;
      final minute = _date.minute < 10 ? "0${_date.minute}" : _date.minute;

      return "${_date.difference(DateTime.now()).inDays == 0 ? "Today" : _date.toLocal().toString().split(" ")[0].split("-").join(".")} at $hourString:$minute${_date.hour < 13 ? "AM" : "PM"}";
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, _) {
        final order = provider?.orders?.length == 0
            ? Order(() {})
            : provider?.orders?.elementAt(orderForRenderIdx);
        return Scaffold(
          body: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
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
                        children: [
                          Text(_renderTime()),
                          Text(
                            "\$${order.totalPrice ?? 0}0",
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
                            children: [
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
                      width: MediaQuery.of(context).size.width,
                      height: 110.0,
                      color: Colors.white,
                      child: Padding(
                        padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                  children: [
                                    Image.asset(
                                      'assets/user.png',
                                      width: 40.0,
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
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
                                      borderRadius: BorderRadius.circular(30.0)),
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
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0, left: 20.0, bottom: 5.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Items",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: order?.itemList?.length ?? 0,
                  itemBuilder: (context, index) {
                    final _order = order?.itemList?.elementAt(index);
                    if (_order != null) {
                      return _ListItemInOrder(
                        title: _order?.title,
                        size: '',
                        image: _order.image,
                        num: _order?.itemCount,
                        price: _order?.price,
                        totalPrice: _order.price * _order.itemCount,
                      );
                    }
                    return CircularProgressIndicator();
                  },
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: (MediaQuery.of(context).size.width / 3) - 30,
                  color: Colors.black12,
                  child: MaterialButton(
                    onPressed: callback,
                    child: Text(
                      "Print receipt",
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ListItemInOrder extends StatelessWidget {
  final ImageProvider image;
  final String title;
  final String size;
  final int num;
  final double price;
  final double totalPrice;

  _ListItemInOrder(
      {@required this.image,
      @required this.title,
      @required this.size,
      @required this.num,
      @required this.price,
      @required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            height: 100,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Stack(
                        overflow: Overflow.visible,
                        children: [
                          Container(
                            width: 80.0,
                            child: Image(image: image),
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
                          children: [
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
                    children: [
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
