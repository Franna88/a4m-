import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../CommonComponents/inputFields/mySearchBar.dart';
import '../../../../../myutility.dart';
import '../../../../AdminA4mMembers/ui/memberContainers.dart';
import '../../../../../CommonComponents/dialogs/submitUserReportDialog.dart';

class LecturerList extends StatefulWidget {
  final Function(String id, String name, String userType)? onLecturerSelected;

  const LecturerList({
    super.key,
    this.onLecturerSelected,
  });

  @override
  State<LecturerList> createState() => _LecturerListState();
}

class _LecturerListState extends State<LecturerList> {
  final TextEditingController searchLecturer = TextEditingController();
  String searchQuery = '';
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    searchLecturer.addListener(() {
      setState(() {
        searchQuery = searchLecturer.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    searchLecturer.dispose();
    super.dispose();
  }

  void _showReportDialog(
      BuildContext context, String lecturerId, String lecturerName) {
    showDialog(
      context: context,
      builder: (context) => SubmitUserReportDialog(
        userId: lecturerId,
        userName: lecturerName,
        userType: 'lecturer',
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

    return Container(
      width: double.infinity,
      height: MyUtility(context).height - 110,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 300,
            child: MySearchBar(
              textController: searchLecturer,
              hintText: 'Search Lecturers',
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .where('userType', isEqualTo: 'lecturer')
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
                  return const Center(child: Text('No lecturers found'));
                }

                final lecturers = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  data['uid'] = doc.id;
                  return data;
                }).where((lecturer) {
                  final name =
                      (lecturer['name'] ?? '').toString().toLowerCase();
                  final id = lecturer['uid'] ?? '';
                  // Filter out current user and apply search
                  return id != currentUserId &&
                      (searchQuery.isEmpty || name.contains(searchQuery));
                }).toList();

                if (lecturers.isEmpty) {
                  return const Center(
                    child: Text('No lecturers match your search'),
                  );
                }

                return SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: LayoutGrid(
                      gridFit: GridFit.loose,
                      columnSizes: List.generate(columns, (index) => 1.fr),
                      rowSizes:
                          List.generate(lecturers.length, (index) => auto),
                      rowGap: 15,
                      columnGap: 8,
                      children: lecturers.map((lecturer) {
                        final lecturerId = lecturer['uid'] ?? '';
                        final name = lecturer['name'] ?? 'Unknown';
                        final phone = lecturer['phoneNumber'] ?? '';
                        final profileImage = lecturer['profileImageUrl'] ?? '';
                        final userType = lecturer['userType'] ?? 'lecturer';

                        return MemberContainers(
                          image: profileImage.isNotEmpty
                              ? profileImage
                              : 'images/person1.png',
                          name: name,
                          number: phone,
                          isLecturer: true,
                          studentAmount:
                              lecturer['studentCount']?.toString() ?? '0',
                          onTap: () {
                            if (widget.onLecturerSelected != null) {
                              widget.onLecturerSelected!(
                                  lecturerId, name, userType);
                            }
                          },
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.report_problem,
                              size: 20,
                              color: Colors.grey,
                            ),
                            onPressed: () =>
                                _showReportDialog(context, lecturerId, name),
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
