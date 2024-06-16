import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';

class _Chart extends StatelessWidget {
  const _Chart({required this.isShowingMainData, required this.hourlyAverageSpots});

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
            color: kDefaultColor.withOpacity(0.5),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
                  radius: 1,
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
        maxY: 45,
        minY: 5,
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
      fontSize: 14,
    );
    String text;
    switch (value.toInt()) {
  
      case 10:
        text = '10C';
        break;
      case 15:
        text = '15C';
        break;
      case 20:
        text = '20C';
        break;
      case 25:
        text = '25C';
        break;
      case 30:
        text = '30C';
        break;
      case 35:
        text = '35C';
        break;
      case 40:
        text = '40C';
        break;  
    
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  SideTitles leftTitles() => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        interval: 5,
        reservedSize: 35,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
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

class ChartBar1 extends StatefulWidget {
  final DateTime? selectedDate;
  final String email;
  final String farmName;

  const ChartBar1({super.key, this.selectedDate, required this.email, required this.farmName});

  @override
  State<StatefulWidget> createState() => ChartBar1State();
}

class ChartBar1State extends State<ChartBar1> {
  late bool isShowingMainData;
  List<FlSpot> hourlyAverageSpots = [];

  @override
  void initState() {
    super.initState();
    isShowingMainData = true;
    if (widget.selectedDate != null) {
      _fetchHourlyData(widget.selectedDate!, widget.email, widget.farmName);
    }
  }

  Future<void> _fetchHourlyData(DateTime date, String email, String farmName) async {
    String dateStr = DateFormat('yyyy-M-d').format(date);

    CollectionReference environment = FirebaseFirestore.instance
        .collection('User')
        .doc(email)
        .collection('farm')
        .doc(farmName)
        .collection('environment');

    QuerySnapshot querySnapshot = await environment
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: '${dateStr}_00:00:00')
        .where(FieldPath.documentId, isLessThanOrEqualTo: '${dateStr}_23:59:59')
        .get();

    Map<int, List<double>> hourlyData = {};

    for (var doc in querySnapshot.docs) {
      String docId = doc.id;
      List<String> parts = docId.split('_');
      String timeString = parts[1];
      int hour = int.parse(timeString.split(':')[0]);

      double temperature = doc['temperature'];

      if (hourlyData[hour] == null) {
        hourlyData[hour] = [];
      }
      hourlyData[hour]!.add(temperature);
    }

    List<FlSpot> spots = [];
    hourlyData.forEach((hour, temps) {
      double avgTemp = temps.reduce((a, b) => a + b) / temps.length;
      avgTemp = double.parse(avgTemp.toStringAsFixed(2)); // Format to 2 decimal places
      spots.add(FlSpot(hour.toDouble(), avgTemp));
    });

    setState(() {
      hourlyAverageSpots = spots;
    });
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
                  child: _Chart(isShowingMainData: isShowingMainData, hourlyAverageSpots: hourlyAverageSpots),
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
