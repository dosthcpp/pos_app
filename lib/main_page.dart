import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
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
          actions: <Widget>[
            ButtonTheme(
              minWidth: 0,
              height: 0,
              child: MaterialButton(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: Icon(
                  Icons.add,
                  color: Colors.deepPurpleAccent,
                ),
                onPressed: () {},
              ),
            ),
            ButtonTheme(
              minWidth: 0,
              height: 0,
              child: MaterialButton(
                child: Icon(
                  Icons.search,
                  color: Colors.deepPurpleAccent,
                ),
                onPressed: () {},
              ),
            )
          ],
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 150.0,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    isExpanded: true,
                    hint: Text("Select"),
                    value: 1,
                    items: [
                      DropdownMenuItem(
                        child: Text(
                            "All collections",
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                            ),
                        ),
                        value: 1
                      )
                    ], onChanged: (newValue) {  },
                  ),
                ),
              ),

            ],
          )
        ),
      ),
      body: Column(
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
                  child: Text("QUICK SALE",
                    style: TextStyle(
                      color: Colors.deepPurpleAccent,
                      fontSize: 15.0
                    ),
                  ),
                  onPressed: () {},
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
      ),
      floatingActionButton: Container(
        height: 50.0,
        width: MediaQuery.of(context).size.width - 30,
        child: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: Colors.deepPurpleAccent,
          label: IntrinsicHeight(
            child: Row(
              children: <Widget>[
                Transform(
                  transform: Matrix4.translationValues(-30.0, 0, 0),
                  child: Row(
                    children: <Widget>[
                      Text("3",
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
                  child: Text("SUBTOTAL \$185.00",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.0
                      ),
                  ),
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepPurpleAccent,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            title: Text('Checkout'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_travel),
            title: Text('Orders'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            title: Text('Store'),
          ),
        ]
      ),
    );
  }
}

class _ListItem extends StatelessWidget {

  final String imageUrl;
  final String title;
  final int num;
  bool isActive = true;

  _ListItem({
    @required this.imageUrl,
    @required this.title,
    @required this.num,
    this.isActive,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
            height: 100,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 18.0
              ),
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
                            )
                        ),
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
                                color: isActive == true ? Colors.black : Colors.grey[500]
                              ),
                            ),
                            SizedBox(height: 8.0,),
                            Text(
                              "$num in stock",
                              style: TextStyle(
                                  color: Colors.black45
                              ),
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
                            borderRadius: BorderRadius.circular(30.0)
                        ),
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
            )
        ),
        Divider(),
      ],
    );
  }
}

