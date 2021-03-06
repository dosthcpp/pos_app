import 'package:flutter/material.dart';
import 'package:pos_app/main.dart' show orderProvider, OrderProvider;
import 'package:pos_app/main_page.dart';
import 'package:provider/provider.dart';

class OrderSpec extends StatelessWidget {
  final Function callback;
  final int orderForRenderIdx;

  OrderSpec(this.callback, {this.orderForRenderIdx});

  _renderTime(order) {
    final _date = orderProvider.orderList?.length == 0
        ? DateTime.now()
        : order.date;
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
        final order = provider?.orderList?.length == 0
            ? Order(() {})
            : provider?.orderList?.elementAt(orderForRenderIdx);
        bool _useCash = order.cash == null ? false : order.cash;
        bool _promotion = order.promotion == null ? false : order.promotion;
        return Column(
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
                        Text(_renderTime(order)),
                        Text(
                          "\$${oCcy.format(order.totalPrice ?? 0)}",
                          style: TextStyle(fontSize: 40.0),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text("Sold by Ricardo Vazquez"),
                        SizedBox(
                          height: 10.0,
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
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
                                "Paid by ${_useCash ? "Cash (Got \$${oCcy.format(order.cashGet)})" : "Card"}${_promotion ? ", applied \$20.00 of promotion" : ""}",
                                style: TextStyle(color: Colors.black45),
                                overflow: TextOverflow.fade,
                              )
                            ],
                          ),
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
                  onPressed: () {
                    callback(order, _useCash, _promotion);
                  },
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
                        "\$${oCcy.format(totalPrice)}",
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        "(\$${oCcy.format(price)} x $num)",
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
