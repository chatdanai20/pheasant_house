import 'dart:math';
import 'dart:ui';
import 'package:excel/excel.dart';
import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pheasant_house/screen/chartscreen/chartscreen1.dart';
import 'package:pheasant_house/screen/chartscreen/chartscreen2.dart';
import 'package:pheasant_house/screen/chartscreen/chartscreen3.dart';
import 'package:pheasant_house/screen/chartscreen/chartscreen4.dart';
import 'package:pheasant_house/screen/chartscreen/chartscreen5.dart';
import 'package:pheasant_house/screen/functionMQTT.dart/creatdata.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:io';
import '../../constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:flutter_charts/flutter_charts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // เพิ่มการนำเข้าแพ็คเกจ intl
import 'package:intl/date_symbol_data_local.dart'; // เพิ่มการนำเข้า date_symbol_data_local
import 'package:pheasant_house/screen/chartscreen/chartpdf.dart';

class ChartScreen extends StatefulWidget {
  final String farmName;
  final String email;

  const ChartScreen({super.key, required this.farmName, required this.email});

  @override
  State<ChartScreen> createState() => ChartScreenState();
}

class ChartScreenState extends State<ChartScreen> {
  final PageController _controller = PageController();
  List<DateTime> availableDates = [];
  List<Map<String, dynamic>> hourlyData = [];
  List<String> uniqueMonths = [];
  DateTime? selectedDate;
  String? selectedMonthYear;
  List<Map<String, dynamic>> environmentData = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchUniqueMonths();
    environmentData = environmentData;
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
                  buildChartContainer(
                      'ความเข้มแสง',
                      ChartBar1(
                          selectedDate: selectedDate,
                          email: widget.email,
                          farmName: widget.farmName)),
                  buildChartContainer(
                      'อุณหภูมิ',
                      ChartBar2(
                          selectedDate: selectedDate,
                          email: widget.email,
                          farmName: widget.farmName)),
                  buildChartContainer(
                      'ความชื้นในอากาศ',
                      ChartBar3(
                          selectedDate: selectedDate,
                          email: widget.email,
                          farmName: widget.farmName)),
                  buildChartContainer(
                      'ความชื้นในดิน',
                      ChartBar4(
                          selectedDate: selectedDate,
                          email: widget.email,
                          farmName: widget.farmName)),
                  buildChartContainer(
                      'แอมโมเนีย',
                      ChartBar5(
                          selectedDate: selectedDate,
                          email: widget.email,
                          farmName: widget.farmName)),
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
                'วัน/เดือน/ปี',
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
        InkWell(
          onTap: () => exportToExcel(),
          child: bottom(context, kContainerExcelColor, 'Excel'),
        ),
        const SizedBox(
          height: 20,
        ),
        InkWell(
          onTap: () => _showMonthYearSelectionDialog(context),
          child: bottom(context, kContainerPDFColor, 'PDF'),
        ),
        const SizedBox(
          height: 20,
        ),
        // InkWell(
        //   onTap: () => generatePDF(),
        //   child: bottom(context, kContainerPDFColor, 'testPDF'),
        // ),
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

    List<DateTime> availableDates = [];

    for (var doc in querySnapshot.docs) {
      String docId = doc.id;

      if (docId != 'now') {
        List<String> parts = docId.split('_');
        String dateString = parts[0];

        try {
          DateTime dateTime = DateFormat('yyyy-M-d').parse(dateString);

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
    }

    availableDates.sort((a, b) => a.compareTo(b));

    setState(() {
      this.availableDates = availableDates;
    });

    print('Fetched Data:');
    print('Available Dates:');
    for (var date in availableDates) {
      print(DateFormat('dd/MM/yyyy').format(date));
      print(date);
    }
  }

  Future<void> _fetchUniqueMonths() async {
    String userEmail = widget.email;
    String farmName = widget.farmName;

    CollectionReference environment = FirebaseFirestore.instance
        .collection('User')
        .doc(userEmail)
        .collection('farm')
        .doc(farmName)
        .collection('environment');

    QuerySnapshot querySnapshot = await environment.get();

    Set<String> uniqueMonthsSet = {};

    for (var doc in querySnapshot.docs) {
      String docId = doc.id;

      if (docId != 'now') {
        List<String> parts = docId.split('_');
        String dateString = parts[0];

        try {
          DateTime dateTime = DateFormat('yyyy-M-d').parse(dateString);
          String monthYear = DateFormat('MM/yyyy').format(dateTime);

          uniqueMonthsSet.add(monthYear);
        } catch (e) {
          print('Error parsing date: $dateString');
          print(e);
        }
      }
    }

    setState(() {
      uniqueMonths = uniqueMonthsSet.toList();
      uniqueMonths.sort((a, b) => DateFormat('MM/yyyy')
          .parse(a)
          .compareTo(DateFormat('MM/yyyy').parse(b)));
    });
  }

  Future<List<Map<String, dynamic>>> fetchDatapdf(String monthYear) async {
    String userEmail = widget.email;
    String farmName = widget.farmName;

    CollectionReference environment = FirebaseFirestore.instance
        .collection('User')
        .doc(userEmail)
        .collection('farm')
        .doc(farmName)
        .collection('environment');

    // Parse monthYear to DateTime
    DateTime selectedMonth = DateFormat('M/yyyy').parse(monthYear);

    DateTime startOfMonth =
        DateTime(selectedMonth.year, selectedMonth.month, 1);
    DateTime endOfMonth =
        DateTime(selectedMonth.year, selectedMonth.month + 1, 1)
            .subtract(Duration(days: 1));

    // จัดรูปแบบวันที่สำหรับคิวรี Firestore
    String startDateString = DateFormat('yyyy-M-dd').format(startOfMonth);
    String endDateString = DateFormat('yyyy-M-dd').format(endOfMonth);

    // คิวรี Firestore เพื่อดึงเอกสารภายในเดือนที่ระบุ
    QuerySnapshot querySnapshot = await environment
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: startDateString)
        .where(FieldPath.documentId, isLessThanOrEqualTo: endDateString)
        .get();

    // Map to store daily data averages
    Map<String, Map<String, List<double>>> dailyData = {};

    // Iterate through query results and calculate daily averages
    for (var doc in querySnapshot.docs) {
      String docId = doc.id;
      List<String> parts = docId.split('_');
      String dateString = parts[0];
      DateTime dateTime = DateFormat('yyyy-M-dd').parse(dateString);
      // Skip documents with docId 'now' or dates outside selected month
      if (docId == 'now' ||
          dateTime.isBefore(startOfMonth) ||
          dateTime.isAfter(endOfMonth)) {
        continue;
      }
      print(dateString);

      String timeString = parts.length > 1 ? parts[1] : '00:00:00';
      DateTime time = DateFormat('HH:mm:ss').parse(timeString);

      // Initialize dailyData entry if not exists
      if (!dailyData.containsKey(dateString)) {
        dailyData[dateString] = {
          'lux_morning': [],
          'lux_noon': [],
          'lux_evening': [],
          'temperature': [],
          'humidity': [],
          'soilmoisture': [],
          'ppm': [],
        };
      }

      Map<String, List<double>> dayData = dailyData[dateString]!;
      int lux = doc['lux'] ?? 0;
      double temperature = doc['temperature'] ?? 0.0;
      double humidity = doc['humidity'] ?? 0.0;
      double soilMoisture = doc['soilmoisture'] ?? 0.0;
      double ppm = doc['ppm'] ?? 0;

      // Assign lux to appropriate time slot in dayData
      if (time.hour >= 7 && time.hour < 11) {
        dayData['lux_morning']!.add(lux.toDouble());
      } else if (time.hour >= 11 && time.hour < 15) {
        dayData['lux_noon']!.add(lux.toDouble());
      } else if (time.hour >= 15 && time.hour < 17) {
        dayData['lux_evening']!.add(lux.toDouble());
      }

      // Add temperature, humidity, soil moisture, ppm to dayData
      dayData['temperature']!.add(temperature);
      dayData['humidity']!.add(humidity);
      dayData['soilmoisture']!.add(soilMoisture);
      dayData['ppm']!.add(ppm);
    }

    // List to store averaged environment data for each day in the month
    List<Map<String, dynamic>> environmentData = [];

    // Calculate averages and format data for each day in dailyData
    dailyData.forEach((date, dayData) {
      double luxMorningAvg = _calculateAverage(dayData['lux_morning']!)/1000;
      double luxNoonAvg = _calculateAverage(dayData['lux_noon']!)/1000;
      double luxEveningAvg = _calculateAverage(dayData['lux_evening']!)/1000;
      double tempAvg = _calculateAverage(dayData['temperature']!) ;
      double humidityAvg = _calculateAverage(dayData['humidity']!) / 10;
      double soilMoistureAvg = _calculateAverage(dayData['soilmoisture']!) / 10;
      double ppmAvg = _calculateAverage(dayData['ppm']!);

      // Format data for each day and add to environmentData list
      environmentData.add({
        'docId': date,
        'lux_morning': luxMorningAvg,
        'lux_noon': luxNoonAvg,
        'lux_evening': luxEveningAvg,
        'temperature': tempAvg,
        'humidity': humidityAvg,
        'soilmoisture': soilMoistureAvg,
        'ppm': ppmAvg,
      });
    });

    print(environmentData);
//
    return environmentData;
  }

// Function to calculate average of a list of doubles
  double _calculateAverage(List<double> values) {
    if (values.isEmpty) return 0.0;
    double sum = values.reduce((a, b) => a + b);
    return sum / values.length;
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

  Future<void> _showMonthYearSelectionDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('เลือกเดือน/ปี'),
          content: SizedBox(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: uniqueMonths.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(uniqueMonths[index]),
                  onTap: () async {
                    selectedMonthYear = uniqueMonths[index];
                    Navigator.of(context).pop(selectedMonthYear);
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
    ).then((selectedMonthYear) async {
      if (selectedMonthYear != null) {
        // ดึงข้อมูลสำหรับเดือน/ปีที่เลือก
        List<Map<String, dynamic>> environmentData =
            await fetchDatapdf(selectedMonthYear);

        // นำทางไปยังหน้าจอใหม่
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChartPdf(
              selectedMonthYear: selectedMonthYear!,
              userEmail: widget.email,
              farmName: widget.farmName,
              environmentData: environmentData,
            ),
          ),
        );
      }
    });
  }

  Future<void> exportToExcel() async {
    String userEmail = widget.email;
    String farmName = widget.farmName;

    CollectionReference environment = FirebaseFirestore.instance
        .collection('User')
        .doc(userEmail)
        .collection('farm')
        .doc(farmName)
        .collection('environment');

    QuerySnapshot querySnapshot = await environment.get();

    List<Map<String, dynamic>> environmentData = [];

    for (var doc in querySnapshot.docs) {
      if (doc.id != 'now') {
        // Ensure all fields are non-null and convert types accordingly
        environmentData.add({
          'docId': doc.id ?? 'N/A',
          'lux': (doc['lux'] ?? 0) is int
              ? doc['lux']
              : int.tryParse(doc['lux'].toString()) ?? 0,
          'temperature': (doc['temperature'] ?? 0.0) is double
              ? doc['temperature']
              : double.tryParse(doc['temperature'].toString()) ?? 0.0,
          'humidity': (doc['humidity'] ?? 0.0) is double
              ? doc['humidity']
              : double.tryParse(doc['humidity'].toString()) ?? 0.0,
          'soilmoisture': (doc['soilmoisture'] ?? 0) is double
              ? doc['soilmoisture']
              : double.tryParse(doc['soilmoisture'].toString()) ?? 0.0,
          'ppm': (doc['ppm'] ?? 0) is int
              ? doc['ppm']
              : double.tryParse(doc['ppm'].toString()) ?? 0,
        });
      }
    }

    environmentData.sort((a, b) {
      DateTime dateA = DateFormat('yyyy-M-d_H:m:s').parse(a['docId']);
      DateTime dateB = DateFormat('yyyy-M-d_H:m:s').parse(b['docId']);
      return dateB.compareTo(dateA);
    });

    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Define the header row
    sheet.appendRow([
      const TextCellValue('วัน/เวลา'),
      const TextCellValue('ความเข้มแสง'),
      const TextCellValue('อุณหภูมิ'),
      const TextCellValue('ความชื้นในอากาศ'),
      const TextCellValue('ความชื้นในดิน'),
      const TextCellValue('แอมโมเนีย')
    ]);

    for (var data in environmentData) {
      // Append data rows with non-null values
      sheet.appendRow([
        TextCellValue(data['docId']),
        IntCellValue(data['lux']),
        DoubleCellValue(data['temperature']),
        DoubleCellValue(data['humidity']),
        DoubleCellValue(data['soilmoisture']),
        DoubleCellValue(data['ppm']),
      ]);
    }

    // Get the downloads directory
    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/Download/test1.xlsx';
    final file = File(path);

    var fileBytes = excel.save();
    file
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);
    //print(environmentData);
    print('File saved to $path');
    // Show toast notification
    Fluttertoast.showToast(
      msg: "File saved to $path",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<Uint8List> loadFont(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  // Future<void> generatePDF() async {
  //   await initializeDateFormatting('th_TH'); // Initialize Thai date formatting

  //   final pdf = pw.Document();

  //   final fontData = await loadFont('asset/fonts/THSarabunNew.ttf');
  //   final ttf = pw.Font.ttf(ByteData.sublistView(fontData));

  //   final logoImage = pw.MemoryImage(
  //     (await rootBundle.load('asset/images/Logo2.png')).buffer.asUint8List(),
  //   );

  //   String username = widget.email;
  //   String farmName = widget.farmName;
  //   DocumentSnapshot<Map<String, dynamic>> userData =
  //       await FirebaseFirestore.instance.collection('User').doc(username).get();

  //   DateTime now = DateTime.now();
  //   String formattedDate = DateFormat.yMMMM('th_TH').format(DateTime(
  //       now.year + 543,
  //       now.month,
  //       now.day)); // ใช้ DateFormat ภาษาไทยและเพิ่ม 543 ปี

  //   pdf.addPage(
  //     pw.Page(
  //       build: (pw.Context context) {
  //         return pw.Stack(
  //           children: [
  //             pw.Positioned(
  //               top: 0,
  //               left: 0,
  //               right: 0,
  //               child: pw.Column(
  //                 crossAxisAlignment: pw.CrossAxisAlignment.center,
  //                 children: [
  //                   pw.Image(logoImage, width: 130, height: 100),
  //                   pw.SizedBox(height: 10),
  //                   pw.Text(
  //                     'โรงเรือน: $farmName',
  //                     style: pw.TextStyle(font: ttf, fontSize: 16),
  //                   ),
  //                   pw.Text(
  //                     'เดือนและปี: $formattedDate',
  //                     style: pw.TextStyle(font: ttf, fontSize: 16),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             pw.Positioned(
  //               bottom: 50,
  //               right: 0, // จุดลงชื่ออยู่ทางขวาล่าง
  //               child: pw.Column(
  //                 crossAxisAlignment: pw.CrossAxisAlignment.end, // ชิดขวา
  //                 children: [
  //                   pw.Text(
  //                     'ลงชื่อ: ____________________________',
  //                     style: pw.TextStyle(font: ttf, fontSize: 16),
  //                   ),
  //                   pw.SizedBox(height: 10),
  //                   pw.Container(
  //                     alignment: pw.Alignment.center,
  //                     width: 200, // กำหนดความกว้างเพื่อให้ข้อความอยู่ตรงกลาง
  //                     child: pw.Text(
  //                       '     ${userData['name'] ?? 'N/A'}      ${userData['lastname'] ?? 'N/A'}',
  //                       style: pw.TextStyle(font: ttf, fontSize: 16),
  //                       textAlign: pw.TextAlign.center,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             pw.Positioned(
  //               bottom: 50,
  //               left: 0, // ข้อมูลเพิ่มเติมอยู่ทางซ้ายล่าง
  //               child: pw.Column(
  //                 crossAxisAlignment: pw.CrossAxisAlignment.start, // ชิดซ้าย
  //                 children: [
  //                   pw.Text(
  //                     'ข้อมูลเพิ่มเติม:',
  //                     style: pw.TextStyle(font: ttf, fontSize: 16),
  //                   ),
  //                   //pw.SizedBox(height: 10),
  //                   pw.Text(
  //                     'ชื่อ: ${userData['name'] ?? 'N/A'} นามสกุล:  ${userData['lastname'] ?? 'N/A'}',
  //                     style: pw.TextStyle(font: ttf, fontSize: 16),
  //                   ),
  //                   pw.Text(
  //                     'Email: $username',
  //                     style: pw.TextStyle(font: ttf, fontSize: 16),
  //                   ),
  //                   pw.Text(
  //                     'โทร: ${userData['phone'] ?? 'N/A'}',
  //                     style: pw.TextStyle(font: ttf, fontSize: 16),
  //                   ),
  //                   pw.Text(
  //                     'ที่อยู่: ${userData['address'] ?? 'N/A'}',
  //                     style: pw.TextStyle(font: ttf, fontSize: 16),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //   );

  //   // บันทึกไฟล์ PDF ลงในอุปกรณ์
  //   final output = await getExternalStorageDirectory();
  //   final file = File('${output?.path}/example_thai.pdf');
  //   await file.writeAsBytes(await pdf.save());

  //   // ตรวจสอบ path ของไฟล์ที่บันทึก
  //   print('Path to saved PDF: ${file.path}');
  //   Fluttertoast.showToast(
  //     msg: "File saved to ${file.path}",
  //     toastLength: Toast.LENGTH_LONG,
  //     gravity: ToastGravity.BOTTOM,
  //     timeInSecForIosWeb: 1,
  //     backgroundColor: Colors.black,
  //     textColor: Colors.white,
  //     fontSize: 16.0,
  //   );
  // }
}
