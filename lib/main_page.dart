import 'dart:convert';
import 'dart:io' show File;
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:pos_app/addCustomer.dart';
import 'package:pos_app/addInventory.dart';
import 'package:pos_app/addProduct.dart';
import 'package:pos_app/main.dart';
import 'package:pos_app/orderPage.dart';
import 'package:pos_app/paymentPage.dart';
import 'package:pos_app/payment_result.dart';
import 'package:pos_app/quickSale.dart';
import 'package:pos_app/storePage/apps.dart';
import 'package:pos_app/storePage/hardware.dart';
import 'package:pos_app/storePage/location.dart';
import 'package:pos_app/storePage/payment.dart';
import 'package:pos_app/storePage/settings.dart';
import 'package:pos_app/storePage/support.dart';
import 'package:pos_app/storePage/tips.dart';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/animated_focus_light.dart';
import 'package:tutorial_coach_mark/custom_target_position.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

// RenderRepaintBoundary boundary =
// scr.currentContext
//     .findRenderObject();
// final directory = (await pp.getApplicationDocumentsDirectory()).path;
// var image =
// await boundary.toImage();
// var byteData =
// await image.toByteData(
//     format:
//     ImageByteFormat.png);
// var pngBytes =
// byteData.buffer.asUint8List();
// print(pngBytes);
// File imgFile = File('$directory/screenshot.png');
// print(directory);
// imgFile.writeAsBytes(pngBytes);
// final RenderBox box =
// keys[index].currentContext.findRenderObject();
//
// final position =
// box.getTransformTo(null).getTranslation();
// final topLeft = {position.x, position.y};
// final topRight = {
//   position.x + box.size.width,
//   position.y
// };
// final bottomLeft = {
//   position.x,
//   position.y + box.size.height
// };
// final bottomRight = {
//   position.x + box.size.width,
//   position.y + box.size.height
// };
// print(topLeft);
// print(topRight);
// print(bottomLeft);
// print(bottomRight);

class MainPage extends StatefulWidget {
  static const id = 'main_page';

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  bool searchMode = false;
  bool isMainMenu = true;

  int imageIdx = 0;
  int rightPageIdx = 0;
  int leftPageIdx = 0;
  int orderTitleIdx = 0;

  List<ImageProvider> providers = [];
  String itemName = '';
  List<String> itemNames = [];
  TextEditingController _itemNameController = TextEditingController();
  String itemPrice = '';
  List<String> itemPrices = [];
  TextEditingController _itemPriceController = TextEditingController();

  int orderForRenderIdx = 0;

  final fn = FocusNode();

  bool isCashPage = false;
  double cashGet = 0.0;

  // final scr = GlobalKey();

  TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = List();
  final productsGrid = GlobalKey();
  final subTotalButton = GlobalKey();
  final paymentButton = PaymentPage.paymentButton;
  final printReceiptKey = PaymentResult.printReceiptKey;
  final salesPage = _CheckoutPage.salesPage;

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _pressed = false;

  @override
  void initState() {
    orderProvider.initDate();
    _showDialog();
    initPlatformState();
    initTargets();
  }

  _selectDate(help, initialDate) async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        // Refer step 1
        firstDate: DateTime(2019),
        lastDate: DateTime(2023),
        initialEntryMode: DatePickerEntryMode.calendar,
        locale: Locale('en'),
        helpText: help,
        cancelText: 'Cancel',
        confirmText: 'OK',
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: Colors.black54,
              accentColor: Colors.pinkAccent, //selection color
            ),
            child: child,
          );
        });
    if (picked != null && picked != initialDate) {
      return picked;
    } else {
      return initialDate;
    }
  }

  _showDialog() async {
    await Future.delayed(Duration(milliseconds: 50));
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('This is DEMO version'),
            content: Text(
                "Thank you for using our product.\nThis is the free trial period.\nPlease search for 'ONE POS' on Facebook!"),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context, "OK");
                },
              ),
            ],
          );
        });
  }

  void showTutorial() {
    setState(() {
      rightPageIdx = 0;
      isMainMenu = true;
    });
    tutorialCoachMark = TutorialCoachMark(context,
        targets: targets,
        colorShadow: Colors.red,
        textSkip: "SKIP",
        paddingFocus: 10,
        opacityShadow: 0.8, onFinish: () {
      _printReceipt();
      setState(() {
        rightPageIdx = 0;
        isMainMenu = true;
      });
    }, onClickTarget: (target) {
      if (target.keyTarget == subTotalButton?.currentWidget?.key) {
        setState(() {
          rightPageIdx = 19;
          isMainMenu = false;
        });
      } else if (target.keyTarget == paymentButton?.currentWidget?.key) {
        setState(() {
          rightPageIdx = 20;
        });
      }
    }, onClickSkip: () {
      // ...
    })
      ..show();
  }

  void initTargets() {
    Future.delayed(Duration.zero, () {
      double width = MediaQuery.of(context).size.width;
      targets.add(
        TargetFocus(
          identify: "Target 1",
          keyTarget: productsGrid,
          color: Colors.purple,
          contents: [
            ContentTarget(
              align: AlignContent.custom,
              customPosition: CustomTargetPosition(
                bottom: 50,
                left: width / 3 * 2 + 10,
              ),
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Adding products",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "You can add some products by simply clicking these\nproducts.",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
          shape: ShapeLightFocus.RRect,
          radius: 5,
        ),
      );
      targets.add(
        TargetFocus(
          identify: "Target 2",
          keyTarget: salesPage,
          color: Colors.purple,
          contents: [
            ContentTarget(
              align: AlignContent.bottom,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Products list",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "These are products list.",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
          shape: ShapeLightFocus.RRect,
          radius: 5,
        ),
      );
      targets.add(
        TargetFocus(
          identify: "Target 3",
          keyTarget: subTotalButton,
          color: Colors.purple,
          contents: [
            ContentTarget(
              align: AlignContent.custom,
              customPosition: CustomTargetPosition(
                bottom: 0,
                left: 0,
              ),
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Click ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "You can add some products by simply clicking these\nproducts.",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
          shape: ShapeLightFocus.RRect,
          radius: 5,
        ),
      );
      targets.add(
        TargetFocus(
          identify: "Target 4",
          keyTarget: paymentButton,
          color: Colors.purple,
          contents: [
            ContentTarget(
              align: AlignContent.custom,
              customPosition: CustomTargetPosition(
                bottom: 0,
                left: 0,
              ),
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Payment methods",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "These are payments methods. You can ",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
          shape: ShapeLightFocus.RRect,
          radius: 5,
        ),
      );
      targets.add(
        TargetFocus(
          identify: "Target 5",
          keyTarget: printReceiptKey,
          color: Colors.purple,
          contents: [
            ContentTarget(
              align: AlignContent.custom,
              customPosition: CustomTargetPosition(
                bottom: 0,
                left: 0,
              ),
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Payment methods",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "These are payments methods. You can ",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
          shape: ShapeLightFocus.RRect,
          radius: 5,
        ),
      );
    });
  }

  Future<void> initPlatformState() async {
    List<BluetoothDevice> devices = [];

    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      // TODO - Error
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            _pressed = false;
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            _pressed = false;
          });
          break;
        default:
          print(state);
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });
  }

  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  void _connect() {
    if (_device == null) {
      show('No device selected.');
    } else {
      bluetooth.isConnected.then((isConnected) {
        if (!isConnected) {
          bluetooth.connect(_device).catchError((error) {
            setState(() => _pressed = false);
          });
          setState(() => _pressed = true);
        }
      });
    }
  }

  void _disconnect() {
    bluetooth.disconnect();
    setState(() => _pressed = true);
  }

  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(Duration(milliseconds: 100));
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        duration: duration,
      ),
    );
  }

  void _testPrint() async {
    bluetooth.isConnected.then((isConnected) {
      if (isConnected) {
        bluetooth.printCustom("GAVIN INNOVATION", 3, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom("RECEIPT", 3, 1);
        bluetooth.printLeftRight("Address:", "", 0);
        bluetooth.printLeftRight("[POS 01]",
            DateTime.now().toString().split(' ')[1].split('.')[0], 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Item name / PPU /", "# / Total price", 1);
        bluetooth.printLeftRight("A Mug cup \$6.99", "1 \$6.99", 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Subtotal", "\$6.99", 1);
        bluetooth.printLeftRight("Net Amount", "\$6.99", 1);
        bluetooth.printLeftRight("Tax", "\$0.99", 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Total", "\$0.99", 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Promotion", "\$4.99", 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Card", "MasterCard", 1);
        bluetooth.printLeftRight("Membership No. :", "96641334156***", 1);
        bluetooth.printCustom("Card Approval No. :", 1, 0);
        bluetooth.printCustom("20201120112005123", 1, 2);
        bluetooth.printLeftRight("Affiliate No. :", "3230", 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Membership Credit", "\$0.99", 1);
        bluetooth.printLeftRight("Membership Card", "*********6912", 1);
        bluetooth.printCustom("Approval No : 577145", 1, 1);
        bluetooth.printCustom("Balance: \$0.00", 1, 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printCustom(
            "Please Charge your card since your balance is \$0.00", 0, 0);
        bluetooth.printCustom("My reward (GB29**)", 0, 0);
        bluetooth.printCustom("My coupon No : 1590230415049", 0, 0);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Cash :", "\$2.00", 1);
        bluetooth.printLeftRight("Charge due :", "\$0.00", 1);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.paperCut();
      }
    });
  }

  void _printReceipt() async {
    bluetooth.isConnected.then(
      (isConnected) {
        if (isConnected) {
          bluetooth.printCustom("GAVIN INNOVATION", 3, 1);
          bluetooth.printNewLine();
          bluetooth.printCustom("RECEIPT", 3, 1);
          bluetooth.printLeftRight("Address:", "", 0);
          bluetooth.printLeftRight("[POS 01]",
              DateTime.now().toString().split(' ')[1].split('.')[0], 1);
          bluetooth.printCustom("----------------------------", 1, 1);
          bluetooth.printLeftRight("Item name / PPU /", "# / Total price", 1);
          orderProvider.itemList.forEach((el) {
            bluetooth.printLeftRight(
                "${el.title} \$${el.price}", "1 \$${el.price}", 1);
          });
          bluetooth.printCustom("----------------------------", 1, 1);
          bluetooth.printLeftRight("Subtotal", "\$${orderProvider.price}", 1);
          bluetooth.printLeftRight("Net Amount", "\$${orderProvider.price}", 1);
          bluetooth.printLeftRight("Tax", "\$${orderProvider.price / 10}", 1);
          bluetooth.printCustom("----------------------------", 1, 1);
          bluetooth.printLeftRight("Total", "\$${orderProvider.price}", 1);
          bluetooth.printCustom("----------------------------", 1, 1);
          bluetooth.printLeftRight("Promotion", "\$20.0", 1);
          bluetooth.printCustom("----------------------------", 1, 1);
          bluetooth.printLeftRight("Card", "MasterCard", 1);
          bluetooth.printLeftRight("Membership No. :", "96641334156***", 1);
          bluetooth.printCustom("Card Approval No. :", 1, 0);
          bluetooth.printCustom("20201120112005123", 1, 2);
          bluetooth.printLeftRight("Affiliate No. :", "3230", 1);
          bluetooth.printCustom("----------------------------", 1, 1);
          bluetooth.printLeftRight(
              "Membership Credit", "\$${orderProvider.price}", 1);
          bluetooth.printLeftRight("Membership Card", "*********6912", 1);
          bluetooth.printCustom("Approval No : 577145", 1, 1);
          bluetooth.printCustom("Balance: \$0.00", 1, 1);
          bluetooth.printCustom("----------------------------", 1, 1);
          bluetooth.printCustom(
              "Please Charge your card since your balance is \$0.00", 0, 0);
          bluetooth.printCustom("My reward (GB29**)", 0, 0);
          bluetooth.printCustom("My coupon No : 755F47HB2B7A98C9", 0, 0);
          bluetooth.printCustom("----------------------------", 1, 1);
          bluetooth.printLeftRight("Cash :", "\$0.00", 1);
          bluetooth.printLeftRight("Charge due :", "\$0.00", 1);
          bluetooth.printNewLine();
          bluetooth.printNewLine();
          bluetooth.paperCut();
        }
      },
    );
  }

  void _printReceiptOnOrderPage() async {
    bluetooth.isConnected.then((isConnected) {
      if (isConnected) {
        bluetooth.printCustom("GAVIN INNOVATION", 3, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom("RECEIPT", 3, 1);
        bluetooth.printLeftRight("Address:", "", 0);
        bluetooth.printLeftRight("[POS 01]",
            DateTime.now().toString().split(' ')[1].split('.')[0], 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Item name / PPU /", "# / Total price", 1);
        bluetooth.printLeftRight("Walnut Planter \$61.6", "3 \$61.60", 1);
        bluetooth.printLeftRight("Mug cup \$24.25", "1 \$24.25", 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Subtotal", "\$209.05", 1);
        bluetooth.printLeftRight("Net Amount", "\$209.05", 1);
        bluetooth.printLeftRight("Tax", "\$20.90", 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Total", "\$209.05", 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Promotion", "\$0.00", 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Card", "MasterCard", 1);
        bluetooth.printLeftRight("Membership No. :", "96641334156***", 1);
        bluetooth.printCustom("Card Approval No. :", 1, 0);
        bluetooth.printCustom("20201120112005123", 1, 2);
        bluetooth.printLeftRight("Affiliate No. :", "3230", 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Membership Credit", "\$209.05", 1);
        bluetooth.printLeftRight("Membership Card", "*********6912", 1);
        bluetooth.printCustom("Approval No : 577145", 1, 1);
        bluetooth.printCustom("Balance: \$0.00", 1, 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printCustom(
            "Please Charge your card since your balance is \$0.00", 0, 0);
        bluetooth.printCustom("My reward (GB29**)", 0, 0);
        bluetooth.printCustom("My coupon No : 1590230415049", 0, 0);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Cash :", "\$0.00", 1);
        bluetooth.printLeftRight("Charge due :", "\$0.00", 1);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.paperCut();
      }
    });
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devices.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devices.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  String renderTitle() {
    switch (rightPageIdx) {
      case 3:
        return "Stock Existing Inventory";
      case 4:
        return "Add product";
      case 5:
        return "Add customer";
      case 6:
        return "Quick Sale";
      case 7:
        return "Hardware";
      case 8:
        return "Locations";
      case 9:
        return "Payment Types";
      case 10:
        return "Apps";
      case 11:
        return "Tips";
      case 12:
        return "Settings";
      case 13:
        return "Support";
      case 14:
        return "Get Gavin Mobile";
      case 15:
        return "Connect POS printer";
      case 16:
        return "Scan Code";
      case 17:
        return "Purchase pos printer";
      case 18:
        return "Order #${orderTitleIdx + 1001}";
      case 19:
        return "Select Payment";
      case 20:
        return "Order complete";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OrderProvider>.value(
      value: orderProvider,
      child: WillPopScope(
        onWillPop: () async => false,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(40.0),
                    child: AppBar(
                      automaticallyImplyLeading: false,
                      title: Container(
                        width: 150.0,
                        child: Text(
                          "All products",
                          style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              leftPageIdx = 1;
                            });
                          },
                          child: Text("+ADD ITEM"),
                        ),
                      ],
                      backgroundColor: Colors.white,
                    ),
                  ),
                  body: Stack(
                    children: [
                      Offstage(
                        offstage: leftPageIdx != 0,
                        child: TickerMode(
                          enabled: leftPageIdx == 0,
                          child: CustomScrollView(
                            key: productsGrid,
                            slivers: [
                              Container(
                                child: SliverGrid(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 5,
                                    childAspectRatio: 1.0,
                                    mainAxisSpacing: 10.0,
                                    crossAxisSpacing: 10.0,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      return GestureDetector(
                                        child: Container(
                                          color: Colors.grey[200],
                                          width: 80,
                                          child: Center(
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Image(
                                                image: providers[index],
                                              ),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          var _price =
                                              double.parse(itemPrices[index]);
                                          orderProvider.addList(
                                            ItemList(
                                              title: itemNames[index],
                                              image: providers[index],
                                              price: _price,
                                              itemCount: 1,
                                            ),
                                            _price,
                                          );
                                        },
                                      );
                                    },
                                    childCount: itemNames.length,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Offstage(
                        offstage: leftPageIdx != 1,
                        child: TickerMode(
                          enabled: leftPageIdx == 1,
                          child: Container(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Add Item",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  _AddItemField(
                                    "Item name",
                                    callback: (name) {
                                      itemName = name;
                                    },
                                    controller: _itemNameController,
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  _AddItemField(
                                    "Price",
                                    callback: (price) {
                                      itemPrice = price;
                                    },
                                    controller: _itemPriceController,
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: MaterialButton(
                                      padding: EdgeInsets.all(10.0),
                                      child: !providers
                                              .asMap()
                                              .containsKey(imageIdx)
                                          ? Image.asset(
                                              'assets/cloud-computing.png',
                                              width: 280.0,
                                            )
                                          : Image(
                                              image: providers[imageIdx],
                                              width: 280.0,
                                            ),
                                      onPressed: () async {
                                        FilePickerResult result =
                                            await FilePicker.platform
                                                .pickFiles();

                                        if (result != null) {
                                          String filePath =
                                              result.files.single.path;
                                          var _cmpressed_image;
                                          _cmpressed_image =
                                              await FlutterImageCompress
                                                  .compressWithFile(filePath,
                                                      format:
                                                          CompressFormat.jpeg,
                                                      quality: 70);
                                          setState(() {
                                            providers.add(
                                                MemoryImage(_cmpressed_image));
                                          });
                                        } else {
                                          // User canceled the picker
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 300.0,
                                    child: Material(
                                      elevation: 5.0,
                                      borderRadius: BorderRadius.circular(30.0),
                                      color: Color(0xff01A0C7),
                                      child: MaterialButton(
                                        minWidth:
                                            MediaQuery.of(context).size.width,
                                        padding: EdgeInsets.fromLTRB(
                                            20.0, 15.0, 20.0, 15.0),
                                        onPressed: () {
                                          if (imageIdx == 5) {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text(
                                                    'Alert!',
                                                  ),
                                                  content: Text(
                                                    "No more items can be added. Please contact customer service.",
                                                  ),
                                                  actions: [
                                                    FlatButton(
                                                      child: Text('OK'),
                                                      onPressed: () {
                                                        leftPageIdx = 0;
                                                        Navigator.pop(
                                                          context,
                                                          "OK",
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } else if (orderProvider.itemList
                                                  .where((_item) => _item.title
                                                      .contains(itemName))
                                                  .toList()
                                                  .length !=
                                              0) {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text(
                                                    'Alert!',
                                                  ),
                                                  content: Text(
                                                    "Item name duplicates. Please use another name.",
                                                  ),
                                                  actions: [
                                                    FlatButton(
                                                      child: Text('OK'),
                                                      onPressed: () {
                                                        Navigator.pop(
                                                          context,
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } else if (itemName != '' &&
                                              itemName.length != 0 &&
                                              itemPrice != '' &&
                                              itemPrice.length != 0 &&
                                              providers
                                                  .asMap()
                                                  .containsKey(imageIdx)) {
                                            setState(() {
                                              itemNames.add(itemName);
                                              itemPrices.add(itemPrice);
                                              itemName = '';
                                              _itemNameController.clear();
                                              itemPrice = '';
                                              _itemPriceController.clear();
                                              leftPageIdx = 0;
                                              imageIdx++;
                                            });
                                          } else {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text(
                                                    'Alert!',
                                                  ),
                                                  content: Text(
                                                    "You should fill the form.",
                                                  ),
                                                  actions: [
                                                    FlatButton(
                                                      child: Text('OK'),
                                                      onPressed: () {
                                                        Navigator.pop(
                                                            context, "OK");
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        },
                                        child: Text(
                                          "OK",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 20.0,
                                          ).copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                  // bottomNavigationBar: BottomNavigationBar(),
                  ),
            ),
            Expanded(
              flex: 1,
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                resizeToAvoidBottomPadding: false,
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(40.0),
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
                            rightPageIdx == 0
                                ? Row(
                                    children: [
                                      SizedBox(
                                        width: 30.0,
                                        height: 40.0,
                                        child: PopupMenuButton(
                                          onSelected: (value) {
                                            switch (value) {
                                              case 1:
                                                setState(() {
                                                  rightPageIdx = 3;
                                                  isMainMenu = false;
                                                });
                                                break;
                                              case 2:
                                                setState(() {
                                                  rightPageIdx = 4;
                                                  isMainMenu = false;
                                                });
                                                break;
                                              case 3:
                                                setState(() {
                                                  rightPageIdx = 5;
                                                  isMainMenu = false;
                                                });
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
                                                  Text(
                                                      "Stock existing inventory"),
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
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 5.0,
                                          vertical: 15.0,
                                        ),
                                        child: Transform(
                                          transform: Matrix4.translationValues(
                                              3, -7, 0),
                                          child: GestureDetector(
                                            child: FaIcon(
                                              FontAwesomeIcons.barcode,
                                              color: Colors.purpleAccent,
                                            ),
                                            onTap: () async {
                                              await ImagePicker().getImage(
                                                source: ImageSource.camera,
                                              );
                                            },
                                          ),
                                        ),
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
                                  )
                                : rightPageIdx == 1
                                    ? Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.calendar_today,
                                            ),
                                            color: Colors.black54,
                                            onPressed: () async {
                                              orderProvider.selectStartDate(
                                                  context,
                                                  await _selectDate(
                                                      "Start date",
                                                      orderProvider
                                                          .startDatePicked));
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.calendar_today,
                                            ),
                                            color: Colors.black54,
                                            onPressed: () async {
                                              orderProvider.selectEndDate(
                                                  context,
                                                  await _selectDate(
                                                      "End date",
                                                      orderProvider
                                                          .endDatePicked));
                                            },
                                          ),
                                        ],
                                      )
                                    : Container(),
                          ],
                    title: rightPageIdx == 0
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
                                children: [
                                  Container(
                                    width: 150.0,
                                    child: Container(
                                      width: 150.0,
                                      child: Text(
                                        "All products",
                                        style: TextStyle(
                                          fontSize: 17.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                        : rightPageIdx == 1
                            ? Transform(
                                transform: Matrix4.translationValues(-20, 0, 0),
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: 15.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Orders",
                                        style: TextStyle(
                                          fontSize: 17.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : rightPageIdx == 2
                                ? Transform(
                                    transform:
                                        Matrix4.translationValues(-20, 0, 0),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: 15.0,
                                      ),
                                      child: Text(
                                        "Store",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                    ),
                                  )
                                : Transform(
                                    transform:
                                        Matrix4.translationValues(-20, 0, 0),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: 15.0,
                                      ),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            child: Icon(
                                              Icons.arrow_back_ios_outlined,
                                              color: Colors.black54,
                                            ),
                                            onTap: () {
                                              setState(() {
                                                isMainMenu = true;
                                                if (rightPageIdx >= 3 &&
                                                        rightPageIdx <= 6 ||
                                                    rightPageIdx == 19) {
                                                  rightPageIdx = 0;
                                                } else if (rightPageIdx >= 7 &&
                                                    rightPageIdx <= 14) {
                                                  rightPageIdx = 2;
                                                } else if (rightPageIdx >= 15 &&
                                                    rightPageIdx <= 17) {
                                                  rightPageIdx = 7;
                                                } else if (rightPageIdx == 18) {
                                                  rightPageIdx = 1;
                                                } else if (rightPageIdx == 20) {
                                                  rightPageIdx = 19;
                                                }
                                              });
                                            },
                                          ),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Text(
                                            renderTitle(),
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                  ),
                ),
                body: searchMode
                    ? null
                    : Stack(
                        children: [
                          Offstage(
                            offstage: rightPageIdx != 0,
                            child: TickerMode(
                              enabled: rightPageIdx == 0,
                              child: _CheckoutPage(
                                callback: () {
                                  setState(
                                    () {
                                      rightPageIdx = 6;
                                      isMainMenu = false;
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          Offstage(
                            offstage: rightPageIdx != 1,
                            child: TickerMode(
                              enabled: rightPageIdx == 1,
                              child: _OrderList(() {
                                setState(
                                  () {
                                    rightPageIdx = 18;
                                    isMainMenu = false;
                                  },
                                );
                              }),
                            ),
                          ),
                          Offstage(
                            offstage: rightPageIdx != 2,
                            child: TickerMode(
                              enabled: rightPageIdx == 2,
                              child: _StorePage(callback: (idx) {
                                setState(() {
                                  rightPageIdx = idx + 7;
                                  isMainMenu = false;
                                });
                              }),
                            ),
                          ),

                          // Checkout Page -> index = 0
                          Offstage(
                            offstage: rightPageIdx != 3,
                            child: TickerMode(
                              enabled: rightPageIdx == 3,
                              child: AddInventory(),
                            ),
                          ),
                          Offstage(
                            offstage: rightPageIdx != 4,
                            child: TickerMode(
                              enabled: rightPageIdx == 4,
                              child: AddProduct(),
                            ),
                          ),
                          Offstage(
                            offstage: rightPageIdx != 5,
                            child: TickerMode(
                              enabled: rightPageIdx == 5,
                              child: AddCustomer(),
                            ),
                          ),
                          Offstage(
                            offstage: rightPageIdx != 6,
                            child: TickerMode(
                              enabled: rightPageIdx == 6,
                              child: QuickSale(),
                            ),
                          ),

                          // SETTINGS -> index = 2
                          Offstage(
                            offstage: rightPageIdx != 7,
                            child: TickerMode(
                              enabled: rightPageIdx == 7,
                              child: Hardware(
                                callback: (idx) {
                                  setState(() {
                                    rightPageIdx = idx + 15;
                                    isMainMenu = false;
                                  });
                                },
                              ),
                            ),
                          ),
                          Offstage(
                            offstage: rightPageIdx != 8,
                            child: TickerMode(
                              enabled: rightPageIdx == 8,
                              child: Location(),
                            ),
                          ),
                          Offstage(
                            offstage: rightPageIdx != 9,
                            child: TickerMode(
                              enabled: rightPageIdx == 9,
                              child: Payment(),
                            ),
                          ),
                          Offstage(
                            offstage: rightPageIdx != 10,
                            child: TickerMode(
                              enabled: rightPageIdx == 10,
                              child: Apps(),
                            ),
                          ),
                          Offstage(
                            offstage: rightPageIdx != 11,
                            child: TickerMode(
                              enabled: rightPageIdx == 11,
                              child: Tips(),
                            ),
                          ),
                          Offstage(
                            offstage: rightPageIdx != 12,
                            child: TickerMode(
                              enabled: rightPageIdx == 12,
                              child: Settings(),
                            ),
                          ),
                          Offstage(
                            offstage: rightPageIdx != 13,
                            child: TickerMode(
                              enabled: rightPageIdx == 13,
                              child: Support(() async {
                                _connected
                                    ? showTutorial()
                                    : await showDialog(
                                        context: context,
                                        barrierDismissible:
                                            false, // user must tap button!
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                                'POS printer is not connected'),
                                            content: Text(
                                                "You can simply bond your pos printer by visiting hardware page."),
                                            actions: <Widget>[
                                              FlatButton(
                                                child: Text('OK'),
                                                onPressed: () {
                                                  Navigator.pop(context, "OK");
                                                },
                                              ),
                                              FlatButton(
                                                child: Text('Cancel'),
                                                onPressed: () {
                                                  Navigator.pop(
                                                      context, "Cancel");
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                              }),
                            ),
                          ),
                          Offstage(
                            offstage: rightPageIdx != 14,
                            child: TickerMode(
                              enabled: rightPageIdx == 14,
                              child: Padding(
                                padding: EdgeInsets.all(15.0),
                                child: Text("Will be added soon."),
                              ),
                            ),
                          ),

                          // Hardware subpage -> index = 7
                          Offstage(
                            offstage: rightPageIdx != 15,
                            child: TickerMode(
                              enabled: rightPageIdx == 15,
                              child: ConnectCardReader(
                                bluetoothConnection: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    DropdownButton(
                                      items: _getDeviceItems(),
                                      onChanged: (value) =>
                                          setState(() => _device = value),
                                      value: _device,
                                    ),
                                    RaisedButton(
                                      onPressed: _pressed
                                          ? null
                                          : _connected
                                              ? _disconnect
                                              : _connect,
                                      child: Text(_connected
                                          ? 'Disconnect'
                                          : 'Connect'),
                                    ),
                                    MaterialButton(
                                      child: Text("Test print"),
                                      onPressed: () => _testPrint(),
                                    ),
                                  ],
                                ),
                                isConnected: _connected,
                              ),
                            ),
                          ),
                          Offstage(
                            offstage: rightPageIdx != 16,
                            child: TickerMode(
                              enabled: rightPageIdx == 16,
                              child: ScanCode(),
                            ),
                          ),
                          Offstage(
                            offstage: rightPageIdx != 17,
                            child: TickerMode(
                              enabled: rightPageIdx == 17,
                              child: DummyPage(),
                            ),
                          ),

                          // Order page -> index = 1
                          Offstage(
                            offstage: rightPageIdx != 18,
                            child: TickerMode(
                              enabled: rightPageIdx == 18,
                              child: OrderPage(
                                () {
                                  _printReceiptOnOrderPage();
                                },
                                orderForRenderIdx: orderForRenderIdx,
                              ),
                            ),
                          ),
                          // Payment Page
                          Offstage(
                            offstage: rightPageIdx != 19,
                            child: TickerMode(
                              enabled: rightPageIdx == 19,
                              child: PaymentPage(
                                (_isCashPage) async {
                                  if (_isCashPage) {
                                    await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content: Row(
                                              children: [
                                                Expanded(
                                                  child: TextField(
                                                    onChanged: (val) {
                                                      cashGet = double.parse(val);
                                                    },
                                                    autofocus: true,
                                                    decoration: InputDecoration(
                                                      labelText: 'Cash get?',
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            actions: [
                                              FlatButton(
                                                child: Text('OK'),
                                                onPressed: () {
                                                  Navigator.pop(context, "OK");
                                                },
                                              ),
                                            ],
                                          );
                                        }).then(
                                      (cash) => setState(() {
                                        rightPageIdx = 20;
                                        isMainMenu = false;
                                        isCashPage = _isCashPage;
                                      }),
                                    );
                                  } else {
                                    setState(() {
                                      rightPageIdx = 20;
                                      isMainMenu = false;
                                      isCashPage = _isCashPage;
                                    });
                                  }
                                },
                                price: orderProvider.price,
                              ),
                            ),
                          ),
                          Offstage(
                            offstage: rightPageIdx != 20,
                            child: TickerMode(
                              enabled: rightPageIdx == 20,
                              child: PaymentResult(
                                () => _printReceipt(),
                                () {
                                  // DONE 누르면
                                  orderProvider.addOrder(
                                    Order(
                                      (idx) {
                                        setState(() {
                                          rightPageIdx = 18;
                                          isMainMenu = false;
                                          orderForRenderIdx = idx;
                                          orderTitleIdx = idx;
                                        });
                                      },
                                      date: DateTime.now(),
                                      totalPrice: orderProvider.price,
                                      // deep copy
                                      itemList:
                                          List.from(orderProvider.itemList),
                                      orderNo: orderProvider.orderNo,
                                    ),
                                  );
                                  orderProvider.clearListItem();
                                  orderProvider.orderUp();
                                  setState(() {
                                    rightPageIdx = 0;
                                    isMainMenu = true;
                                  });
                                },
                                orderProvider.price,
                                isCashPage: isCashPage,
                                cashGet: cashGet,
                              ),
                            ),
                          )
                        ],
                      ),
                floatingActionButton: rightPageIdx == 0
                    ? Container(
                        key: subTotalButton,
                        height: 50.0,
                        width: 330,
                        child: FloatingActionButton.extended(
                          heroTag: 'btn1',
                          onPressed: () {
                            setState(() {
                              rightPageIdx = 19;
                              isMainMenu = false;
                            });
                          },
                          backgroundColor: Colors.deepPurpleAccent,
                          label: IntrinsicHeight(
                            child: Center(
                              child: Consumer<OrderProvider>(
                                builder: (context, provider, _) => Text(
                                  "SUB TOTAL \$${provider.price}0",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          shape: RoundedRectangleBorder(),
                        ),
                      )
                    : null,
                bottomNavigationBar: Visibility(
                  visible: isMainMenu,
                  child: BottomNavigationBar(
                    selectedItemColor: Colors.deepPurpleAccent,
                    onTap: (idx) {
                      setState(() {
                        rightPageIdx = idx;
                      });
                    },
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatefulWidget {
  final Function callback;

  _OrderList(this.callback);

  @override
  __OrderListState createState() => __OrderListState();
}

class __OrderListState extends State<_OrderList> {
  final List<String> month = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // TODO: date에 따라 필터링 구현

  _parseDate(date) {
    return "${month[date.month - 1]} ${date.day}, ${date.year}";
  }

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
          child: Consumer<OrderProvider>(
            builder: (context, provider, _) => Text(
                "${_parseDate(provider.startDatePicked)} ~ ${_parseDate(provider.endDatePicked)}"),
          ),
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
              child: Consumer<OrderProvider>(
                builder: (context, provider, _) {
                  if (provider.didModifyDate) {
                    if (provider.filteredOrder.isEmpty) {
                      return Text("There are no results.");
                    } else {
                      return ListView.builder(
                        itemCount: provider.filteredOrder?.length ?? 0,
                        itemBuilder: (_context, index) {
                          return provider.filteredOrder[index]
                            ..tapBubblingEvent = () {
                              return index;
                            };
                        },
                      );
                    }
                  } else {
                    if (provider.orders.isEmpty) {
                      return Text("There are no results.");
                    } else {
                      return ListView.builder(
                        itemCount: provider.orders?.length ?? 0,
                        itemBuilder: (_context, index) {
                          return provider.orders[index]
                            ..tapBubblingEvent = () {
                              return index;
                            };
                        },
                      );
                    }
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Order extends StatelessWidget {
  final Function callback;
  Function tapBubblingEvent;

  final DateTime date;

  // date, title, price, itemCount
  final List itemList;
  final totalPrice;
  final orderNo;

  // final title;
  // final price;
  // final itemCount;

  Order(this.callback,
      {this.date, this.itemList, this.totalPrice, this.orderNo});

  _parseDate() {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final hourString = hour < 10 ? "0$hour" : hour;
    final minute = date.minute < 10 ? "0${date.minute}" : date.minute;

    return "${date.toString().split(" ")[0]} $hourString:$minute${date.hour < 13 ? "AM" : "PM"}";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: 80.0),
          child: MaterialButton(
            padding: EdgeInsets.all(0),
            onPressed: () {
              callback(tapBubblingEvent());
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("#$orderNo"),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _parseDate(),
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      "\$$totalPrice",
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
    );
  }
}

class _CheckoutPage extends StatelessWidget {
  final Function callback;
  static final salesPage = GlobalKey();

  _CheckoutPage({this.callback});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                onPressed: callback,
              ),
            ),
          ),
        ),
        Expanded(
          key: _CheckoutPage.salesPage,
          flex: 1,
          child: Consumer<OrderProvider>(
            builder: (context, provider, _) => ListView.builder(
              itemCount: provider.itemList.length,
              itemBuilder: (context, index) {
                final pvd = provider.itemList[index];
                return ItemList(
                  image: pvd.image,
                  title: pvd.title,
                  price: pvd.price,
                  itemCount: pvd.itemCount,
                );
              },
            ),
          ),
        ),
        SizedBox(
          height: 70.0,
        )
      ],
    );
  }
}

class _AddItemField extends StatelessWidget {
  final title;
  final callback;
  final controller;

  _AddItemField(this.title, {this.callback, this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20.0)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 10.0,
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: title,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
          onChanged: callback,
        ),
      ),
    );
  }
}

class _StorePage extends StatelessWidget {
  final Function callback;

  _StorePage({this.callback});

  List<String> _storeImage = [
    'tools.png',
    'placeholder.png',
    'credit-card-store.png',
    'app.png',
    'chat-store.png',
    'settings.png',
    'support.png',
    'smartphone.png'
  ];
  List<String> _menuTitle = [
    'Hardware',
    'Locations',
    'Payment types',
    'Apps',
    'Tips',
    'Settings',
    'Support',
    'Get Gavin mobile'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
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
            child: ListView.builder(
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
                      child: Row(
                        children: [
                          Transform(
                            transform: Matrix4.translationValues(-15, 0, 0),
                            child: SizedBox(
                              width: 30.0,
                              child: Image.asset(
                                'assets/${_storeImage[index]}',
                              ),
                            ),
                          ),
                          Text(
                            _menuTitle[index],
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              itemCount: _menuTitle.length,
            ),
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
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
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Transform(
                          transform: Matrix4.translationValues(-15, 0, 0),
                          child: Text(
                            "Log out of App",
                            style: TextStyle(
                                fontSize: 16.0, color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class ItemList extends StatelessWidget {
  // final String imageUrl;
  final ImageProvider image;

  final String title;
  final double price;
  int itemCount;

  ItemList({
    @required this.image,
    @required this.title,
    @required this.price,
    @required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MaterialButton(
          padding: EdgeInsets.all(0),
          onPressed: () {
            orderProvider.removeList(itemCount, title, price);
          },
          child: Container(
              height: 100,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 80.0,
                          child: Image(image: image),
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
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(
                                height: 8.0,
                              ),
                              Text(
                                "\$$price",
                              ),
                              SizedBox(
                                height: 8.0,
                              ),
                              Text(
                                "count: $itemCount",
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
        ),
        Divider(),
      ],
    );
  }
}
