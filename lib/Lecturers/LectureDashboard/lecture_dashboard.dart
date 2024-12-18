import 'package:a4m/Admin/Dashboard/ui/coursePerformancePieChart.dart';
import 'package:a4m/Admin/Dashboard/ui/monthlySalesChart.dart';
import 'package:a4m/Admin/Dashboard/ui/monthlyStatSumContainers.dart';
import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/Lecturers/LectureDashboard/dash_calendar_notices.dart';
import 'package:a4m/Lecturers/LectureDashboard/lecture_dashboard_profile.dart';
import 'package:a4m/Lecturers/LectureDashboard/lecture_dashboard_total_students.dart';
import 'package:a4m/Lecturers/LectureDashboard/newly_submitted_modules.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

class LectureDashboard extends StatefulWidget {
  final String lecturerId;
  final Function(int, String) changePageWithCourseId;

  final String reminder;
  const LectureDashboard(
      {super.key,
      this.reminder = 'Reminder',
      required this.lecturerId,
      required this.changePageWithCourseId});

  @override
  State<LectureDashboard> createState() => _LectureDashboardState();
}

class _LectureDashboardState extends State<LectureDashboard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Mycolors().offWhite,
      width: MyUtility(context).width - 320,
      height: MyUtility(context).height - 80,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LectureDashboardProfile(
                      lecturerId: widget.lecturerId,
                    ),
                    SizedBox(width: 50),
                    LectureDashboardTotalStudents(
                      lecturerId: widget.lecturerId,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    NewlySubmitedModules(
                      lecturerId: widget.lecturerId,
                      changePageWithCourseId: widget.changePageWithCourseId,
                    ),
                  ],
                )
              ],
            ),
            Spacer(),
            Container(
              color: Colors.white,
              width: MyUtility(context).width * 0.22,
              height: MyUtility(context).height - 80,
              child: Center(
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      width: MyUtility(context).width * 0.22,
                      height: MyUtility(context).height * 0.7,
                      child: const DashCalendarNotices(),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(10.0),
                    //   child: Divider(
                    //     color: Mycolors().offWhite,
                    //     thickness: 5,
                    //   ),
                    // ),
                    // const Row(
                    //   children: [
                    //     Spacer(),
                    //     SizedBox(width: 15),
                    //     Text(
                    //       'Today\'s Reminders',
                    //       style: TextStyle(
                    //           fontSize: 20,
                    //           color: Colors.black,
                    //           fontWeight: FontWeight.bold),
                    //     ),
                    //     Spacer(),
                    //     Icon(
                    //       Icons.add,
                    //       size: 30,
                    //     )
                    //   ],
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.all(10.0),
                    //   child: Container(
                    //     height: MyUtility(context).height * 0.05,
                    //     decoration: BoxDecoration(
                    //         color: Mycolors().offWhite,
                    //         borderRadius: BorderRadius.circular(6)),
                    //     child: Text(
                    //       widget.reminder,
                    //       style: TextStyle(
                    //           fontSize: 20,
                    //           color: Colors.black,
                    //           fontWeight: FontWeight.bold),
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
