import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../myutility.dart';

class CoursePerformanceChart extends StatefulWidget {
  const CoursePerformanceChart({super.key});

  @override
  State<CoursePerformanceChart> createState() => _CoursePerformanceChartState();
}

class _CoursePerformanceChartState extends State<CoursePerformanceChart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MyUtility(context).width < 1500 ? 350 : 410,
      height: MyUtility(context).width < 1500 ? 270 : 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course Performance',
              style: GoogleFonts.kanit(
                  fontWeight: FontWeight.w600,
                  fontSize: MyUtility(context).width < 1500 ? 22 : 28),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  height: MyUtility(context).width < 1500 ? 170 : 270,
                  width: MyUtility(context).width < 1500 ? 170 : 270,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: 55,
                          color: Colors.blue.shade900,
                          title: '55%',
                          radius: MyUtility(context).width < 1500 ? 80 : 110,
                          titleStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: 35,
                          color: Colors.blue.shade700,
                          title: '35%',
                          radius: MyUtility(context).width < 1500 ? 80 : 110,
                          titleStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: 30,
                          color: Colors.blue.shade500,
                          title: '30%',
                          radius: MyUtility(context).width < 1500 ? 80 : 110,
                          titleStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        PieChartSectionData(
                          value: 20,
                          color: Colors.blue.shade300,
                          title: '20%',
                          radius: MyUtility(context).width < 1500 ? 80 : 110,
                          titleStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        PieChartSectionData(
                          value: 18,
                          color: Colors.blue.shade100,
                          title: '18%',
                          radius: MyUtility(context).width < 1500 ? 80 : 110,
                          titleStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 0,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LegendItem(color: Colors.blue.shade100, label: 'Category'),
                    LegendItem(color: Colors.blue.shade300, label: 'Category'),
                    LegendItem(color: Colors.blue.shade500, label: 'Category'),
                    LegendItem(color: Colors.blue.shade700, label: 'Category'),
                    LegendItem(color: Colors.blue.shade900, label: 'Category'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
