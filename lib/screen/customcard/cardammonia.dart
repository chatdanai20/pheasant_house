import 'package:flutter/material.dart';
import 'package:pheasant_house/constants.dart';

import '../popupscreen/popupscreen.dart';

class CardAmmonia extends StatefulWidget {
  final bool initialIsOpen;
  final bool initialIsAuto;

  const CardAmmonia({
    Key? key,
    this.initialIsOpen = false,
    this.initialIsAuto = true,
  }) : super(key: key);

  @override
  State<CardAmmonia> createState() => _CardAmmoniaState();
}

class _CardAmmoniaState extends State<CardAmmonia> {
  late bool isOpen;
  late bool isAuto;

  @override
  void initState() {
    super.initState();
    isOpen = widget.initialIsOpen;
    isAuto = widget.initialIsAuto;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.3,
      height: MediaQuery.of(context).size.height / 1.7,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(80),
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          sizedBox,
          Image.asset('asset/images/Rectangle78.png'),
          sizedBox,
          buildStatusRow(),
          buildSwitchRow(
              'เปิด/ปิด', isOpen, (value) => setState(() => isOpen = value)),
          buildSwitchRow(
              'อัตโนมัติ', isAuto, (value) => setState(() => isAuto = value)),
          sizedBox,
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const PopupTemp()));
            },
            child: buildInfoContainer(
                'อุณหภูมิ', ' C', 'asset/images/Rectangle78.png', 7),
          ),
          sizedBox,
          GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PopupSmell()));
              },
              child: buildInfoContainer(
                  'แอมโมเนียม', ' pH', 'asset/images/image3.png', 4)),
        ],
      ),
    );
  }

  Widget buildStatusRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'สถานะ : ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Text(
          isOpen ? 'เปิด' : 'ปิด',
          style: TextStyle(
            color: isOpen ? Colors.green : Colors.red,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget buildSwitchRow(
      String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$label : ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Switch(
          activeColor: Colors.green,
          activeTrackColor: Colors.green[200],
          inactiveTrackColor: Colors.red[200],
          inactiveThumbColor: Colors.white,
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget buildInfoContainer(
      String title, String unit, String imageAsset, double scale) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.6,
      height: MediaQuery.of(context).size.height / 20,
      decoration: const BoxDecoration(
        color: Color(0xFF6FC0C5),
        borderRadius: BorderRadius.all(
          Radius.circular(14),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Image.asset(
                  imageAsset,
                  scale: scale,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 30,
            ),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
