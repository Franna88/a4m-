import 'package:a4m/Admin/AdminA4mMembers/dummyDataModel/membersDummyData.dart';
import 'package:a4m/CommonComponents/inputFields/myDropDownMenu.dart';
import 'package:a4m/CommonComponents/inputFields/mySearchBar.dart';
import 'package:a4m/Lecturers/LectureStudents/lecture_student_containers.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/messaging_service.dart';

class FacilitatorStudents extends StatefulWidget {
  final String facilitatorId;
  final Function(int)? changePage;

  const FacilitatorStudents({
    super.key,
    required this.facilitatorId,
    this.changePage,
  });

  @override
  State<FacilitatorStudents> createState() => _FacilitatorStudentsState();
}

class _FacilitatorStudentsState extends State<FacilitatorStudents> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MessagingService _messagingService = MessagingService();
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'name';
  String _searchQuery = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _fetchStudents();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _fetchStudents() async {
    try {
      setState(() => _isLoading = true);

      // Get students from facilitatorStudents subcollection
      QuerySnapshot studentsSnapshot = await _firestore
          .collection('Users')
          .doc(widget.facilitatorId)
          .collection('facilitatorStudents')
          .get();

      List<Map<String, dynamic>> fetchedStudents = [];

      for (var doc in studentsSnapshot.docs) {
        Map<String, dynamic> studentData = doc.data() as Map<String, dynamic>;

        // Get student's enrolled courses
        DocumentSnapshot studentDoc =
            await _firestore.collection('Users').doc(doc.id).get();

        if (studentDoc.exists) {
          Map<String, dynamic> userData =
              studentDoc.data() as Map<String, dynamic>;
          List<dynamic> enrolledCourses = userData['enrolledCourses'] ?? [];

          fetchedStudents.add({
            'id': doc.id,
            'name': studentData['name'] ?? userData['name'] ?? 'Unknown',
            'email': studentData['email'] ?? userData['email'] ?? '',
            'phoneNumber':
                studentData['phoneNumber'] ?? userData['phoneNumber'] ?? '',
            'profileImageUrl': studentData['profileImageUrl'] ??
                userData['profileImageUrl'] ??
                '',
            'courseCount': enrolledCourses.length,
            'createdAt': studentData['createdAt'] ?? userData['createdAt'],
          });
        }
      }

      // Sort students based on current sort criteria
      _sortStudents(fetchedStudents);

      setState(() {
        _students = fetchedStudents;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching students: $e');
      setState(() => _isLoading = false);
    }
  }

  void _sortStudents(List<Map<String, dynamic>> students) {
    switch (_sortBy) {
      case 'name':
        students.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
        break;
      case 'newest':
        students.sort((a, b) {
          var aDate = a['createdAt']?.toDate() ?? DateTime(1900);
          var bDate = b['createdAt']?.toDate() ?? DateTime(1900);
          return bDate.compareTo(aDate);
        });
        break;
      case 'oldest':
        students.sort((a, b) {
          var aDate = a['createdAt']?.toDate() ?? DateTime(1900);
          var bDate = b['createdAt']?.toDate() ?? DateTime(1900);
          return aDate.compareTo(bDate);
        });
        break;
    }
  }

  List<Map<String, dynamic>> _getFilteredStudents() {
    if (_searchQuery.isEmpty) return _students;

    return _students.where((student) {
      String name = (student['name'] ?? '').toLowerCase();
      String email = (student['email'] ?? '').toLowerCase();
      String query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  Future<void> _handleMessageTap(Map<String, dynamic> student) async {
    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening chat...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // Get the chat ID by sorting the user IDs
      final List<String> sortedIds = [widget.facilitatorId, student['id']]
        ..sort();
      final chatId = sortedIds.join('_');

      // Check if chat exists, if not create it
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) {
        await _messagingService.createChat(
          senderId: widget.facilitatorId,
          receiverId: student['id'],
          senderType: 'facilitator',
          receiverType: 'student',
          courseId: null,
          courseTitle: null,
        );
      }

      // Only navigate if context is still mounted
      if (context.mounted) {
        // Set the selected chat information in the messaging service
        await _messagingService.setSelectedChat(
            chatId: chatId,
            otherUserId: student['id'],
            otherUserName: student['name'],
            otherUserImage: student['profileImageUrl'] ?? '',
            userType: 'student');

        // Navigate to messages page
        widget.changePage?.call(4); // Index 4 is the Messages page
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open chat: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = _getFilteredStudents();
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth ~/ 400).clamp(1, 6);

    return SizedBox(
      width: MyUtility(context).width - 320,
      height: MyUtility(context).height - 80,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyDropDownMenu(
                  description: 'Sort By',
                  customSize: 300,
                  items: ['A-Z', 'Newest', 'Oldest'],
                  textfieldController: TextEditingController(text: _sortBy),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortBy = value.toLowerCase();
                        _sortStudents(_students);
                      });
                    }
                  },
                ),
                SizedBox(
                  width: 300,
                  height: 50,
                  child: MySearchBar(
                    textController: _searchController,
                    hintText: 'Search Students',
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (filteredStudents.isEmpty)
              Center(
                child: Text(
                  'No students found',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: LayoutGrid(
                    columnSizes: List.generate(
                      crossAxisCount,
                      (_) => const FlexibleTrackSize(1),
                    ),
                    rowSizes: List.generate(
                      (filteredStudents.length / crossAxisCount).ceil(),
                      (_) => auto,
                    ),
                    rowGap: 20,
                    columnGap: 20,
                    children: filteredStudents
                        .map((student) => LectureStudentContainers(
                              isLecturer: false,
                              isContentDev: false,
                              isFacilitator: true,
                              image: student['profileImageUrl'] ??
                                  'https://via.placeholder.com/150',
                              name: student['name'] ?? 'Unknown',
                              number: student['phoneNumber'] ?? 'No phone',
                              studentAmount:
                                  student['courseCount']?.toString() ?? '0',
                              onMessageTap: () => _handleMessageTap(student),
                            ))
                        .toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
