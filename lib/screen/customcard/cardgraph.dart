import 'package:flutter/material.dart';
import 'package:pheasant_house/screen/chartscreen/chartscreen2.dart';
import 'package:pheasant_house/screen/chartscreen/chartscreen3.dart';
import 'package:pheasant_house/screen/chartscreen/chartscreen4.dart';
import 'package:pheasant_house/screen/chartscreen/chartscreen5.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../constants.dart';
import '../chartscreen/chartscreen1.dart';

class CardGraph extends StatefulWidget {
  const CardGraph({super.key});

  @override
  State<CardGraph> createState() => _CardGraphState();
}

class _CardGraphState extends State<CardGraph> {
  final PageController _controller = PageController();

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
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 3.5,
            width: MediaQuery.of(context).size.width / 1.6,
            child: Stack(
              children: [
                PageView(
                  controller: _controller,
                  children: [
                    const LineChart1(),
                    ChartBar2(),
                    ChartBar3(),
                    ChartBar4(),
                    ChartBar5(),
                  ],
                ),
              ],
            ),
          ),
          SmoothPageIndicator(
            controller: _controller,
            count: 5,
            effect: const ExpandingDotsEffect(
              dotHeight: 14,
            ),
          ),
          const SizedBox(
            height: 10,
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
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        'ข้อมูลย้อนหลัง',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 30,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('วันเดือนปี '),
              Icon(Icons.calendar_today_outlined),
              Text(' - วันเดือนปี '),
              Icon(Icons.calendar_today_outlined),
            ],
          ),
          sizedBox,
          bottom(context, kContainerSearchColor, 'ค้นหา'),
          const SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              bottom(context, kContainerPDFColor, 'PDF'),
              bottom(context, kContainerExcelColor, 'Excel'),
            ],
          ),
        ],
      ),
    );
  }

  Container bottom(BuildContext context, Color color, String text) {
    return Container(
      width: MediaQuery.of(context).size.width / 5,
      height: MediaQuery.of(context).size.height / 28,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(
          Radius.circular(2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.9),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 0.5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
