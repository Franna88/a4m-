import 'package:a4m/Admin/Dashboard/ui/coursePerformancePieChart.dart';
import 'package:a4m/Admin/Dashboard/ui/monthlySalesChart.dart';
import 'package:a4m/Admin/Dashboard/ui/monthlyStatSumContainers.dart';
import 'package:a4m/Lecturers/LectureDashboard/lecture_dashboard_profile.dart';
import 'package:a4m/Lecturers/LectureDashboard/lecture_dashboard_total_students.dart';
import 'package:a4m/Lecturers/LectureDashboard/newly_submitted_modules.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

class LectureDashboard extends StatefulWidget {
  const LectureDashboard({super.key});

  @override
  State<LectureDashboard> createState() => _LectureDashboardState();
}

class _LectureDashboardState extends State<LectureDashboard> {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LectureDashboardProfile(),
              SizedBox(width: 50),
              LectureDashboardTotalStudents(),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NewlySubmitedModules(),
            ],
          )
        ],
      ),
    );
  }
}
