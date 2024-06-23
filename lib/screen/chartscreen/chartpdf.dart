import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pheasant_house/constants.dart';
import 'package:pheasant_house/screen/homescreen/homescreen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'chartscreen.dart';
import 'package:flutter/material.dart';

class chartpdf extends StatelessWidget {
  final String selectedMonthYear; // เพิ่มตัวแปรเพื่อรับค่า selectedMonthYear
  final String userEmail;
  final String farmName;
  final List<Map<String, dynamic>> environmentData;

  const chartpdf({
    Key? key,
    required this.selectedMonthYear,
    required this.userEmail,
    required this.farmName,
    required this.environmentData,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: chart(
        selectedMonthYear: selectedMonthYear,
        userEmail: userEmail,
        farmName: farmName,
        environmentData: environmentData,
      ), // ส่งค่า selectedMonthYear ไปยัง _Chart
    );
  }
}

class chart extends StatefulWidget {
  final String selectedMonthYear; // เพิ่มตัวแปรเพื่อรับค่า selectedMonthYear
  final String userEmail;
  final String farmName;
  final List<Map<String, dynamic>> environmentData;
  const chart({
    Key? key,
    required this.selectedMonthYear,
    required this.userEmail,
    required this.farmName,
    required this.environmentData,
  }) : super(key: key);
  @override
  ChartState createState() => ChartState();
}

class ChartState extends State<chart> {
  late List<_ChartData> data;
  late TooltipBehavior _tooltip;
  final GlobalKey _chartKey = GlobalKey();

  @override
  void initState() {
     super.initState();
      data = widget.environmentData.map((e) => _ChartData.fromMap(e)).toList();
    _tooltip = TooltipBehavior(enable: true);
   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Syncfusion Flutter chart'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _chartKey,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  interval: 5,
                ),
                primaryYAxis: NumericAxis(minimum: 0, maximum: 40, interval: 5),
                tooltipBehavior: _tooltip,
                series: <CartesianSeries<_ChartData, String>>[
                  ColumnSeries<_ChartData, String>(
                    dataSource: data,
                    xValueMapper: (_ChartData data, _) => data.x,
                    yValueMapper: (_ChartData data, _) => data.ppm ?? 0,
                    name: 'Ammonia',
                    color: Color.fromARGB(255, 237, 177, 197),
                  ),
                  LineSeries<_ChartData, String>(
                    dataSource: data,
                    xValueMapper: (_ChartData data, _) => data.x,
                    yValueMapper: (_ChartData data, _) => data.luxMorning ??0,
                        
                    name: 'Light_morning',
                    color: Colors.blue,
                  ),
                  LineSeries<_ChartData, String>(
                    dataSource: data,
                    xValueMapper: (_ChartData data, _) => data.x,
                    yValueMapper: (_ChartData data, _) =>
                        data.luxNoon ?? 0,
                    name: 'Light_noon',
                    color: Colors.orange,
                  ),
                  LineSeries<_ChartData, String>(
                    dataSource: data,
                    xValueMapper: (_ChartData data, _) => data.x,
                    yValueMapper: (_ChartData data, _) =>
                        data.luxEvening ?? 0,
                    name: 'Light_evening',
                    color: Color.fromARGB(255, 188, 59, 12),
                  ),
                  LineSeries<_ChartData, String>(
                    dataSource: data,
                    xValueMapper: (_ChartData data, _) => data.x,
                    yValueMapper: (_ChartData data, _) => data.temperature ?? 0,
                    name: 'Temperature',
                    color: Colors.red,
                  ),
                  LineSeries<_ChartData, String>(
                    dataSource: data,
                    xValueMapper: (_ChartData data, _) => data.x,
                    yValueMapper: (_ChartData data, _) => data.humidity ?? 0,
                    name: 'Humidity',
                    color: Colors.green,
                  ),
                  LineSeries<_ChartData, String>(
                    dataSource: data,
                    xValueMapper: (_ChartData data, _) => data.x,
                    yValueMapper: (_ChartData data, _) =>
                        data.soilMoisture ?? 0,
                    name: 'Soil Moisture',
                    color: Colors.brown,
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _handlePermissions(context);
              // await _pdfResults(context);
              await generatePDF(context);
            },
            child: const Text('Generate PDF'),
          ),
          SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }

  Future<Uint8List> loadFont(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  Future<void> generatePDF(BuildContext context) async {
    final pdf = pw.Document();

    final fontData = await loadFont('asset/fonts/THSarabunNew.ttf');
    final ttf = pw.Font.ttf(ByteData.sublistView(fontData));

    final logoImage = pw.MemoryImage(
      (await rootBundle.load('asset/images/Logo2.png')).buffer.asUint8List(),
    );
    final boundary =
        _chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    DocumentSnapshot<Map<String, dynamic>> userData =
        await FirebaseFirestore.instance.collection('User').doc(widget.userEmail).get();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Image(logoImage, width: 130, height: 100),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'โรงเรือน: ${widget.farmName}',
                      style: pw.TextStyle(font: ttf, fontSize: 16),
                    ),
                    pw.Text(
                      'เดือนและปี: ${widget.selectedMonthYear}',
                      style: pw.TextStyle(font: ttf, fontSize: 16),
                    ),
                  ],
                ),
              ),
              pw.Center(
                child:
                    pw.Image(pw.MemoryImage(bytes), width: 5000, height: 460),
              ),
              pw.Positioned(
                bottom: 20,
                right: 0, // จุดลงชื่ออยู่ทางขวาล่าง
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end, // ชิดขวา
                  children: [
                    pw.Text(
                      'ลงชื่อ: __________________________',
                      style: pw.TextStyle(font: ttf, fontSize: 16),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Container(
                      alignment: pw.Alignment.center,
                      width: 200,
                      child: pw.Text(
                        '${userData['name']}    ${userData['lastname']}',
                        style: pw.TextStyle(font: ttf, fontSize: 16),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Positioned(
                bottom: 0,
                left: 0,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'ข้อมูลเพิ่มเติม:',
                      style: pw.TextStyle(font: ttf, fontSize: 16),
                    ),
                    //pw.SizedBox(height: 10),
                    pw.Text(
                      'ชื่อ: ${userData['name'] } ${userData['lastname']}',
                      style: pw.TextStyle(font: ttf, fontSize: 16),
                    ),
                    pw.Text(
                      'Email: ${userData['email']}',
                      style: pw.TextStyle(font: ttf, fontSize: 16),
                    ),
                    pw.Text(
                      'โทร: ${userData['phone']}',
                      style: pw.TextStyle(font: ttf, fontSize: 16),
                    ),
                    pw.Text(
                      'ที่อยู่:  ${userData['address']}',
                      style: pw.TextStyle(font: ttf, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
    await savePdf(pdf, context);
  }

  Future<void> _handlePermissions(BuildContext context) async {
    PermissionStatus storageExStatus =
        await Permission.manageExternalStorage.request();
    if (storageExStatus == PermissionStatus.granted) {
      print("Storage permission granted");
    } else if (storageExStatus == PermissionStatus.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage permission denied'),
        ),
      );
    } else if (storageExStatus == PermissionStatus.permanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _pdfResults(BuildContext context) async {
    var pdf = pw.Document();
    final boundary =
        _chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            widthFactor: 250,
            heightFactor: 250,
            child: pw.Image(pw.MemoryImage(bytes)),
          );
        },
      ),
    );

    await savePdf(pdf, context);
  }

  Future<String> savePdf(pw.Document pdf, BuildContext context) async {
    String path;
    late File file;

    if (Platform.isAndroid) {
      path = (await getExternalStorageDirectory())!.path;
      file = File("$path/best_pdf.pdf");
    } else if (Platform.isIOS) {
      path = (await getApplicationDocumentsDirectory()).path;
      Directory directory = await Directory("$path/best_pdfs").create();
      file = File("${directory.path}/best_pdf.pdf");
    } else {
      throw UnsupportedError("Unsupported platform");
    }

    if (await file.exists()) {
      try {
        await file.delete();
      } on Exception catch (e) {
        print(e);
      }
    }

    await file.writeAsBytes(await pdf.save());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF saved at ${file.path}')),
    );
    return file.path;
  }
}

class _ChartData {
  final String x;
  final int luxMorning;
  final int luxNoon;
  final int luxEvening;
  final double temperature;
  final double humidity;
  final double soilMoisture;
  final int ppm;

  _ChartData(
    this.x,
    this.luxMorning,
    this.luxNoon,
    this.luxEvening,
    this.temperature,
    this.humidity,
    this.soilMoisture,
    this.ppm,
  );

  factory _ChartData.fromMap(Map<String, dynamic> map) {
    return _ChartData(
      map['docId'],
      map['luxMorning']?.toDouble() ?? 0,
      map['luxNoon']?.toDouble() ?? 0,
      map['luxEvening']?.toDouble() ?? 0,
      map['temperature']?.toDouble() ?? 0,
      map['humidity']?.toDouble() ?? 0,
      map['soilMoisture']?.toDouble() ?? 0,
      map['ppm']?.toDouble() ?? 0,
    );
  }
}
