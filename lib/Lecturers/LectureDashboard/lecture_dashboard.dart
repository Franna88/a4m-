import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/Lecturers/LectureDashboard/dash_calendar_notices.dart';
import 'package:a4m/Lecturers/LectureDashboard/lecture_dashboard_profile.dart';
import 'package:a4m/Lecturers/LectureDashboard/lecture_dashboard_total_students.dart';
import 'package:a4m/Lecturers/LectureDashboard/newly_submitted_modules.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

class LectureDashboard extends StatefulWidget {
  final String lecturerId;
  final Function(int, {String courseId, String moduleId})
      changePageWithCourseId;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: LectureDashboardProfile(
                            lecturerId: widget.lecturerId,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: LectureDashboardTotalStudents(
                            lecturerId: widget.lecturerId,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: NewlySubmitedModules(
                      lecturerId: widget.lecturerId,
                      changePageWithCourseId: widget.changePageWithCourseId,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const DashCalendarNotices(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
