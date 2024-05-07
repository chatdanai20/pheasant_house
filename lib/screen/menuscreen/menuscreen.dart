import 'package:flutter/material.dart';
import 'package:pheasant_house/constants.dart';

import '../customcard/cardHeat.dart';
import '../customcard/cardammonia.dart';
import '../customcard/cardclean.dart';
import '../customcard/cardgraph.dart';
import '../customcard/cardmoisture.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<bool> isSelected = [true, false, false, false, false];
  List<Widget> cards = [
    const CardHeat(),
    const CardAmmonia(),
    const CardMoisture(),
    const CardGraph(),
    const CardClean(),
  ];

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
                        width: 70,
                        height: 70,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Image.asset(
                            'asset/images/Logo.png',
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
                            'Welcome',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'To Pheasant House',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
            height: MediaQuery.of(context).size.height / 1.12,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (int i = 0; i < isSelected.length; i++)
                      bottomAction(i, '${getImageName(i)}.png'),
                  ],
                ),
                const SizedBox(
                  height: kDefaultPadding * 0.8,
                ),
                cards[getSelectedIndex()],
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
        return 'image4';
      case 4:
        return 'icon_clean';
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
            width: 30,
            height: 30,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
