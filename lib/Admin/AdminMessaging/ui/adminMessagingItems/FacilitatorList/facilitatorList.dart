import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../CommonComponents/inputFields/mySearchBar.dart';
import '../../../../../myutility.dart';
import '../../../../AdminA4mMembers/ui/memberContainers.dart';
import '../../../../../CommonComponents/dialogs/submitUserReportDialog.dart';

class FacilitatorList extends StatefulWidget {
  final Function(String id, String name, String userType)?
      onFacilitatorSelected;

  const FacilitatorList({
    super.key,
    this.onFacilitatorSelected,
  });

  @override
  State<FacilitatorList> createState() => _FacilitatorListState();
}

class _FacilitatorListState extends State<FacilitatorList> {
  final TextEditingController searchFacilitator = TextEditingController();
  String searchQuery = '';
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    searchFacilitator.addListener(() {
      setState(() {
        searchQuery = searchFacilitator.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    searchFacilitator.dispose();
    super.dispose();
  }

  void _showReportDialog(
      BuildContext context, String facilitatorId, String facilitatorName) {
    showDialog(
      context: context,
      builder: (context) => SubmitUserReportDialog(
        userId: facilitatorId,
        userName: facilitatorName,
        userType: 'facilitator',
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
              textController: searchFacilitator,
              hintText: 'Search Facilitators',
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .where('userType', isEqualTo: 'facilitator')
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
                  return const Center(child: Text('No facilitators found'));
                }

                final facilitators = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  data['uid'] = doc.id;
                  return data;
                }).where((facilitator) {
                  final name =
                      (facilitator['name'] ?? '').toString().toLowerCase();
                  final id = facilitator['uid'] ?? '';
                  // Filter out current user and apply search
                  return id != currentUserId &&
                      (searchQuery.isEmpty || name.contains(searchQuery));
                }).toList();

                if (facilitators.isEmpty) {
                  return const Center(
                    child: Text('No facilitators match your search'),
                  );
                }

                return SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: LayoutGrid(
                      gridFit: GridFit.loose,
                      columnSizes: List.generate(columns, (index) => 1.fr),
                      rowSizes:
                          List.generate(facilitators.length, (index) => auto),
                      rowGap: 15,
                      columnGap: 8,
                      children: facilitators.map((facilitator) {
                        final facilitatorId = facilitator['uid'] ?? '';
                        final name = facilitator['name'] ?? 'Unknown';
                        final phone = facilitator['phoneNumber'] ?? '';
                        final profileImage =
                            facilitator['profileImageUrl'] ?? '';
                        final userType =
                            facilitator['userType'] ?? 'facilitator';

                        return MemberContainers(
                          image: profileImage.isNotEmpty
                              ? profileImage
                              : 'images/person1.png',
                          name: name,
                          number: phone,
                          isFacilitator: true,
                          studentAmount:
                              facilitator['studentCount']?.toString() ?? '0',
                          onTap: () {
                            if (widget.onFacilitatorSelected != null) {
                              widget.onFacilitatorSelected!(
                                  facilitatorId, name, userType);
                            }
                          },
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.report_problem,
                              size: 20,
                              color: Colors.grey,
                            ),
                            onPressed: () =>
                                _showReportDialog(context, facilitatorId, name),
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
