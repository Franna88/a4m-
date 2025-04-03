import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/Facilitator/Pages/Dashboard/ui/facilitatorStudentPassRate.dart';
import 'package:a4m/Facilitator/Pages/Dashboard/ui/facilitatorStudentProgressList.dart';
import 'package:a4m/Facilitator/Pages/Dashboard/ui/facilitatorTotalStudents.dart';
import 'package:a4m/Lecturers/LectureDashboard/dash_calendar_notices.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

class FacilitatorDashboard extends StatefulWidget {
  final String reminder;
  final String facilitatorId;
  const FacilitatorDashboard({
    super.key,
    this.reminder = 'Reminder',
    required this.facilitatorId,
  });

  @override
  State<FacilitatorDashboard> createState() => _FacilitatorDashboardState();
}

class _FacilitatorDashboardState extends State<FacilitatorDashboard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Mycolors().offWhite,
      width: MyUtility(context).width - 280,
      height: MyUtility(context).height - 50,
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FacilitatorStudentProgressList(
                    facilitatorId: widget.facilitatorId,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      FacilitatorStudentPassRate(
                        percentage: 50,
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      FacilitatorTotalStudents()
                    ],
                  )
                ],
              ),
            ),
            Spacer(),
            Container(
              color: Colors.white,
              width: MyUtility(context).width * 0.22,
              height: MyUtility(context).height - 50,
              child: Center(
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      width: MyUtility(context).width * 0.22,
                      height: MyUtility(context).height * 0.7,
                      child: const DashCalendarNotices(),
                    ),
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
