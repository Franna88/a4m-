import 'package:a4m/Admin/AdminMessaging/ui/adminMessagingItems/FacilitatorList/dummyList/facilitatorDummyList.dart';
import 'package:a4m/Admin/AdminMessaging/ui/adminMessagingItems/LecturerList/dummyList/lecturerDummyList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

import '../../../../../CommonComponents/inputFields/mySearchBar.dart';
import '../../../../../myutility.dart';
import '../../../../AdminA4mMembers/ui/memberContainers.dart';

class FacilitatorList extends StatefulWidget {
  const FacilitatorList({super.key});

  @override
  State<FacilitatorList> createState() => _FacilitatorListState();
}

class _FacilitatorListState extends State<FacilitatorList> {
  final TextEditingController searchFacilitator = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final facilitatorFiltered = facilitators;
    final screenWidth = MediaQuery.of(context).size.width;

    // Define desired item width
    const double itemWidth = 250;
    // Calculate number of columns based on available width
    int columns = (screenWidth / itemWidth)
        .floor()
        .clamp(1, 4); // Limits columns to min 1, max 4

    return Container(
      width: MyUtility(context).width - 580,
      height: MyUtility(context).height - 110,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 300,
            child: MySearchBar(
                textController: searchFacilitator, hintText: 'Search'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutGrid(
              gridFit: GridFit.loose,
              columnSizes:
                  List.generate(columns, (index) => 1.fr), // Dynamic columns
              rowSizes:
                  List.generate(facilitatorFiltered.length, (index) => auto),
              rowGap: 15, // Adjust vertical gap as needed
              columnGap: 8, // Adjust horizontal gap as needed
              children: facilitatorFiltered.map((facilitators) {
                return MemberContainers(
                  isFacilitator: facilitators.isFacilitator,
                  image: facilitators.image,
                  name: facilitators.name,
                  number: facilitators.number,
                  studentAmount: facilitators.studentAmount,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
