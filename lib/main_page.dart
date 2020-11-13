import 'package:flutter/material.dart';
import 'package:pos_app/addCustomer.dart';
import 'package:pos_app/addInventory.dart';
import 'package:pos_app/addProduct.dart';
import 'package:pos_app/orderPage.dart';
import 'package:pos_app/paymentPage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos_app/quickSale.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int index = 0;
  int cur = 1;
  bool searchMode = false;
  final fn = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 10.0,
          automaticallyImplyLeading: false,
          leading: searchMode
              ? GestureDetector(
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.deepPurpleAccent,
                  ),
                  onTap: () {
                    setState(() {
                      searchMode = false;
                    });
                  },
                )
              : null,
          actions: searchMode
              ? null
              : [
                  index == 0
                      ? SizedBox(
                          width: 30.0,
                          height: 40.0,
                          child: PopupMenuButton(
                            onSelected: (value) {
                              switch (value) {
                                case 1:
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AddInventory()));
                                  break;
                                case 2:
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AddProduct()));
                                  break;
                                case 3:
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AddCustomer()));
                                  break;
                                default:
                                  break;
                              }
                            },
                            icon: Icon(
                              Icons.add,
                              color: Colors.purpleAccent,
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 0,
                                child: Text(
                                  "Actions",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                enabled: false,
                              ),
                              PopupMenuItem(
                                value: 1,
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/packages.png',
                                      width: 20.0,
                                    ),
                                    Text("Stock existing inventory"),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 2,
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/product.png',
                                      width: 20.0,
                                    ),
                                    Text("Add product"),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 3,
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/user.png',
                                      width: 20.0,
                                    ),
                                    Text("Add customer"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.0,
                      vertical: 15.0,
                    ),
                    child: GestureDetector(
                        child: FaIcon(
                          FontAwesomeIcons.barcode,
                          color: Colors.purpleAccent,
                        ),
                        onTap: () async {
                          await ImagePicker().getImage(
                            source: ImageSource.camera,
                          );
                        }),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.0,
                    ),
                    child: GestureDetector(
                      child: Icon(
                        Icons.search,
                        color: Colors.purpleAccent,
                      ),
                      onTap: () {
                        setState(() {
                          searchMode = true;
                          fn.requestFocus();
                        });
                      },
                    ),
                  ),
                ],
          title: index == 0
              ? searchMode
                  ? TextField(
                      focusNode: fn,
                      decoration: InputDecoration(
                        hintText: "Search all products",
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 150.0,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              isExpanded: true,
                              hint: Text("Select"),
                              value: cur,
                              items: [
                                DropdownMenuItem(
                                  child: Text(
                                    "All products",
                                    style: TextStyle(
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  value: 1,
                                ),
                                DropdownMenuItem(
                                  child: Text(
                                    "Home page",
                                    style: TextStyle(
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  value: 2,
                                )
                              ],
                              onChanged: (newValue) {
                                setState(() {
                                  cur = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    )
              : index == 1
                  ? Transform(
                      transform: Matrix4.translationValues(-20, 0, 0),
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 15.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Orders",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15.0,
                              ),
                            ),
                            Text(
                              "Address not available",
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 12.0),
                            ),
                          ],
                        ),
                      ),
                    )
                  : null,
        ),
      ),
      body: searchMode
          ? null
          : Stack(
              children: <Widget>[
                Offstage(
                  offstage: index != 0,
                  child: TickerMode(
                    enabled: index == 0,
                    child: _CheckoutPage(),
                  ),
                ),
                Offstage(
                  offstage: index != 1,
                  child: TickerMode(
                    enabled: index == 1,
                    child: _OrderList(),
                  ),
                ),
                Offstage(
                  offstage: index != 2,
                  child: TickerMode(
                    enabled: index == 2,
                    child: _StorePage(),
                  ),
                ),
              ],
            ),
      floatingActionButton: index == 0
          ? Container(
              height: 50.0,
              width: MediaQuery.of(context).size.width - 30,
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentPage(),
                    ),
                  );
                },
                backgroundColor: Colors.deepPurpleAccent,
                label: IntrinsicHeight(
                  child: Row(
                    children: <Widget>[
                      Transform(
                        transform: Matrix4.translationValues(-30.0, 0, 0),
                        child: Row(
                          children: <Widget>[
                            Text(
                              "3",
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                            ),
                            SizedBox(
                              width: 20.0,
                            ),
                            Container(
                              height: 50.0,
                              child: VerticalDivider(
                                thickness: 2.0,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 30.0,
                      ),
                      Center(
                        child: Text(
                          "SUBTOTAL \$185.00",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                shape: RoundedRectangleBorder(),
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          onTap: (idx) {
            setState(() {
              this.index = idx;
            });
          },
          selectedItemColor: Colors.deepPurpleAccent,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              title: Text(
                'Checkout',
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.card_travel),
              title: Text(
                'Orders',
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.store),
              title: Text(
                'Store',
              ),
            ),
          ]),
    );
  }
}

class _OrderList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 10.0,
            bottom: 10.0,
            left: 10.0,
          ),
          child: Text("November 3, 2020"),
        ),
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
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
                horizontal: 10.0,
              ),
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 80.0),
                    child: MaterialButton(
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OrderPage()));
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("#1001"),
                          Column(
                            children: [
                              Text(
                                "9:24AM",
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                "\$240",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 13.0),
            child: Container(
              height: 50.0,
              width: MediaQuery.of(context).size.width - 30,
              child: RaisedButton(
                elevation: 5.0,
                color: Colors.white,
                child: Text(
                  "QUICK SALE",
                  style:
                      TextStyle(color: Colors.deepPurpleAccent, fontSize: 15.0),
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => QuickSale()));
                },
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: ListView(
            children: <Widget>[
              _ListItem(
                title: 'Mug Cup',
                imageUrl: 'assets/cup.jpeg',
                num: 15,
                isActive: true,
              ),
              _ListItem(
                title: 'Chair',
                imageUrl: 'assets/chair.jpg',
                num: 36,
                isActive: true,
              ),
              _ListItem(
                title: 'napkin 1 pack',
                imageUrl: 'assets/napkin.jpeg',
                num: 0,
                isActive: false,
              ),
              _ListItem(
                title: 'notebooks',
                imageUrl: 'assets/notebooks.jpg',
                num: 11,
                isActive: true,
              ),
              _ListItem(
                title: 'tumbler',
                imageUrl: 'assets/tumbler.jpg',
                num: 45,
                isActive: true,
              ),
              _ListItem(
                title: 'Standard Clock',
                imageUrl: 'assets/clock.jpg',
                num: 0,
                isActive: false,
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _StorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _ListItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final int num;
  final int price;
  bool isActive = false;

  _ListItem(
      {@required this.imageUrl,
      @required this.title,
      @required this.num,
      @required this.price,
      this.isActive});

  @override
  Widget build(BuildContext context) {
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
                                  color: isActive == true
                                      ? Colors.black
                                      : Colors.grey[500]),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            Text(
                              "$num in stock",
                              style: TextStyle(color: Colors.black45),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  ButtonTheme(
                    padding: EdgeInsets.all(0),
                    minWidth: 0,
                    height: 0,
                    child: MaterialButton(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
            )),
        Divider(),
      ],
    );
  }
}
