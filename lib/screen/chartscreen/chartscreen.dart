import 'package:flutter/material.dart';
import 'package:pheasant_house/screen/chartscreen/chartscreen1.dart';
import 'package:pheasant_house/screen/chartscreen/chartscreen2.dart';
import 'package:pheasant_house/screen/chartscreen/chartscreen3.dart';
import 'package:pheasant_house/screen/chartscreen/chartscreen4.dart';
import 'package:pheasant_house/screen/chartscreen/chartscreen5.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../constants.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 10),
              child: Row(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Text(
                        'ข้อมูลย้อนหลัง',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.82,
              child: PageView(
                controller: _controller,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          header('ความเข้มแสง'),
                          const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: ChartBar1(),
                          ),
                          exportData(),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          header('อุณหภูมิ'),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ChartBar2(),
                          ),
                          exportData(),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          header('ความชื้นในอากาศ'),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ChartBar3(),
                          ),
                          exportData(),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          header('ความชื้นในดิน'),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ChartBar4(),
                          ),
                          exportData(),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          header('แอมโมเนีย'),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ChartBar5(),
                          ),
                          exportData(),
                        ],
                      ),
                    ),
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
      ),
    );
  }

  header(String title) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'ข้อมูลย้อนหลัง$title',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  exportData() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'วัน/เดือน/ปี - วัน/เดือน/ปี',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width / 1.2,
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
          height: 20,
        ),
        bottom(context, kContainerSearchColor, 'ค้นหา'),
        const SizedBox(
          height: 20,
        ),
        bottom(context, kContainerPDFColor, 'PDF'),
        const SizedBox(
          height: 20,
        ),
        bottom(context, kContainerExcelColor, 'Excel'),
      ],
    );
  }

  Container bottom(BuildContext context, Color color, String text) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.2,
      height: MediaQuery.of(context).size.height / 22,
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
