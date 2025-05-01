import 'package:a4m/Admin/CurriculumVitae/Table/cvTable.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import '../../myutility.dart';

class CirriculumVitae extends StatefulWidget {
  const CirriculumVitae({super.key});

  @override
  State<CirriculumVitae> createState() => _CirriculumVitaeState();
}

class _CirriculumVitaeState extends State<CirriculumVitae>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TabBar
          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            indicatorColor: Mycolors().green,
            tabs: [
              Tab(
                child: Text(
                  'All CVs',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  'Lecturers',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  'Facilitators',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  'Content Devs',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
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
                // All CVs Table
                Container(
                  height: MyUtility(context).height - 95,
                  width: MyUtility(context).width - 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    border: Border.all(
                      width: 2,
                      color: Colors.black,
                    ),
                  ),
                  child: CvTable(userType: null),
                ),
                // Lecturers Table
                Container(
                  height: MyUtility(context).height - 95,
                  width: MyUtility(context).width - 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    border: Border.all(
                      width: 2,
                      color: Colors.black,
                    ),
                  ),
                  child: CvTable(userType: 'lecturer'),
                ),
                // Facilitators Table
                Container(
                  height: MyUtility(context).height - 95,
                  width: MyUtility(context).width - 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    border: Border.all(
                      width: 2,
                      color: Colors.black,
                    ),
                  ),
                  child: CvTable(userType: 'facilitator'),
                ),
                // Content Devs Table
                Container(
                  height: MyUtility(context).height - 95,
                  width: MyUtility(context).width - 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    border: Border.all(
                      width: 2,
                      color: Colors.black,
                    ),
                  ),
                  child: CvTable(userType: 'contentDev'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
