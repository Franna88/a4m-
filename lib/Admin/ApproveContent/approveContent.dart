import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:a4m/Admin/AdminCourses/Table/courseTable.dart';
import 'package:a4m/Admin/ApproveContent/Table/reviewMarksTable.dart';
import 'package:a4m/CommonComponents/inputFields/myDropDownMenu.dart';
import 'package:a4m/myutility.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Table/approveNewContentTable.dart';

class ApproveContent extends StatefulWidget {
  const ApproveContent({super.key});

  @override
  State<ApproveContent> createState() => _ApproveContentState();
}

class _ApproveContentState extends State<ApproveContent> {
  @override
  Widget build(BuildContext context) {
    final oldNew = TextEditingController();

    return SizedBox(
      height: MyUtility(context).height - 80,
      width: MyUtility(context).width - 280,
      child: DefaultTabController(
        length: 2, // Number of tabs
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
                labelColor: Colors.black,
                indicatorColor: Mycolors().green,
                tabs: [
                  Tab(
                    child: Text(
                      'Approve New Content',
                      style:
                          GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Review Marks',
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
                  children: [
                    // Approve New Content Table
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
                      child: ApproveNewContentTable(),
                    ),

                    // Review Marks Table
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
                      child: ReviewMarksTable(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
