import 'package:a4m/Admin/Dashboard/ui/coursePerformancePieChart.dart';
import 'package:a4m/Admin/Dashboard/ui/monthlySalesChart.dart';
import 'package:a4m/Admin/Dashboard/ui/monthlyStatSumContainers.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

class AdminDashboardMain extends StatefulWidget {
  const AdminDashboardMain({super.key});

  @override
  State<AdminDashboardMain> createState() => _AdminDashboardMainState();
}

class _AdminDashboardMainState extends State<AdminDashboardMain> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 9),
            child: MonthlySalesChart()),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(
              width: 7,
            ),
            MonthlyStatSumContainers(
                header: 'Total Students',
                totalSum: '1200',
                increasedAmount: '12'),
            MonthlyStatSumContainers(
                header: 'Courses Accessed',
                totalSum: '345',
                increasedAmount: '12'),
            Padding(
                padding: MyUtility(context).width < 1500
                    ? EdgeInsets.symmetric(vertical: 10, horizontal: 8)
                    : EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                child: CoursePerformanceChart()),
          ],
        )
      ],
    );
  }
}
