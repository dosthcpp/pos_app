import 'dart:convert';
import 'dart:io' show File;
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

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
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as pp;
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/animated_focus_light.dart';
import 'package:tutorial_coach_mark/custom_target_position.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class MainPage extends StatefulWidget {
  static const id = 'main_page';

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  bool searchMode = false;
  bool isMainMenu = true;

  int currentOrderIdx = 0;
  int rightPageIdx = 0;
  int leftPageIdx = 0;
  int orderTitleIdx = 0;

  List<ImageProvider> providers = [];

  // title: encodedImage
  Map<String, String> base64EncodedImages = {};
  String itemName = '';
  List<String> itemNames = [];
  TextEditingController _itemNameController = TextEditingController();
  String itemPrice = '';
  List<String> itemPrices = [];
  TextEditingController _itemPriceController = TextEditingController();
  int functionSnapshotIdx = 0;
  List<Function> functionSnapshot = List<Function>(2048);

  int orderForRenderIdx = 0;

  final fn = FocusNode();

  bool willUseCash = false;
  double cashGet = 0.0;
  bool promotion = false;

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
    _loadData();
    _initFunctionSnapshot();
    orderProvider.loadData(functionSnapshot);
    initPlatformState();
    initTargets();
    orderProvider.loadBalance();
    _showDialog();
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
          actions: [
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context, "OK");
              },
            ),
          ],
        );
      },
    ).then(
      (_) {
        if(orderProvider.balance == 0.0) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          orderProvider.initBalance(val);
                        },
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: 'Balance?',
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
            },
          );
        }
      },
    );
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
                  children: [
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
                  children: [
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
                  children: [
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
                  children: [
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
                  children: [
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
        bluetooth.printLeftRight("Net Amount", "\$6.29", 1);
        bluetooth.printLeftRight("Tax", "\$0.69", 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Total", "\$6.99", 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Cash :", "\$6.99", 1);
        bluetooth.printLeftRight("Charge due :", "\$0.00", 1);
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
          if (orderProvider.itemList.length != 0) {
            bluetooth.printLeftRight("Item name / PPU /", "# / Total price", 1);
          }
          orderProvider.itemList.forEach((el) {
            bluetooth.printLeftRight(
                "${el.title} \$${el.price}", "1 \$${el.price}", 1);
          });
          if (orderProvider.itemList.length != 0) {
            bluetooth.printCustom("----------------------------", 1, 1);
          }
          bluetooth.printLeftRight("Subtotal", "\$${orderProvider.price}", 1);
          bluetooth.printLeftRight(
              "Net Amount", "\$${orderProvider.price / 10 * 9}", 1);
          bluetooth.printLeftRight("Tax", "\$${orderProvider.price / 10}", 1);
          bluetooth.printCustom("----------------------------", 1, 1);
          if (promotion) {
            bluetooth.printLeftRight("Promotion", "\$20.0", 1);
            bluetooth.printCustom("----------------------------", 1, 1);
          }
          bluetooth.printLeftRight(
              "Total",
              "\$${promotion ? orderProvider.price - 20 : orderProvider.price}0",
              1);
          bluetooth.printCustom("----------------------------", 1, 1);
          if (willUseCash) {
            bluetooth.printLeftRight("Cash :", "\$$cashGet", 1);
            bluetooth.printLeftRight(
                "Charge due :",
                "${promotion ? "\$${-(orderProvider.price - cashGet - 20) == -0 ? 0.0 : -(orderProvider.price - cashGet - 20.0)}0" : "\$${cashGet - orderProvider.price}0"}",
                1);
            bluetooth.printCustom("----------------------------", 1, 1);
          } else {
            bluetooth.printLeftRight("Card", "MasterCard", 1);
            bluetooth.printLeftRight("Membership No. :", "96641334156***", 1);
            bluetooth.printCustom("Card Approval No. :", 1, 0);
            bluetooth.printCustom("20201120112005123", 1, 2);
            bluetooth.printLeftRight("Affiliate No. :", "3230", 1);
            bluetooth.printCustom("----------------------------", 1, 1);
          }
          bluetooth.printLeftRight("Membership Credit", "\$0.99}", 1);
          bluetooth.printLeftRight(
              "Membership Card No. : ", "*********6912", 1);
          bluetooth.printCustom("Approval No : 577145", 1, 1);
          bluetooth.printCustom("Balance: \$0.00", 1, 1);
          bluetooth.printCustom("----------------------------", 1, 1);
          bluetooth.printCustom(
              "Please Charge your card since your balance is \$0.00", 0, 0);
          bluetooth.printCustom("My reward (GB29**)", 0, 0);
          bluetooth.printCustom("My coupon No : 755F47HB2B7A98C9", 0, 0);
          bluetooth.printCustom("----------------------------", 1, 1);
          bluetooth.printNewLine();
          bluetooth.printNewLine();
          bluetooth.paperCut();
        }
      },
    );
  }

  void _printReceiptOnOrderPage(order, _useCash, _promotion) async {
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
          if (order.itemList.length != 0) {
            bluetooth.printLeftRight("Item name / PPU /", "# / Total price", 1);
          }
          order.itemList.forEach((el) {
            bluetooth.printLeftRight(
                "${el.title} \$${el.price}", "1 \$${el.price}", 1);
          });
          if (order.itemList.length != 0) {
            bluetooth.printCustom("----------------------------", 1, 1);
          }
          bluetooth.printLeftRight("Subtotal", "\$${order.totalPrice}", 1);
          bluetooth.printLeftRight(
              "Net Amount", "\$${order.totalPrice / 10 * 9}", 1);
          bluetooth.printLeftRight("Tax", "\$${order.totalPrice / 10}", 1);
          bluetooth.printCustom("----------------------------", 1, 1);
          if (promotion) {
            bluetooth.printLeftRight("Promotion", "\$20.0", 1);
            bluetooth.printCustom("----------------------------", 1, 1);
          }
          bluetooth.printLeftRight(
              "Total",
              "\$${order.promotion ? order.totalPrice - 20 : order.totalPrice}0",
              1);
          bluetooth.printCustom("----------------------------", 1, 1);
          if (willUseCash) {
            bluetooth.printLeftRight("Cash :", "\$${order.cashGet}", 1);
            bluetooth.printLeftRight(
                "Charge due :",
                "${order.promotion ? "\$${-(order.totalPrice - order.cashGet - 20) == -0 ? 0.0 : -(order.totalPrice - order.cashGet - 20.0)}0" : "\$${order.cashGet - order.totalPrice}0"}",
                1);
            bluetooth.printCustom("----------------------------", 1, 1);
          } else {
            bluetooth.printLeftRight("Card", "MasterCard", 1);
            bluetooth.printLeftRight("Membership No. :", "96641334156***", 1);
            bluetooth.printCustom("Card Approval No. :", 1, 0);
            bluetooth.printCustom("20201120112005123", 1, 2);
            bluetooth.printLeftRight("Affiliate No. :", "3230", 1);
            bluetooth.printCustom("----------------------------", 1, 1);
          }
          bluetooth.printLeftRight("Membership Credit", "\$0.99}", 1);
          bluetooth.printLeftRight(
              "Membership Card No. : ", "*********6912", 1);
          bluetooth.printCustom("Approval No : 577145", 1, 1);
          bluetooth.printCustom("Balance: \$0.00", 1, 1);
          bluetooth.printCustom("----------------------------", 1, 1);
          bluetooth.printCustom(
              "Please Charge your card since your balance is \$0.00", 0, 0);
          bluetooth.printCustom("My reward (GB29**)", 0, 0);
          bluetooth.printCustom("My coupon No : 755F47HB2B7A98C9", 0, 0);
          bluetooth.printCustom("----------------------------", 1, 1);
          bluetooth.printNewLine();
          bluetooth.printNewLine();
          bluetooth.paperCut();
        }
      },
    );
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
      case 21:
        return "Receipt";
    }
  }

  _refresh() async {
    String jsonString = "["
        "{";
    if (itemNames.length == 0) {
      jsonString += "}]";
    } else {
      for (var i = 0; i < itemNames.length; ++i) {
        jsonString +=
            '"itemName": "${itemNames.elementAt(i)}", "itemPrice": "${itemPrices.elementAt(i)}", "image": "${base64EncodedImages[itemNames.elementAt(i)]}"}';
        if (i != itemNames.length - 1) {
          jsonString += ",{";
        }
      }
      jsonString += "]";
    }
    final directory = await pp.getApplicationDocumentsDirectory();
    final file = File('${directory.path}/product.json');
    await file.writeAsString(jsonString);
  }

  _loadData() async {
    Future.delayed(Duration.zero, () async {
      final file = File(
          '${(await pp.getApplicationDocumentsDirectory()).path}/product.json');
      if (!file.existsSync()) return;
      String data = await file.readAsString();
      List<dynamic> jsonResult = json.decode(data);
      if (data == "[{}]" && jsonResult[0].length == 0) {
        itemNames = [];
        itemPrices = [];
        providers = [];
        base64EncodedImages = {};
        currentOrderIdx = 0;
      } else {
        jsonResult.forEach((item) {
          itemNames.add(item['itemName']);
          itemPrices.add(item['itemPrice']);
          base64EncodedImages[item['itemName']] = item['image'];
          providers.add(MemoryImage(base64Decode(item['image'])));
        });
        currentOrderIdx = itemNames.length;
      }
    });
  }

  _initFunctionSnapshot() {
    for (int i = 0; i < 2048; ++i) {
      functionSnapshot[i] = (idx) {
        setState(() {
          rightPageIdx = 18;
          isMainMenu = false;
          orderForRenderIdx = idx;
          orderTitleIdx = idx;
        });
      };
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
                        Visibility(
                          visible: leftPageIdx == 0,
                          child: TextButton(
                            onPressed: () {
                              if (currentOrderIdx != 5) {
                                setState(() {
                                  leftPageIdx = 1;
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
                              }
                            },
                            child: Text(
                              "+ADD ITEM",
                              style: TextStyle(
                                color: currentOrderIdx != 5
                                    ? Colors.blueAccent
                                    : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ],
                      backgroundColor: Colors.white,
                    ),
                  ),
                  body: Column(
                    children: [
                      Expanded(
                        flex: 10,
                        child: Stack(
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
                                            final onLongPress = () {
                                              setState(() {
                                                base64EncodedImages?.remove(
                                                    itemNames.elementAt(index));
                                                itemNames?.removeAt(index);
                                                itemPrices?.removeAt(index);
                                                providers?.removeAt(index);
                                                currentOrderIdx--;
                                              });
                                              _refresh();
                                            };
                                            return Product(
                                              onLongPress: onLongPress,
                                              title:
                                                  itemNames?.elementAt(index),
                                              price:
                                                  itemPrices?.elementAt(index),
                                              image:
                                                  providers?.elementAt(index),
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
                                child: SingleChildScrollView(
                                  child: Container(
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                            keyboardType: TextInputType.text,
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
                                            keyboardType: TextInputType.number,
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
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                            child: MaterialButton(
                                              padding: EdgeInsets.all(10.0),
                                              child: !providers
                                                      .asMap()
                                                      .containsKey(
                                                          currentOrderIdx)
                                                  ? Image.asset(
                                                      'assets/cloud-computing.png',
                                                      width: 280.0,
                                                    )
                                                  : Image(
                                                      image: providers[
                                                          currentOrderIdx],
                                                      width: 280.0,
                                                    ),
                                              onPressed: () async {
                                                FilePickerResult result =
                                                    await FilePicker.platform
                                                        .pickFiles();

                                                if (result != null) {
                                                  String filePath =
                                                      result.files.single.path;
                                                  Uint8List cmpressedImage =
                                                      await FlutterImageCompress
                                                          .compressWithFile(
                                                              filePath,
                                                              format:
                                                                  CompressFormat
                                                                      .jpeg,
                                                              quality: 70);

                                                  if (providers
                                                      .asMap()
                                                      .containsKey(
                                                          currentOrderIdx)) {
                                                    setState(() {
                                                      // 전에꺼 지우고 추가
                                                      providers.removeAt(
                                                          currentOrderIdx);
                                                    });
                                                  }
                                                  base64EncodedImages[
                                                          itemName] =
                                                      base64Encode(
                                                          cmpressedImage);
                                                  setState(() {
                                                    providers.add(
                                                      MemoryImage(
                                                          cmpressedImage),
                                                    );
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
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                              color: Color(0xff01A0C7),
                                              child: MaterialButton(
                                                minWidth: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                padding: EdgeInsets.fromLTRB(
                                                    20.0, 15.0, 20.0, 15.0),
                                                onPressed: () async {
                                                  if (currentOrderIdx == 5) {
                                                  } else if (itemNames
                                                          .where((_itemName) =>
                                                              _itemName ==
                                                              itemName)
                                                          .toList()
                                                          .length !=
                                                      0) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
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
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
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
                                                          .containsKey(
                                                              currentOrderIdx)) {
                                                    setState(() {
                                                      itemNames.add(itemName);
                                                      itemPrices.add(itemPrice);
                                                      currentOrderIdx++;
                                                      itemName = '';
                                                      _itemNameController
                                                          .clear();
                                                      itemPrice = '';
                                                      _itemPriceController
                                                          .clear();
                                                      leftPageIdx = 0;
                                                    });
                                                    _refresh();
                                                  } else {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
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
                                                                    context,
                                                                    "OK");
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
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.0,
                                          ),
                                          SizedBox(
                                            width: 300.0,
                                            child: Material(
                                              elevation: 5.0,
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                              color: Colors.blueGrey,
                                              child: MaterialButton(
                                                minWidth: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                padding: EdgeInsets.fromLTRB(
                                                    20.0, 15.0, 20.0, 15.0),
                                                onPressed: () {
                                                  setState(() {
                                                    if (providers
                                                        .asMap()
                                                        .containsKey(
                                                            currentOrderIdx)) {
                                                      providers.removeAt(
                                                          currentOrderIdx);
                                                      base64EncodedImages
                                                          .remove(itemNames[
                                                              currentOrderIdx]);
                                                    }
                                                    itemName = '';
                                                    _itemNameController.clear();
                                                    itemPrice = '';
                                                    _itemPriceController
                                                        .clear();
                                                    leftPageIdx = 0;
                                                  });
                                                },
                                                child: Text(
                                                  "Cancel",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 20.0,
                                                  ).copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
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
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: 20.0,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Total Balance",
                                    style: TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Consumer<OrderProvider>(
                                    builder: (context, provider, _) {
                                      return Text.rich(
                                        TextSpan(
                                          text: '\$',
                                          style: TextStyle(
                                            color: provider.balance > 0
                                                ? Colors.blue
                                                : Colors.red,
                                            fontSize: 15.0,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: "${provider.balance}0",
                                              style: TextStyle(
                                                fontSize: 21.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
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
                                ?
                                // Dummy
                                // Row(
                                //         children: [
                                //           SizedBox(
                                //             width: 30.0,
                                //             height: 40.0,
                                //             child: PopupMenuButton(
                                //               onSelected: (value) {
                                //                 switch (value) {
                                //                   case 1:
                                //                     setState(() {
                                //                       rightPageIdx = 3;
                                //                       isMainMenu = false;
                                //                     });
                                //                     break;
                                //                   case 2:
                                //                     setState(() {
                                //                       rightPageIdx = 4;
                                //                       isMainMenu = false;
                                //                     });
                                //                     break;
                                //                   case 3:
                                //                     setState(() {
                                //                       rightPageIdx = 5;
                                //                       isMainMenu = false;
                                //                     });
                                //                     break;
                                //                   default:
                                //                     break;
                                //                 }
                                //               },
                                //               icon: Icon(
                                //                 Icons.add,
                                //                 color: Colors.purpleAccent,
                                //               ),
                                //               itemBuilder: (context) => [
                                //                 PopupMenuItem(
                                //                   value: 0,
                                //                   child: Text(
                                //                     "Actions",
                                //                     style: TextStyle(
                                //                       color: Colors.black,
                                //                     ),
                                //                   ),
                                //                   enabled: false,
                                //                 ),
                                //                 PopupMenuItem(
                                //                   value: 1,
                                //                   child: Row(
                                //                     children: [
                                //                       Image.asset(
                                //                         'assets/packages.png',
                                //                         width: 20.0,
                                //                       ),
                                //                       Text(
                                //                           "Stock existing inventory"),
                                //                     ],
                                //                   ),
                                //                 ),
                                //                 PopupMenuItem(
                                //                   value: 2,
                                //                   child: Row(
                                //                     children: [
                                //                       Image.asset(
                                //                         'assets/product.png',
                                //                         width: 20.0,
                                //                       ),
                                //                       Text("Add product"),
                                //                     ],
                                //                   ),
                                //                 ),
                                //                 PopupMenuItem(
                                //                   value: 3,
                                //                   child: Row(
                                //                     children: [
                                //                       Image.asset(
                                //                         'assets/user.png',
                                //                         width: 20.0,
                                //                       ),
                                //                       Text("Add customer"),
                                //                     ],
                                //                   ),
                                //                 ),
                                //               ],
                                //             ),
                                //           ),
                                //           Padding(
                                //             padding: EdgeInsets.symmetric(
                                //               horizontal: 5.0,
                                //               vertical: 15.0,
                                //             ),
                                //             child: Transform(
                                //               transform: Matrix4.translationValues(
                                //                   3, -7, 0),
                                //               child: GestureDetector(
                                //                 child: FaIcon(
                                //                   FontAwesomeIcons.barcode,
                                //                   color: Colors.purpleAccent,
                                //                 ),
                                //                 onTap: () async {
                                //                   await ImagePicker().getImage(
                                //                     source: ImageSource.camera,
                                //                   );
                                //                 },
                                //               ),
                                //             ),
                                //           ),
                                //           Padding(
                                //             padding: EdgeInsets.symmetric(
                                //               horizontal: 10.0,
                                //             ),
                                //             child: GestureDetector(
                                //               child: Icon(
                                //                 Icons.search,
                                //                 color: Colors.purpleAccent,
                                //               ),
                                //               onTap: () {
                                //                 setState(() {
                                //                   searchMode = true;
                                //                   fn.requestFocus();
                                //                 });
                                //               },
                                //             ),
                                //           ),
                                //         ],
                                //       )
                                Container()
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
                                                  orderProvider.startDatePicked,
                                                ),
                                              );
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
                                                  orderProvider.endDatePicked,
                                                ),
                                              );
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
                                : rightPageIdx == 22
                                    ? Transform(
                                        transform: Matrix4.translationValues(
                                            -20, 0, 0),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            left: 15.0,
                                          ),
                                          child: Text(
                                            "Purchase",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18.0,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Transform(
                                        transform: Matrix4.translationValues(
                                            -20, 0, 0),
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
                                                    // back button
                                                    isMainMenu = true;
                                                    if (rightPageIdx >= 3 &&
                                                            rightPageIdx <= 6 ||
                                                        rightPageIdx == 19) {
                                                      rightPageIdx = 0;
                                                    } else if (rightPageIdx >=
                                                            7 &&
                                                        rightPageIdx <= 14) {
                                                      rightPageIdx = 2;
                                                    } else if (rightPageIdx >=
                                                            15 &&
                                                        rightPageIdx <= 17) {
                                                      rightPageIdx = 7;
                                                    } else if (rightPageIdx ==
                                                        18) {
                                                      rightPageIdx = 1;
                                                    } else if (rightPageIdx ==
                                                        20) {
                                                      rightPageIdx = 19;
                                                      isMainMenu = false;
                                                    } else if (rightPageIdx ==
                                                        21) {
                                                      rightPageIdx = 20;
                                                      isMainMenu = false;
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
                          Offstage(
                            offstage: rightPageIdx != 22,
                            child: TickerMode(
                              enabled: rightPageIdx == 22,
                              child: Purchase(),
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
                              child: Settings(
                                resetAll: () {
                                  setState(() {
                                    itemNames = [];
                                    itemPrices = [];
                                    providers = [];
                                    base64EncodedImages = {};
                                    currentOrderIdx = 0;
                                    _loadData();
                                  });
                                },
                              ),
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
                                            actions: [
                                              FlatButton(
                                                child: Text('OK'),
                                                onPressed: () {
                                                  Navigator.pop(
                                                    context,
                                                  );
                                                  setState(() {
                                                    rightPageIdx = 15;
                                                  });
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
                                (order, _useCash, _promotion) {
                                  _printReceiptOnOrderPage(
                                      order, _useCash, _promotion);
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
                                (_willUseCash) async {
                                  if (_willUseCash) {
                                    await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content: Row(
                                              children: [
                                                Expanded(
                                                  child: TextField(
                                                    keyboardType:
                                                        TextInputType.number,
                                                    onChanged: (val) {
                                                      cashGet =
                                                          double.parse(val);
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
                                      (_) => setState(() {
                                        final _promo = promotion ? 20 : 0;
                                        if (cashGet + _promo <
                                            orderProvider.price) {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Alert!'),
                                                  content: Text(
                                                    "Please pay more than the total price.",
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
                                              });
                                        } else {
                                          rightPageIdx = 20;
                                          isMainMenu = false;
                                          willUseCash = _willUseCash;
                                        }
                                      }),
                                    );
                                  } else {
                                    setState(() {
                                      rightPageIdx = 20;
                                      isMainMenu = false;
                                      willUseCash = _willUseCash;
                                    });
                                  }
                                },
                                price: orderProvider.price,
                                promotion: orderProvider.price < 20
                                    ? false
                                    : promotion,
                                willPromo: (_promo) {
                                  if (orderProvider.price < 20) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Alert!'),
                                            content: Text(
                                              "Promotion cannot be applied since total price is less than \$20.",
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
                                        });
                                  } else {
                                    setState(() {
                                      promotion = _promo;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          Offstage(
                            offstage: rightPageIdx != 20,
                            child: TickerMode(
                              enabled: rightPageIdx == 20,
                              child: PaymentResult(
                                () => _printReceipt(),
                                () async {
                                  // DONE 누르면
                                  orderProvider.addOrder(
                                    Order(
                                      functionSnapshot[functionSnapshotIdx++] =
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
                                      cash: willUseCash,
                                      cashGet: cashGet,
                                      promotion: promotion,
                                      // base64EncodedImages에서 찾아서 image 리스트 넘기기
                                    ),
                                  );
                                  orderProvider.modifyBalance(
                                      orderProvider.price, true);
                                  orderProvider.clearListItem();
                                  orderProvider.orderUp();
                                  setState(() {
                                    rightPageIdx = 0;
                                    isMainMenu = true;
                                  });
                                  await orderProvider
                                      .refresh(Map.from(base64EncodedImages));
                                },
                                () {
                                  setState(() {
                                    rightPageIdx = 21;
                                  });
                                },
                                orderProvider.price,
                                willUseCash: willUseCash,
                                cashGet: cashGet,
                                promotion: promotion,
                              ),
                            ),
                          ),
                          Offstage(
                            offstage: rightPageIdx != 21,
                            child: TickerMode(
                              enabled: rightPageIdx == 21,
                              child: Receipt(
                                willUseCash,
                                cashGet,
                                promotion,
                              ),
                            ),
                          ),
                        ],
                      ),
                floatingActionButton: rightPageIdx == 0
                    ? Container(
                        key: subTotalButton,
                        height: 50.0,
                        width: 330,
                        child: Transform(
                          transform: Matrix4.translationValues(10, 0, 0),
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
                        ),
                      )
                    : rightPageIdx == 22
                        ? FloatingActionButton.extended(
                            heroTag: 'btn2',
                            onPressed: () {
                              if (orderProvider.purchaseTotalPrice != 0.0) {
                                orderProvider.modifyBalance(
                                    orderProvider.purchaseTotalPrice, false);
                                orderProvider.clearPurchaseTotal();
                              }
                            },
                            backgroundColor:
                                Colors.lightBlueAccent.withOpacity(0.8),
                            label: Center(
                              child: Icon(
                                Icons.check,
                              ),
                            ),
                          )
                        : null,
                bottomNavigationBar: Visibility(
                  visible: isMainMenu,
                  child: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    selectedItemColor: Colors.deepPurpleAccent,
                    unselectedItemColor: Colors.black54,
                    onTap: (idx) {
                      setState(() {
                        switch (idx) {
                          case 0:
                          case 1:
                            rightPageIdx = idx;
                            break;
                          case 2:
                            rightPageIdx = 22;
                            break;
                          case 3:
                            rightPageIdx = 2;
                        }
                      });
                    },
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.shopping_cart),
                        label: 'Checkout',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.card_travel),
                        label: 'Orders',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.add_business),
                        label: 'Purchase',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.store),
                        label: 'Store',
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
          flex: 11,
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
        Expanded(
          child: MaterialButton(
            child: Center(
              child: Text(
                "Export orders",
              ),
            ),
            onPressed: () {
              orderProvider.exportAsPdf();
            },
          ),
        )
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
  bool cash = false;
  final double cashGet;
  final bool promotion;

  Order(this.callback,
      {this.date,
      this.itemList,
      this.totalPrice,
      this.orderNo,
      this.cash,
      this.cashGet,
      this.promotion});

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
        // Dummy
        // Center(
        //   child: Padding(
        //     padding: EdgeInsets.symmetric(vertical: 13.0),
        //     child: Container(
        //       height: 50.0,
        //       width: MediaQuery.of(context).size.width - 30,
        //       child: RaisedButton(
        //         elevation: 5.0,
        //         color: Colors.white,
        //         child: Text(
        //           "QUICK SALE",
        //           style:
        //               TextStyle(color: Colors.deepPurpleAccent, fontSize: 15.0),
        //         ),
        //         onPressed: callback,
        //       ),
        //     ),
        //   ),
        // ),
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
  final keyboardType;

  _AddItemField(this.title,
      {this.callback, this.controller, this.keyboardType});

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
          keyboardType: keyboardType,
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

class Purchase extends StatefulWidget {
  @override
  _PurchaseState createState() => _PurchaseState();
}

class _PurchaseState extends State<Purchase> {
  DateTime initDate = DateTime.now();

  String itemName = '';
  double price = 0.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          Expanded(
            flex: 9,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: 10,
                            ),
                            child: Text(
                              "Date: ${initDate.toString().split(' ')[0]}",
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.date_range,
                            ),
                            onPressed: () async {
                              DateTime picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  // Refer step 1
                                  firstDate: DateTime(2019),
                                  lastDate: DateTime(2023),
                                  initialEntryMode:
                                      DatePickerEntryMode.calendar,
                                  locale: Locale('en'),
                                  helpText: "Select Date",
                                  cancelText: 'Cancel',
                                  confirmText: 'OK',
                                  builder: (context, child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        primaryColor: Colors.black54,
                                        accentColor:
                                            Colors.pinkAccent, //selection color
                                      ),
                                      child: child,
                                    );
                                  });
                              if (picked != null && picked != initDate) {
                                if (picked.isAfter(DateTime.now())) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Alert!"),
                                        content: Text(
                                          "Date selected must be earlier or as same as today.",
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
                                    },
                                  );
                                } else {
                                  setState(() {
                                    initDate = picked;
                                  });
                                }
                              }
                            },
                          ),
                        ],
                      ),
                      TextButton(
                        child: Text("Add Item"),
                        onPressed: () async {
                          await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        onChanged: (_itemName) {
                                          itemName = _itemName;
                                        },
                                        autofocus: true,
                                        decoration: InputDecoration(
                                          labelText: 'Item Name',
                                        ),
                                      ),
                                      TextField(
                                        keyboardType: TextInputType.number,
                                        onChanged: (_price) {
                                          price = double.parse(_price);
                                        },
                                        autofocus: true,
                                        decoration: InputDecoration(
                                          labelText: 'Item Price',
                                        ),
                                      ),
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
                              }).then((_) {
                            orderProvider.addPurchase(ItemInPurchase(
                              (idx) {
                                orderProvider.modifyPurchaseTotal(
                                    orderProvider.purchaseList
                                        .elementAt(idx)
                                        .price,
                                    false);
                                orderProvider.removePurchase(idx);
                              },
                              itemName: itemName,
                              price: price,
                            ));
                            orderProvider.modifyPurchaseTotal(price, true);
                          });
                        },
                      )
                    ],
                  ),
                ),
                Consumer<OrderProvider>(
                  builder: (context, provider, _) {
                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.0,
                        mainAxisSpacing: 10.0,
                        crossAxisSpacing: 10.0,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return provider.purchaseList[index]
                            ..idx = () {
                              return index;
                            };
                        },
                        childCount: provider.purchaseList.length,
                      ),
                    );
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: Consumer<OrderProvider>(builder: (context, provider, _) {
              return Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text("SUB TOTAL"),
                    Text.rich(
                      TextSpan(
                        text: '\$',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                        ),
                        children: [
                          TextSpan(
                            text: "${provider.purchaseTotalPrice}0",
                            style: TextStyle(
                              fontSize: 25.0,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          )
        ],
      ),
    );
  }
}

class ItemInPurchase extends StatelessWidget {
  final Function callback;
  final String itemName;
  final double price;
  Function idx;

  ItemInPurchase(this.callback, {this.itemName, this.price});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width / 6,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(0.5, 0.0),
              // 10% of the width, so there are ten blinds.
              colors: [
                Colors.lightBlue.withOpacity(0.1),
                Colors.lightBlueAccent.withOpacity(0.5),
              ], // red to yellow
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 10.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "\$${price}0",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.close),
            onPressed: () {
              callback(idx());
            },
          ),
        ),
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
                            children: [
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

class Product extends StatelessWidget {
  final onLongPress;
  final image;
  final price;
  final title;

  Product({this.onLongPress, this.image, this.price, this.title});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: Colors.grey[200],
        width: 80,
        child: Center(
          child: Align(
            alignment: Alignment.center,
            child: Image(
              image: image,
            ),
          ),
        ),
      ),
      onTap: () {
        var _price = double.parse(price);
        orderProvider.addList(
          ItemList(
            title: title,
            image: image,
            price: _price,
            itemCount: 1,
          ),
          _price,
        );
      },
      onLongPress: onLongPress,
    );
  }
}

class Receipt extends StatelessWidget {
  final divider = Text(
    "----------------------------------------------",
    style: TextStyle(letterSpacing: 2.5),
  );

  final bool willUseCash;
  final cashGet;
  final bool promotion;
  GlobalKey scr = GlobalKey();

  Receipt(this.willUseCash, this.cashGet, this.promotion);

  _renderDate() =>
      "${DateTime.now().toString().split(' ')[0]} ${DateTime.now().toString().split(' ')[1].split('.')[0]}";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 10,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Align(
              alignment: Alignment.center,
              child: RepaintBoundary(
                key: scr,
                child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width / 3 - 20,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 20.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "GAVIN INNOVATION",
                          style: TextStyle(fontSize: 25),
                        ),
                        Text(
                          "Receipt",
                          style: TextStyle(
                              fontSize: 20, letterSpacing: 5.0, height: 2.0),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Address:",
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "[POS 01]",
                                  ),
                                  Text(
                                    _renderDate(),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        divider,
                        orderProvider?.itemList?.length != 0
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Item name",
                                    textAlign: TextAlign.start,
                                  ),
                                  Text("PPU"),
                                  Text("#"),
                                  Text("Total price")
                                ],
                              )
                            : Container(),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: orderProvider?.itemList?.length ?? 0,
                          itemBuilder: (context, index) {
                            final price =
                                orderProvider.itemList.elementAt(index).price;
                            final itemCount = orderProvider.itemList
                                .elementAt(index)
                                .itemCount;
                            final subTotalPrice = price * itemCount;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  orderProvider.itemList.elementAt(index).title,
                                ),
                                Text("\$${price}0"),
                                Text(itemCount.toString()),
                                Text("\$${subTotalPrice.toString()}0"),
                              ],
                            );
                          },
                        ),
                        orderProvider?.itemList?.length != 0
                            ? divider
                            : Container(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Subtotal",
                            ),
                            Text("\$${orderProvider.price}0"),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Net Amount",
                            ),
                            Text("\$${orderProvider.price * 0.9}0"),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Tax",
                            ),
                            Text("\$${orderProvider.price * 0.1}0"),
                          ],
                        ),
                        divider,
                        promotion
                            ? Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Promotion",
                                      ),
                                      Text("\$20.00"),
                                    ],
                                  ),
                                  divider,
                                ],
                              )
                            : Container(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total",
                            ),
                            Text(
                              "\$${promotion ? orderProvider.price - 20 : orderProvider.price}0",
                            ),
                          ],
                        ),
                        divider,
                        willUseCash
                            ? Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Cash :",
                                      ),
                                      Text("\$${cashGet.toString()}0"),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Charge due:",
                                      ),
                                      Text(
                                        "${promotion ? "\$${-(orderProvider.price - cashGet - 20) == -0 ? 0.0 : -(orderProvider.price - cashGet - 20.0)}0" : "\$${cashGet - orderProvider.price}0"}",
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Card :",
                                      ),
                                      Text("MasterCard"),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Membership No. : ",
                                      ),
                                      Text("96641334156***"),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Card Approval No. : ",
                                      ),
                                      Text("20201120112005123"),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Affiliate No. : ",
                                      ),
                                      Text("3230"),
                                    ],
                                  ),
                                ],
                              ),
                        divider,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Membership Credit :",
                            ),
                            Text("\$0.99"),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Membership Card No. :",
                            ),
                            Text("**********6912"),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Approval No: 577145",
                            ),
                            Text("Balance: \$0.00"),
                          ],
                        ),
                        divider,
                        Text(
                          "Please Charge your card since your balance is \$0.00",
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "My reward (GB29**)",
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "My coupon No: 1590230415049",
                          ),
                        ),
                        divider,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: SizedBox.expand(
            child: RaisedButton(
              child: Text("Email receipt"),
              onPressed: () async {
                RenderRepaintBoundary boundary =
                    scr.currentContext.findRenderObject();
                final directory = (await pp.getExternalStorageDirectory()).path;
                var image = await boundary.toImage();
                var byteData =
                    await image.toByteData(format: ImageByteFormat.png);
                var pngBytes = byteData.buffer.asUint8List();
                File imgFile = File('$directory/receipt.png');
                imgFile.writeAsBytes(pngBytes);

                final Email email = Email(
                  body: 'Receipt',
                  subject: 'Receipt',
                  recipients: ['tedjung@ciousya.com'],
                  attachmentPaths: ['$directory/receipt.png'],
                  isHTML: false,
                );

                await FlutterEmailSender.send(email);
              },
            ),
          ),
        )
      ],
    );
  }
}
