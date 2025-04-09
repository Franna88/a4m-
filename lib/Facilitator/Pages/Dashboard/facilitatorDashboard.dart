import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/Facilitator/Pages/Dashboard/ui/facilitatorStudentPassRate.dart';
import 'package:a4m/Facilitator/Pages/Dashboard/ui/facilitatorStudentProgressList.dart';
import 'package:a4m/Facilitator/Pages/Dashboard/ui/facilitatorTotalStudents.dart';
import 'package:a4m/Lecturers/LectureDashboard/dash_calendar_notices.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Content Column
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row
                  SizedBox(
                    height: 180,
                    child: Row(
                      children: [
                        // Student Pass Rate Card
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 0,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: FacilitatorStudentPassRate(
                                percentage: 50,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Total Students Card
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 0,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: FacilitatorTotalStudents(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Student Progress Section
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 0,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: FacilitatorStudentProgressList(
                          facilitatorId: widget.facilitatorId,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Calendar Section
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: const DashCalendarNotices(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
