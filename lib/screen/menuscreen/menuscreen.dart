import 'package:flutter/material.dart';
import 'package:pheasant_house/constants.dart';
import 'package:pheasant_house/screen/customcard/cardclean.dart';

import '../customcard/card-clean-roof.dart';
import '../customcard/cardHeat.dart';
import '../customcard/cardammonia.dart';
import '../customcard/cardmoisture.dart';
import 'package:pheasant_house/screen/customcard/cardnotiammonia.dart';
import 'package:pheasant_house/screen/customcard/cardnotitemp.dart';

class MenuScreen extends StatefulWidget {
  final String farmName; // เพิ่มพารามิเตอร์ farmName ในคอนสตรักเตอร์

  const MenuScreen({Key? key, required this.farmName}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late List<bool> isSelected;
  late List<Widget> cards;

  @override
  void initState() {
    super.initState();
    isSelected = [true, false, false, false,false,false,false];
    cards = [
      const CardHeat(),
      const CardAmmonia(),
      const CardMoisture(),
      const CardCleanRoof(),
      CardClean(farmName: widget.farmName), // สร้าง CardClean ใน initState()
      CardNotificationTemp(farmName: widget.farmName),
      CardNotificationAmmonia(farmName: widget.farmName),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 10,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF254E5A),
                          size: 40,
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Image.asset(
                            'asset/images/Logo2.png',
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Control And Setting',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          /*Text(
                            '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),*/
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height ,
            decoration: const BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: kDefaultPadding * 0.8,
                ),
                 SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int i = 0; i < isSelected.length; i++)
                        bottomAction(i, '${getImageName(i)}.png'),
                    ],
                  ),
                ),
                const SizedBox(
                  height: kDefaultPadding * 0.8,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: cards[getSelectedIndex()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getImageName(int index) {
    switch (index) {
      case 0:
        return 'li';
      case 1:
        return 'Rectangle78';
      case 2:
        return 'icon3';
      case 3:
        return 'snowing';
      case 4:
        return 'icon_clean';
      case 5:
        return 'icontemp';
      case 6:
        return 'NH3';
      default:
        return '';
    }
  }

  int getSelectedIndex() {
    for (int i = 0; i < isSelected.length; i++) {
      if (isSelected[i]) {
        return i;
      }
    }
    return 0;
  }

  Container bottomAction(int index, String image) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isSelected[index] ? kIconTrueColor : kIconFalseColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: GestureDetector(
        onTap: () {
          setState(() {
            for (int i = 0; i < isSelected.length; i++) {
              isSelected[i] = (i == index);
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'asset/images/$image',
            width: 25,
            height: 25,
            color: Colors.black,
             // เพิ่มการปรับขนาดรูปในไอคอนสำหรับการ์ดที่ 5 และ 6
            scale: (index == 5 || index == 6) ? 1.0 : 1.0,
          ),
        ),
      ),
    );
  }
}