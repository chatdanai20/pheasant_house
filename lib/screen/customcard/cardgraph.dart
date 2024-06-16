import 'package:flutter/material.dart';
import 'package:pheasant_house/screen/chartscreen/chartscreen2.dart';
import 'package:pheasant_house/screen/chartscreen/chartscreen3.dart';
import 'package:pheasant_house/screen/chartscreen/chartscreen4.dart';
import 'package:pheasant_house/screen/chartscreen/chartscreen5.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../constants.dart';
import '../chartscreen/chartscreen1.dart';

class CardGraph extends StatefulWidget {
  final String email;
  final String farmName;

  const CardGraph({super.key, required this.email, required this.farmName});

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
          SizedBox(
            height: MediaQuery.of(context).size.height / 1.9,
            width: MediaQuery.of(context).size.width / 1.6,
            child: Stack(
              children: [
                PageView(
                  controller: _controller,
                  children: [
                    Column(
                      children: [
                        ChartBar1(email: widget.email, farmName: widget.farmName),
                        exportData('ความเข้มแสง'),
                      ],
                    ),
                    Column(
                      children: [
                        ChartBar2(email: widget.email, farmName: widget.farmName),
                        exportData('อุณหภูมิ'),
                      ],
                    ),
                    Column(
                      children: [
                        ChartBar3(email: widget.email, farmName: widget.farmName),
                        exportData('ความชื้นในอากาศ'),
                      ],
                    ),
                    Column(
                      children: [
                        ChartBar4(email: widget.email, farmName: widget.farmName),
                        exportData('ความชื้นในดิน'),
                      ],
                    ),
                    Column(
                      children: [
                        ChartBar5(email: widget.email, farmName: widget.farmName),
                        exportData('แอมโมเนีย'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SmoothPageIndicator(
            controller: _controller,
            count: 5,
            effect: const ExpandingDotsEffect(
              dotHeight: 14,
            ),
          ),
        ],
      ),
    );
  }

  exportData(String title) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'ข้อมูลย้อนหลัง$title',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'วัน/เดือน/ปี - วัน/เดือน/ปี',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 25,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        bottom(context, kContainerSearchColor, 'ค้นหา'),
        const SizedBox(
          height: 10,
        ),
        bottom(context, kContainerPDFColor, 'PDF'),
        const SizedBox(
          height: 10,
        ),
        bottom(context, kContainerExcelColor, 'Excel'),
      ],
    );
  }

  Container bottom(BuildContext context, Color color, String text) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.6,
      height: MediaQuery.of(context).size.height / 27,
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
