import 'package:a4m/Admin/AdminA4mMembers/dummyDataModel/membersDummyData.dart';
import 'package:a4m/CommonComponents/inputFields/myDropDownMenu.dart';
import 'package:a4m/CommonComponents/inputFields/mySearchBar.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ui/memberContainers.dart';

class A4mMembersList extends StatefulWidget {
  const A4mMembersList({super.key});

  @override
  State<A4mMembersList> createState() => _A4mMembersListState();
}

class _A4mMembersListState extends State<A4mMembersList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedTab = 'Lecturer';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        switch (_tabController.index) {
          case 0:
            selectedTab = 'Lecturer';
            break;
          case 1:
            selectedTab = 'ContentDev';
            break;
          case 2:
            selectedTab = 'Facilitators';
            break;
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memberSearch = TextEditingController();
    final memberCategorySelect = TextEditingController();

    // Calculate the number of columns based on the screen width
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount =
        (screenWidth ~/ 400).clamp(1, 6); // Minimum 1, maximum 6

    return Container(
      width: MyUtility(context).width - 320,
      height: MyUtility(context).height - 80,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TabBar to filter members

            // Search bar and dropdown
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyDropDownMenu(
                  description: 'Member Category',
                  customSize: 300,
                  items: [], // Update with member categories if needed
                  textfieldController: memberCategorySelect,
                ),
                SizedBox(
                  width: 300,
                  height: 50,
                  child: MySearchBar(
                    textController: memberSearch,
                    hintText: 'Search Member',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              indicatorColor: Colors.green,
              tabs: [
                Tab(
                  child: Text(
                    'Lecturer',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                  ),
                ),
                Tab(
                  child: Text(
                    'ContentDev',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                  ),
                ),
                Tab(
                  child: Text(
                    'Facilitators',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Scrollable grid layout
            Expanded(
              child: SingleChildScrollView(
                child: LayoutGrid(
                  columnSizes: List.generate(
                    crossAxisCount,
                    (_) => FlexibleTrackSize(220),
                  ),
                  rowSizes: List.generate(
                    (memberdummyData.length / crossAxisCount).ceil(),
                    (_) => auto,
                  ),
                  rowGap: 20, // Space between rows
                  columnGap: 1, // Space between columns
                  children: [
                    for (var member in memberdummyData)
                      if ((selectedTab == 'Lecturer' &&
                              member.isLecturer == true) ||
                          (selectedTab == 'ContentDev' &&
                              member.isContentDev == true) ||
                          (selectedTab == 'Facilitators' &&
                              member.isFacilitator == true))
                        SizedBox(
                          height: 300,
                          width: 250,
                          child: MemberContainers(
                            isLecturer: member.isLecturer,
                            isContentDev: member.isContentDev,
                            isFacilitator: member.isFacilitator,
                            image: member.image,
                            name: member.name,
                            number: member.number,
                            studentAmount: member.students,
                            contentTotal: member.content,
                            rating: member.rating,
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
