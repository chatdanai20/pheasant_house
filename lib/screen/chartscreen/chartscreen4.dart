import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';

class _Chart extends StatelessWidget {
  const _Chart(
      {required this.isShowingMainData, required this.hourlyAverageSpots});

  final bool isShowingMainData;
  final List<FlSpot> hourlyAverageSpots;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            curveSmoothness: 0,
            color: Colors.blue.withOpacity(1),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 2,
                color: Colors.red,
                strokeWidth: 1,
                strokeColor: Colors.red,
              ),
            ),
            belowBarData: BarAreaData(show: false),
            spots: hourlyAverageSpots,
          ),
        ],
        titlesData: titlesData2,
        gridData: gridData,
        borderData: borderData,
        minX: 0,
        maxX: 23,
        maxY: 10,
        minY: 0,
      ),
    );
  }

  FlTitlesData get titlesData2 => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles(),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlGridData get gridData => FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.grey,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.grey,
            strokeWidth: 1,
          );
        },
      );

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: kDefaultColor.withOpacity(0.2), width: 4),
          left: const BorderSide(color: Colors.transparent),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      );

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    String text;
    switch (value.toInt()) {
      case 0: 
        text = '0%';
        break;
      case 1:
        text = '10%';
        break;
      case 2:
        text = '20%';
        break;
      case 3:
        text = '30%';
        break;
      case 4:
        text = '40%';
        break;
      case 5:
        text = '50%';
        break;
      case 6:
        text = '60%';
        break;
      case 7:
        text = '70%';
        break;
      case 8:
        text = '80%';
        break;
      case 9:
         text = '90%';
         break;
      case 10:
         text = '100%';
         break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  SideTitles leftTitles() => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        interval: 1,
        reservedSize: 35,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 11,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('00:00', style: style);
        break;
      case 3:
        text = const Text('03:00', style: style);
        break;
      case 6:
        text = const Text('06:00', style: style);
        break;
      case 9:
        text = const Text('09:00', style: style);
        break;
      case 12:
        text = const Text('12:00', style: style);
        break;
      case 15:
        text = const Text('15:00', style: style);
        break;
      case 18:
        text = const Text('18:00', style: style);
        break;
      case 21:
        text = const Text('21:00', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 5,
      child: text,
    );
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );
}

class ChartBar4 extends StatefulWidget {
  final DateTime? selectedDate;
  final String email;
  final String farmName;

  const ChartBar4(
      {super.key,
      this.selectedDate,
      required this.email,
      required this.farmName});

  @override
  State<StatefulWidget> createState() => ChartBar4State();
}

class ChartBar4State extends State<ChartBar4> {
  late bool isShowingMainData;
  List<FlSpot> hourlyAverageSpots = [];

  @override
  void initState() {
    super.initState();
    isShowingMainData = true;
  }

  Future<List<FlSpot>> _fetchHourlyData(
      DateTime date, String email, String farmName) async {
    String dateStr = DateFormat('yyyy-M-d').format(date);

    CollectionReference environment = FirebaseFirestore.instance
        .collection('User')
        .doc(email)
        .collection('farm')
        .doc(farmName)
        .collection('environment');

    QuerySnapshot querySnapshot = await environment
        .where(FieldPath.documentId,
            isGreaterThanOrEqualTo: '${dateStr}_00:00:00')
        .where(FieldPath.documentId, isLessThanOrEqualTo: '${dateStr}_23:59:59')
        .get();

    Map<int, List<double>> hourlyData = {};

    for (var doc in querySnapshot.docs) {
      String docId = doc.id;
      List<String> parts = docId.split('_');
      String timeString = parts[1];
      int hour = int.parse(timeString.split(':')[0]);

      double soilmoisture = doc['soilmoisture'].toDouble();

      if (hourlyData[hour] == null) {
        hourlyData[hour] = [];
      }
      hourlyData[hour]!.add(soilmoisture);
    }

   List<FlSpot> spots = [];
  hourlyData.forEach((hour, temps) {
    double avgTemp = temps.reduce((a, b) => a + b) / temps.length;
    avgTemp = double.parse(
        (avgTemp / 10).toStringAsFixed(2)); // ปรับสเกลและ Format เป็นทศนิยม 3 ตำแหน่ง
    spots.add(FlSpot(hour.toDouble(), avgTemp));
  });

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(
                height: 60,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 1, left: 1),
                  child: FutureBuilder<List<FlSpot>>(
                    future: widget.selectedDate != null
                        ? _fetchHourlyData(
                            widget.selectedDate!, widget.email, widget.farmName)
                        : Future.value([]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        return _Chart(
                            isShowingMainData: isShowingMainData,
                            hourlyAverageSpots: snapshot.data!);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: kDefaultColor.withOpacity(isShowingMainData ? 1.0 : 0.5),
            ),
            onPressed: () {
              setState(() {
                isShowingMainData = !isShowingMainData;
              });
            },
          )
        ],
      ),
    );
  }
}
