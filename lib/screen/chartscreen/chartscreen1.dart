import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';

class _Chart extends StatelessWidget {
  const _Chart({required this.isShowingMainData});

  final bool isShowingMainData;

  @override
  Widget build(BuildContext context) {
    return isShowingMainData
        ? LineChart(sampleData2, duration: const Duration(milliseconds: 250))
        : BarChart(sampleData1,
            swapAnimationDuration: const Duration(milliseconds: 250));
  }

  BarChartData get sampleData1 => BarChartData(
        barTouchData: barTouchData,
        titlesData: titlesData1,
        borderData: borderData,
        barGroups: barGroups1,
        gridData: gridData,
        alignment: BarChartAlignment.spaceAround,
        maxY: 6,
      );

  LineChartData get sampleData2 => LineChartData(
        lineTouchData: lineTouchData2,
        gridData: gridData,
        titlesData: titlesData2,
        borderData: borderData,
        lineBarsData: lineBarsData2,
        minX: 0,
        maxX: 14,
        maxY: 6,
        minY: 0,
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

  BarTouchData get barTouchData => BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (BarChartGroupData group) => Colors.white,
        ),
        touchCallback: (FlTouchEvent event, BarTouchResponse? touchResponse) {
          // Handle touch callback here
        },
      );

  FlTitlesData get titlesData1 => FlTitlesData(
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

  List<BarChartGroupData> get barGroups1 => [
        BarChartGroupData(x: 1, barRods: [barRodData(1)]),
        BarChartGroupData(x: 3, barRods: [barRodData(4)]),
        BarChartGroupData(x: 5, barRods: [barRodData(1.8)]),
        BarChartGroupData(x: 7, barRods: [barRodData(5)]),
        BarChartGroupData(x: 11, barRods: [barRodData(2)]),
        BarChartGroupData(x: 13, barRods: [barRodData(2.2)]),
        BarChartGroupData(x: 16, barRods: [barRodData(1.8)]),
      ];

  BarChartRodData barRodData(double y) => BarChartRodData(
        toY: y,
        color: kDefaultColor,
        width: 8,
      );

  LineTouchData get lineTouchData2 => const LineTouchData(
        enabled: false,
      );

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

  List<LineChartBarData> get lineBarsData2 => [
        lineChartBarData2_1,
      ];

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = '10C';
        break;
      case 2:
        text = '15C';
        break;
      case 3:
        text = '20C';
        break;
      case 4:
        text = '25C';
        break;
      case 5:
        text = '30C';
        break;
      case 6:
        text = '35C';
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
        reservedSize: 40,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = const Text('Mon', style: style);
        break;
      case 3:
        text = const Text('Tue', style: style);
        break;
      case 5:
        text = const Text('Wed', style: style);
        break;
      case 7:
        text = const Text('Thu', style: style);
        break;
      case 9:
        text = const Text('Fri', style: style);
        break;
      case 11:
        text = const Text('Sat', style: style);
        break;
      case 13:
        text = const Text('Sun', style: style);
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

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: kDefaultColor.withOpacity(0.2), width: 4),
          left: const BorderSide(color: Colors.transparent),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      );

  LineChartBarData get lineChartBarData2_1 => LineChartBarData(
        isCurved: true,
        curveSmoothness: 0,
        color: kDefaultColor.withOpacity(0.5),
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(0, 1),
          FlSpot(3, 4),
          FlSpot(5, 1.8),
          FlSpot(7, 5),
          FlSpot(10, 2),
          FlSpot(12, 2.2),
          FlSpot(13, 1.8),
        ],
      );
}

class ChartBar1 extends StatefulWidget {
  const ChartBar1({super.key});

  @override
  State<StatefulWidget> createState() => ChartBar1State();
}

class ChartBar1State extends State<ChartBar1> {
  late bool isShowingMainData;

  @override
  void initState() {
    super.initState();
    isShowingMainData = true;
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
                  child: _Chart(isShowingMainData: isShowingMainData),
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
