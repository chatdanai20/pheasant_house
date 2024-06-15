import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pheasant_house/screen/chartscreen/chartscreen1.dart';
import 'package:pheasant_house/screen/chartscreen/chartscreen2.dart';
import 'package:pheasant_house/screen/chartscreen/chartscreen3.dart';
import 'package:pheasant_house/screen/chartscreen/chartscreen4.dart';
import 'package:pheasant_house/screen/chartscreen/chartscreen5.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../constants.dart';

class ChartScreen extends StatefulWidget {
  final String farmName;
  final String email;

  const ChartScreen({Key? key, required this.farmName, required this.email})
      : super(key: key);

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  final PageController _controller = PageController();
  DateTime? selectedDate;
  List<DateTime> availableDates = [];
  List<Map<String, dynamic>> hourlyData = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

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
                          if (hourlyData.isNotEmpty)
                            ...hourlyData
                                .map((data) => Text(
                                    'Hour: ${data['hour']}, Value: ${data['value']}'))
                                .toList(),
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
          child: InkWell(
            onTap: () => _showDateSelectionDialog(context),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'เลือกวันที่',
                    style: TextStyle(color: Colors.white),
                  ),
                  Icon(
                    Icons.calendar_month,
                    size: 25,
                  )
                ],
              ),
            ),
          ),
        ),
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

  Future<void> _fetchData([DateTime? selectedDate]) async {
  String userEmail = widget.email;
  String farmName = widget.farmName;

  CollectionReference environment = FirebaseFirestore.instance
      .collection('User')
      .doc(userEmail)
      .collection('farm')
      .doc(farmName)
      .collection('environment');

  QuerySnapshot querySnapshot;

  if (selectedDate != null) {
    DateTime startDate = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 0, 0);
    DateTime endDate = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 23, 59);

    querySnapshot = await environment
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .where('timestamp', isLessThanOrEqualTo: endDate)
        .get();
  } else {
    querySnapshot = await environment.get();
  }

  List<Map<String, dynamic>> hourlyData = [];
  List<DateTime> availableDates = [];

  for (var doc in querySnapshot.docs) {
    Timestamp timestamp = doc.get('timestamp');
    DateTime dateTime = timestamp.toDate();

    if (!availableDates.contains(dateTime)) {
      availableDates.add(dateTime);
    }

    hourlyData.add({
      'docId': doc.id,  // เพิ่ม docId เข้าไปในข้อมูลที่ดึงมา
      'hour': doc.get('hour'),
      'value': doc.get('value'),
    });
  }

  setState(() {
    this.availableDates = availableDates;
    this.hourlyData = hourlyData;
  });
}



  Future<void> _showDateSelectionDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('เลือกวันที่'),
        content: SizedBox(
          width: double.minPositive,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableDates.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                    DateFormat('dd/MM/yyyy').format(availableDates[index])),
                onTap: () {
                  setState(() {
                    selectedDate = availableDates[index];
                    _fetchData(selectedDate!);
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      );
    },
  );
}

}
