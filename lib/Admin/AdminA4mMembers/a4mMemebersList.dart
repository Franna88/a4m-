import 'package:a4m/Admin/AdminA4mMembers/dummyDataModel/membersDummyData.dart';
import 'package:a4m/CommonComponents/inputFields/myDropDownMenu.dart';
import 'package:a4m/CommonComponents/inputFields/mySearchBar.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  List<MembersDummyData> _members = [];
  bool _isLoading = true;
  String _searchQuery = '';

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

    // Fetch members data when the widget initializes
    _fetchMembersData();
  }

  Future<void> _fetchMembersData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final members = await fetchMembersData();
      setState(() {
        _members = members;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching members data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Filter members based on selected tab and search query
  List<MembersDummyData> get _filteredMembers {
    return _members.where((member) {
      // Filter by tab
      bool matchesTab = false;
      if (selectedTab == 'Lecturer' && member.isLecturer == true) {
        matchesTab = true;
      } else if (selectedTab == 'ContentDev' && member.isContentDev == true) {
        matchesTab = true;
      } else if (selectedTab == 'Facilitators' &&
          member.isFacilitator == true) {
        matchesTab = true;
      }

      // Filter by search query if provided
      if (_searchQuery.isEmpty) {
        return matchesTab;
      } else {
        return matchesTab &&
            (member.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                member.number.contains(_searchQuery));
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final memberSearch = TextEditingController();
    final memberCategorySelect = TextEditingController();

    // Calculate the number of columns based on the screen width
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount =
        (screenWidth ~/ 400).clamp(1, 6); // Minimum 1, maximum 6

    return SizedBox(
      width: MyUtility(context).width - 320,
      height: MyUtility(context).height - 80,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
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

            // Loading indicator or content
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_filteredMembers.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'No ${selectedTab.toLowerCase()} found',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            else
              // Scrollable grid layout
              Expanded(
                child: SingleChildScrollView(
                  child: LayoutGrid(
                    columnSizes: List.generate(
                      crossAxisCount,
                      (_) => FlexibleTrackSize(220),
                    ),
                    rowSizes: List.generate(
                      (_filteredMembers.length / crossAxisCount).ceil(),
                      (_) => auto,
                    ),
                    rowGap: 20, // Space between rows
                    columnGap: 1, // Space between columns
                    children: [
                      for (var member in _filteredMembers)
                        SizedBox(
                          height: 300,
                          width: 250,
                          child: MemberContainers(
                            key: ValueKey('${member.id}_${selectedTab}'),
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
