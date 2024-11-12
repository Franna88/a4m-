import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

import '../../../../../CommonComponents/inputFields/mySearchBar.dart';
import '../../../../../myutility.dart';
import '../../../../AdminA4mMembers/ui/memberContainers.dart';
import 'dummyList/contentDevDataList.dart';

class ContentDevList extends StatefulWidget {
  const ContentDevList({super.key});

  @override
  State<ContentDevList> createState() => _ContentDevListState();
}

class _ContentDevListState extends State<ContentDevList> {
  final TextEditingController searchContentDev = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final contentDevsFiltered = contentDevs;
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
                textController: searchContentDev, hintText: 'Search'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutGrid(
              gridFit: GridFit.loose,
              columnSizes: List.generate(columns, (index) => 1.fr), // Dynamic columns
              rowSizes: List.generate(contentDevsFiltered.length, (index) => auto),
              rowGap: 15, // Adjust vertical gap as needed
              columnGap: 8, // Adjust horizontal gap as needed
              children: contentDevsFiltered.map((contentDev) {
                return MemberContainers(
                  isContentDev: contentDev.isContentDev,
                  image: contentDev.image,
                  name: contentDev.name,
                  number: contentDev.number,
                  contentTotal: contentDev.content,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
