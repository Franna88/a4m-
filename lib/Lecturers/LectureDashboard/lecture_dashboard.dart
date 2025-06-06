import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/Lecturers/LectureDashboard/dash_calendar_notices.dart';
import 'package:a4m/Lecturers/LectureDashboard/lecture_dashboard_profile.dart';
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
            // Left column: Profile and Newly Submitted Modules
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  // Profile card
                  LectureDashboardProfile(
                    lecturerId: widget.lecturerId,
                  ),
                  const SizedBox(height: 16),
                  // Newly submitted modules section
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
            // Right column: Calendar and Reminders (now larger)
            Expanded(
              flex: 2,
              child: const DashCalendarNotices(),
            ),
          ],
        ),
      ),
    );
  }
}
