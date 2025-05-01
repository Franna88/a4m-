import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../CommonComponents/inputFields/mySearchBar.dart';
import '../../../../../myutility.dart';
import '../../../../AdminA4mMembers/ui/memberContainers.dart';
import '../../../../../CommonComponents/dialogs/submitUserReportDialog.dart';

class ContentDevList extends StatefulWidget {
  final Function(String id, String name, String userType)? onContentDevSelected;

  const ContentDevList({
    super.key,
    this.onContentDevSelected,
  });

  @override
  State<ContentDevList> createState() => _ContentDevListState();
}

class _ContentDevListState extends State<ContentDevList> {
  final TextEditingController searchContentDev = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    searchContentDev.addListener(() {
      setState(() {
        searchQuery = searchContentDev.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    searchContentDev.dispose();
    super.dispose();
  }

  void _showReportDialog(
      BuildContext context, String contentDevId, String contentDevName) {
    showDialog(
      context: context,
      builder: (context) => SubmitUserReportDialog(
        userId: contentDevId,
        userName: contentDevName,
        userType: 'content_dev',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double itemWidth = 200;
    int columns = 1;

    if (screenWidth > 800) {
      columns = ((screenWidth - 300) / itemWidth).floor().clamp(1, 3);
    }

    return SizedBox(
      width: double.infinity,
      height: MyUtility(context).height - 110,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 300,
            child: MySearchBar(
              textController: searchContentDev,
              hintText: 'Search Content Developers',
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .where('userType', isEqualTo: 'content_dev')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error.toString()}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('No content developers found'));
                }

                final contentDevs = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  data['uid'] = doc.id;
                  return data;
                }).where((contentDev) {
                  final name =
                      (contentDev['name'] ?? '').toString().toLowerCase();
                  return searchQuery.isEmpty || name.contains(searchQuery);
                }).toList();

                if (contentDevs.isEmpty) {
                  return const Center(
                    child: Text('No content developers match your search'),
                  );
                }

                return SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: LayoutGrid(
                      gridFit: GridFit.loose,
                      columnSizes: List.generate(columns, (index) => 1.fr),
                      rowSizes:
                          List.generate(contentDevs.length, (index) => auto),
                      rowGap: 15,
                      columnGap: 8,
                      children: contentDevs.map((contentDev) {
                        final contentDevId = contentDev['uid'] ?? '';
                        final name = contentDev['name'] ?? 'Unknown';
                        final phone = contentDev['phoneNumber'] ?? '';
                        final profileImage =
                            contentDev['profileImageUrl'] ?? '';
                        final userType =
                            contentDev['userType'] ?? 'content_dev';

                        return MemberContainers(
                          image: profileImage.isNotEmpty
                              ? profileImage
                              : 'images/person1.png',
                          name: name,
                          number: phone,
                          isContentDev: true,
                          contentTotal:
                              contentDev['contentCount']?.toString() ?? '0',
                          onTap: () {
                            if (widget.onContentDevSelected != null) {
                              widget.onContentDevSelected!(
                                  contentDevId, name, userType);
                            }
                          },
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.report_problem,
                              size: 20,
                              color: Colors.grey,
                            ),
                            onPressed: () =>
                                _showReportDialog(context, contentDevId, name),
                            tooltip: 'Submit report about $name',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
