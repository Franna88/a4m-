import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../CommonComponents/inputFields/mySearchBar.dart';
import '../../../../../myutility.dart';
import '../../../../AdminA4mMembers/ui/memberContainers.dart';
import '../../../../../CommonComponents/dialogs/submitUserReportDialog.dart';

class AdminList extends StatefulWidget {
  final Function(String id, String name, String userType)? onAdminSelected;
  final String? currentUserId;

  const AdminList({
    super.key,
    this.onAdminSelected,
    this.currentUserId,
  });

  @override
  State<AdminList> createState() => _AdminListState();
}

class _AdminListState extends State<AdminList> {
  final TextEditingController searchAdmin = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    searchAdmin.addListener(() {
      setState(() {
        searchQuery = searchAdmin.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    searchAdmin.dispose();
    super.dispose();
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
              textController: searchAdmin,
              hintText: 'Search Admins',
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .where('userType', isEqualTo: 'admin')
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
                  return const Center(child: Text('No admins found'));
                }

                final admins = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  data['uid'] = doc.id;
                  return data;
                }).where((admin) {
                  final name = (admin['name'] ?? '').toString().toLowerCase();
                  final id = admin['uid'] ?? '';
                  // Filter out current user and apply search
                  return id != widget.currentUserId &&
                      (searchQuery.isEmpty || name.contains(searchQuery));
                }).toList();

                if (admins.isEmpty) {
                  return const Center(
                    child: Text('No admins match your search'),
                  );
                }

                return SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: LayoutGrid(
                      gridFit: GridFit.loose,
                      columnSizes: List.generate(columns, (index) => 1.fr),
                      rowSizes: List.generate(admins.length, (index) => auto),
                      rowGap: 15,
                      columnGap: 8,
                      children: admins.map((admin) {
                        final adminId = admin['uid'] ?? '';
                        final name = admin['name'] ?? 'Unknown';
                        final phone = admin['phoneNumber'] ?? '';
                        final profileImage = admin['profileImageUrl'] ?? '';
                        final userType = admin['userType'] ?? 'admin';

                        return MemberContainers(
                          image: profileImage.isNotEmpty
                              ? profileImage
                              : 'images/person1.png',
                          name: name,
                          number: phone,
                          isAdmin: true,
                          onTap: () {
                            if (widget.onAdminSelected != null) {
                              widget.onAdminSelected!(adminId, name, userType);
                            }
                          },
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
