import 'package:flutter/material.dart';

import '../../constants.dart';
import '../popupscreen/popupscreen.dart';

class CardClean extends StatefulWidget {
  const CardClean({super.key});

  @override
  State<CardClean> createState() => _CardCleanState();
}

class _CardCleanState extends State<CardClean> {
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
          Image.asset('asset/images/carbon_clean.png'),
          const SizedBox(
            height: 50,
          ),
          Container(
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
                      Image.asset('asset/images/carbon_clean.png', scale: 6.5),
                      const SizedBox(
                        width: 5,
                      ),
                      const Text(
                        'วันทำความสะอาด :',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  const Icon(
                    Icons.calendar_month,
                    size: 25,
                  )
                ],
              ),
            ),
          ),
          sizedBox,
          Container(
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
                      Image.asset('asset/images/carbon_clean.png', scale: 6.5),
                      const SizedBox(
                        width: 5,
                      ),
                      const Text(
                        'เวลา :',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  const Text(
                    ' วัน',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PopupClean()));
                },
                child: Text(
                  'ตั้งค่าทำความสะอาด',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kTextBlackColor.withOpacity(0.5),
                  ),
                ),
              ),
              Icon(
                Icons.settings_outlined,
                color: kTextBlackColor.withOpacity(0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
