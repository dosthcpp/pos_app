import 'package:flutter/material.dart';

class AddShippingAddress extends StatefulWidget {
  @override
  _AddShippingAddressState createState() => _AddShippingAddressState();
}

class _AddShippingAddressState extends State<AddShippingAddress> {
  int cur = 1;

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
              Icons.close,
              color: Colors.purpleAccent,
            ),
            onTap: () => Navigator.of(context).pop(),
          ),
          title: Transform(
            transform: Matrix4.translationValues(-40.0, 0, 0),
            child: Text(
              "Add customer address",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: Container(
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
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Address",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black45),
              ),
              SizedBox(
                height: 5.0,
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: "First name",
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: "Last name",
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: "Phone",
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: "Street Name*",
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: "Street Name 2",
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: "City *",
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Country",
                    style: TextStyle(
                      fontSize: 12.0,
                    ),
                  ),
                  DropdownButton(
                    isExpanded: true,
                    hint: Text("Select"),
                    value: cur,
                    items: [
                      DropdownMenuItem(
                        child: Text(
                          "South Korea",
                        ),
                        value: 1,
                      ),
                      DropdownMenuItem(
                        child: Text(
                          "North Korea",
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
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "State/Province",
                    style: TextStyle(
                      fontSize: 12.0,
                    ),
                  ),
                  DropdownButton(
                    isExpanded: true,
                    hint: Text("Select"),
                    value: cur,
                    items: [
                      DropdownMenuItem(
                        child: Text(
                          "Gangwon",
                        ),
                        value: 1,
                      ),
                      DropdownMenuItem(
                        child: Text(
                          "Seoul",
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
                ],
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: "ZIP/Postal code *",
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: "Company",
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: "Phone number",
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Text("* Required fields")
            ],
          ),
        ),
      ),
    );
  }
}
