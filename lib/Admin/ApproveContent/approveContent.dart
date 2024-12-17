import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:a4m/Admin/AdminCourses/Table/courseTable.dart';
import 'package:a4m/Admin/ApproveContent/Table/reviewMarksTable.dart';
import 'package:a4m/CommonComponents/inputFields/myDropDownMenu.dart';
import 'package:a4m/myutility.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Table/approveNewContentTable.dart';

class ApproveContent extends StatefulWidget {
  final Function(int, [Map<String, dynamic>?]) changePage;

  const ApproveContent({super.key, required this.changePage});

  @override
  State<ApproveContent> createState() => _ApproveContentState();
}

class _ApproveContentState extends State<ApproveContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void changePageWrapper(int pageIndex, [Map<String, dynamic>? data]) {
    // Add a debug print statement here to verify the courseId being passed
    if (data != null && data.containsKey('courseId')) {
      print('ApproveContent: Received courseId ${data['courseId']}');
    } else {
      print('ApproveContent: No courseId provided');
    }
    widget.changePage(pageIndex, data);
  }

  @override
  Widget build(BuildContext context) {
    final oldNew = TextEditingController();

    return SizedBox(
      height: MyUtility(context).height - 80,
      width: MyUtility(context).width - 280,
      child: DefaultTabController(
        length: 5, // Number of tabs
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown Menu
              MyDropDownMenu(
                customSize: 300,
                items: [],
                textfieldController: oldNew,
              ),
              const SizedBox(height: 20),

              // TabBar
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                indicatorColor: Mycolors().green,
                tabs: [
                  Tab(
                    child: Text(
                      'New Courses',
                      style:
                          GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Updated Courses',
                      style:
                          GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Approved Courses',
                      style:
                          GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Declined Courses',
                      style:
                          GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Removed Courses',
                      style:
                          GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // TabBarView for the tables
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // New Courses Table
                    Container(
                      height: MyUtility(context).height * 0.75,
                      width: MyUtility(context).width - 320,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        border: Border.all(
                          width: 2,
                          color: Colors.black,
                        ),
                      ),
                      child: ApproveNewContentTable(
                        changePage: changePageWrapper,
                        status: 'pending_approval',
                      ),
                    ),

                    // Updated Courses Table (Reusing ApproveNewContentTable)
                    Container(
                      height: MyUtility(context).height * 0.75,
                      width: MyUtility(context).width - 320,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        border: Border.all(
                          width: 2,
                          color: Colors.black,
                        ),
                      ),
                      child: ApproveNewContentTable(
                        changePage: changePageWrapper,
                        status: 'updated',
                      ),
                    ),

                    // Approved Courses Table (Reusing ApproveNewContentTable)
                    Container(
                      height: MyUtility(context).height * 0.75,
                      width: MyUtility(context).width - 320,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        border: Border.all(
                          width: 2,
                          color: Colors.black,
                        ),
                      ),
                      child: ApproveNewContentTable(
                        changePage: changePageWrapper,
                        status: 'approved',
                      ),
                    ),

                    // Declined Courses Table (Reusing ApproveNewContentTable)
                    Container(
                      height: MyUtility(context).height * 0.75,
                      width: MyUtility(context).width - 320,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        border: Border.all(
                          width: 2,
                          color: Colors.black,
                        ),
                      ),
                      child: ApproveNewContentTable(
                        changePage: changePageWrapper,
                        status: 'declined',
                      ),
                    ),

                    // Removed Courses Table (Reusing ApproveNewContentTable)
                    Container(
                      height: MyUtility(context).height * 0.75,
                      width: MyUtility(context).width - 320,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        border: Border.all(
                          width: 2,
                          color: Colors.black,
                        ),
                      ),
                      child: ApproveNewContentTable(
                        changePage: changePageWrapper,
                        status: 'removed',
                      ),
                    ),
                  ],
                ),
              ),

              // Commented out code for future use
              // Container(
              //   height: MyUtility(context).height * 0.75,
              //   width: MyUtility(context).width - 320,
              //   decoration: BoxDecoration(
              //     borderRadius: const BorderRadius.only(
              //       topLeft: Radius.circular(8),
              //       topRight: Radius.circular(8),
              //     ),
              //     border: Border.all(
              //       width: 2,
              //       color: Colors.black,
              //     ),
              //   ),
              //   child: ReviewMarksTable(),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
