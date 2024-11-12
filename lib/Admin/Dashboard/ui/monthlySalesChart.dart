import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../myutility.dart';

class MonthlySalesChart extends StatefulWidget {
  const MonthlySalesChart({super.key});

  @override
  State<MonthlySalesChart> createState() => _MonthlySalesChartState();
}

class _MonthlySalesChartState extends State<MonthlySalesChart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MyUtility(context).width - 310,
      height: MyUtility(context).height * 0.62 - 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Average Monthly Sales',
                  style: GoogleFonts.kanit(fontWeight: FontWeight.w600, fontSize: 20),
                ),
                Text(
                  'R12.7K',
                  style: GoogleFonts.kanit(fontWeight: FontWeight.w600, fontSize: 30),
                ),
              ],
            ),
            Spacer(),
            SizedBox(
              width: MyUtility(context).width - 310,
              height: MyUtility(context).height * 0.53 - 90,
              child: LineChart(
                LineChartData(
                  borderData: FlBorderData(
                    show: false,
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Color(0xffe7e7e7),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 1000,
                        getTitlesWidget: (value, meta) {
                          if (value % 1000 == 0) {
                            return Text(
                              '${(value / 1000).toInt()}k',
                              style: TextStyle(
                                color: Color(0xff68737d),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          }
                          return Container(); // Return an empty container for other values
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final style = TextStyle(
                            color: Color(0xff68737d),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          );
                          switch (value.toInt()) {
                            case 0:
                              return Text('JAN', style: style);
                            case 1:
                              return Text('FEB', style: style);
                            case 2:
                              return Text('MAR', style: style);
                            case 3:
                              return Text('APR', style: style);
                            case 4:
                              return Text('MAY', style: style);
                            case 5:
                              return Text('JUN', style: style);
                            case 6:
                              return Text('JUL', style: style);
                            case 7:
                              return Text('AUG', style: style);
                            case 8:
                              return Text('SEP', style: style);
                            case 9:
                              return Text('OCT', style: style);
                            case 10:
                              return Text('NOV', style: style);
                            case 11:
                              return Text('DEC', style: style);
                            default:
                              return Text('', style: style);
                          }
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  minX: 0,
                  maxX: 11,
                  minY: 0,
                  maxY: 5000,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 2000),
                        FlSpot(1, 1800),
                        FlSpot(2, 1500),
                        FlSpot(3, 1700),
                        FlSpot(4, 2200),
                        FlSpot(5, 3000),
                        FlSpot(6, 2800),
                        FlSpot(7, 2700),
                        FlSpot(8, 2500),
                        FlSpot(9, 2300),
                        FlSpot(10, 2100),
                        FlSpot(11, 2400),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
