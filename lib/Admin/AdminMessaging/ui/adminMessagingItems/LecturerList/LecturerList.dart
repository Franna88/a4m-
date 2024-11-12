import 'package:a4m/Admin/AdminMessaging/ui/adminMessagingItems/LecturerList/dummyList/lecturerDummyList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

import '../../../../../CommonComponents/inputFields/mySearchBar.dart';
import '../../../../../myutility.dart';
import '../../../../AdminA4mMembers/ui/memberContainers.dart';


class LecturerList extends StatefulWidget {
  const LecturerList({super.key});

  @override
  State<LecturerList> createState() => _LecturerListState();
}

class _LecturerListState extends State<LecturerList> {
  final TextEditingController searchlecturer = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final lecturersFiltered = lecturers;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Define desired item width
    const double itemWidth = 250;
    // Calculate number of columns based on available width
    int columns = (screenWidth / itemWidth).floor().clamp(1, 4); // Limits columns to min 1, max 4

    return Container(
      width: MyUtility(context).width - 580,
      height: MyUtility(context).height - 110,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 300,
            child: MySearchBar(
                textController: searchlecturer, hintText: 'Search'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutGrid(
              gridFit: GridFit.loose,
              columnSizes: List.generate(columns, (index) => 1.fr), // Dynamic columns
              rowSizes: List.generate(lecturersFiltered.length, (index) => auto),
              rowGap: 15, // Adjust vertical gap as needed
              columnGap: 8, // Adjust horizontal gap as needed
              children: lecturersFiltered.map((lecturer) {
                return MemberContainers(
                  isLecturer: lecturer.isLecturer,
                  image: lecturer.image,
                  name: lecturer.name,
                  number: lecturer.number,
                  studentAmount: lecturer.studentAmount,
                  rating: lecturer.rating,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
