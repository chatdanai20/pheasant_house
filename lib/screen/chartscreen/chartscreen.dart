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
  List<DateTime> availableDates = [];
  List<Map<String, dynamic>> hourlyData = [];
  DateTime? selectedDate; // Add this line

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
                  buildChartContainer('ความเข้มแสง', ChartBar1(selectedDate: selectedDate, email: widget.email, farmName: widget.farmName)),
                  buildChartContainer('อุณหภูมิ', ChartBar2(selectedDate: selectedDate, email: widget.email, farmName: widget.farmName)),
                  buildChartContainer('ความชื้นในอากาศ', ChartBar3(selectedDate: selectedDate, email: widget.email, farmName: widget.farmName)),
                  buildChartContainer('ความชื้นในดิน', ChartBar4(selectedDate: selectedDate, email: widget.email, farmName: widget.farmName)),
                  buildChartContainer('แอมโมเนีย', ChartBar5(selectedDate: selectedDate, email: widget.email, farmName: widget.farmName)),
                ],
              ),
            ),
            const SizedBox(height: 10),
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

  Widget buildChartContainer(String title, Widget chartWidget) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            header(title),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: chartWidget,
            ),
            exportData(),
          ],
        ),
      ),
    );
  }

  Widget header(String title) {
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

  Widget exportData() {
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    selectedDate != null
                        ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                        : 'เลือกวันที่',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Icon(
                    Icons.calendar_today,
                    size: 25,
                    color: Colors.white,
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

  Future<void> _fetchData() async {
    String userEmail = widget.email;
    String farmName = widget.farmName;

    CollectionReference environment = FirebaseFirestore.instance
        .collection('User')
        .doc(userEmail)
        .collection('farm')
        .doc(farmName)
        .collection('environment');

    QuerySnapshot querySnapshot = await environment.get();

    // Initialize lists to store data
    List<DateTime> availableDates = [];

    // Iterate through documents
    for (var doc in querySnapshot.docs) {
      String docId = doc.id; // Get the document ID ("2024-5-29_18:37:38")

      // Split docId to separate date and time parts
      List<String> parts = docId.split('_');
      String dateString = parts[0]; // "2024-5-29"

      try {
        // Parse the date part only
        DateTime dateTime = DateFormat('yyyy-M-d').parse(dateString);

        // Check if the date is already in availableDates list
        if (!availableDates.any((date) =>
            date.year == dateTime.year &&
            date.month == dateTime.month &&
            date.day == dateTime.day)) {
          availableDates.add(dateTime);
        }
      } catch (e) {
        print('Error parsing date: $dateString');
        print(e);
      }
    }

    // Sort availableDates list
    availableDates.sort((a, b) => a.compareTo(b));

    // Update state with fetched data
    setState(() {
      this.availableDates = availableDates;
    });

    // Print the fetched data after conversion
    print('Fetched Data:');
    print('Available Dates:');
    availableDates.forEach((date) {
      print(DateFormat('dd/MM/yyyy').format(date));
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
                // Format the dateTime to 'dd/MM/yyyy'
                String formattedDateTime =
                    DateFormat('dd/MM/yyyy').format(availableDates[index]);

                return ListTile(
                  title: Text(formattedDateTime),
                  onTap: () {
                    setState(() {
                      selectedDate = availableDates[index];
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
