import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../CommonComponents/inputFields/mySearchBar.dart';
import '../../../myutility.dart';
import '../../../services/messaging_service.dart';
import 'lecture_student_containers.dart';

class LectureStudent extends StatefulWidget {
  final String lecturerId;
  final Function(int)? changePage;

  const LectureStudent({
    super.key,
    required this.lecturerId,
    this.changePage,
  });

  @override
  State<LectureStudent> createState() => _LectureStudentState();
}

class _LectureStudentState extends State<LectureStudent> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  final MessagingService _messagingService = MessagingService();
  String? _selectedCourseId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<List<Map<String, dynamic>>> _getLecturerCourses() {
    print('Fetching courses for lecturer: ${widget.lecturerId}');
    return _firestore
        .collection('courses')
        .where('assignedLecturers', isNotEqualTo: null)
        .snapshots()
        .map((snapshot) {
      final courses = snapshot.docs.where((doc) {
        final data = doc.data();
        final assignedLecturers = data['assignedLecturers'] as List<dynamic>?;
        if (assignedLecturers == null) return false;

        return assignedLecturers.any((lecturer) =>
            lecturer is Map<String, dynamic> &&
            lecturer['id'].toString().trim() == widget.lecturerId.trim());
      }).map((doc) {
        final data = doc.data();
        print('Course data: $data');
        return {
          'id': doc.id,
          'name': data['courseName'] ??
              data['name'] ??
              data['course_name'] ??
              data['title'] ??
              '',
          'students': data['students'] ?? [],
          ...data,
        };
      }).toList();

      print('Found ${courses.length} courses for lecturer');
      return courses;
    });
  }

  Stream<List<Map<String, dynamic>>> _getStudents() {
    if (_selectedCourseId != null) {
      // Get students for a specific course
      print('Fetching students for course: $_selectedCourseId');
      return _firestore
          .collection('courses')
          .doc(_selectedCourseId)
          .snapshots()
          .asyncMap((courseDoc) async {
        if (!courseDoc.exists) {
          print('Course not found');
          return [];
        }

        final courseData = courseDoc.data()!;
        print('Course data: $courseData');

        final studentsList = (courseData['students'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map((student) => student['studentId'] as String?)
            .where((id) => id != null)
            .cast<String>()
            .toList();

        print('Found ${studentsList.length} student IDs in course');

        if (studentsList.isEmpty) return [];

        // Fetch student details from Users collection
        final studentsSnapshot = await _firestore
            .collection('Users')
            .where(FieldPath.documentId, whereIn: studentsList)
            .get();

        final students = studentsSnapshot.docs.map((doc) {
          final data = doc.data();
          print('Student data: $data');
          return {
            'id': doc.id,
            'name':
                data['name'] ?? data['full_name'] ?? data['displayName'] ?? '',
            'email': data['email'] ?? '',
            'profileImageUrl': data['profileImageUrl'] ??
                data['profile_image_url'] ??
                data['photoURL'] ??
                '',
            'studentNumber': data['studentNumber'] ??
                data['student_number'] ??
                data['student_id'] ??
                '',
            ...data,
          };
        }).toList();
        print('Processed ${students.length} student records');
        return students;
      });
    } else {
      // Get all students for all lecturer's courses
      print('Fetching students for all courses');
      return _getLecturerCourses().asyncMap((courses) async {
        if (courses.isEmpty) {
          print('No courses found for lecturer');
          return [];
        }

        // Collect all unique student IDs from all courses
        final studentIds = courses
            .expand((course) {
              final studentsList = (course['students'] as List<dynamic>? ?? []);
              return studentsList
                  .whereType<Map<String, dynamic>>()
                  .map((student) => student['studentId'] as String?)
                  .where((id) => id != null);
            })
            .toSet()
            .cast<String>()
            .toList();

        print(
            'Found ${studentIds.length} unique student IDs across all courses');
        if (studentIds.isEmpty) return [];

        // Fetch student details from Users collection
        final studentsSnapshot = await _firestore
            .collection('Users')
            .where(FieldPath.documentId, whereIn: studentIds)
            .get();

        final students = studentsSnapshot.docs.map((doc) {
          final data = doc.data();
          print('Student data: $data');
          return {
            'id': doc.id,
            'name':
                data['name'] ?? data['full_name'] ?? data['displayName'] ?? '',
            'email': data['email'] ?? '',
            'profileImageUrl': data['profileImageUrl'] ??
                data['profile_image_url'] ??
                data['photoURL'] ??
                '',
            'studentNumber': data['studentNumber'] ??
                data['student_number'] ??
                data['student_id'] ??
                '',
            ...data,
          };
        }).toList();
        print('Processed ${students.length} student records');
        return students;
      });
    }
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

      String? courseTitle;
      if (_selectedCourseId != null) {
        final courseDoc =
            await _firestore.collection('courses').doc(_selectedCourseId).get();
        courseTitle = courseDoc.data()?['courseName'] as String? ?? '';
      }

      // Get the chat ID by sorting the user IDs
      final List<String> sortedIds = [widget.lecturerId, student['id']]..sort();
      final chatId = sortedIds.join('_');

      // Check if chat exists, if not create it
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) {
        await _messagingService.createChat(
          senderId: widget.lecturerId,
          receiverId: student['id'],
          senderType: 'lecturer',
          receiverType: 'student',
          courseId: _selectedCourseId,
          courseTitle: courseTitle,
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
      print('Error opening chat: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // Calculate available width for containers
    double availableWidth = MyUtility(context).width -
        320 -
        30; // Total width minus sidebar and padding

    return SizedBox(
      width: MyUtility(context).width - 320,
      height: MyUtility(context).height - 80,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course filter dropdown and search bar
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Course filter dropdown
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _getLecturerCourses(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox(width: 300);
                    }

                    final courses = snapshot.data!;
                    return Container(
                      width: 300,
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedCourseId,
                        hint: const Text('Filter by Course'),
                        isExpanded: true,
                        underline: Container(),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Courses'),
                          ),
                          ...courses.map((course) {
                            return DropdownMenuItem<String>(
                              value: course['id'],
                              child: Text(course['name']),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCourseId = value;
                          });
                        },
                      ),
                    );
                  },
                ),
                // Search bar
                SizedBox(
                  width: 300,
                  height: 50,
                  child: MySearchBar(
                    textController: _searchController,
                    hintText: 'Search Student',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Students grid
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _getStudents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No students found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }

                  final students = snapshot.data!.where((student) {
                    final searchQuery = _searchQuery.toLowerCase();
                    final name = student['name'].toString().toLowerCase();
                    final email = student['email'].toString().toLowerCase();
                    final number =
                        student['studentNumber'].toString().toLowerCase();
                    return name.contains(searchQuery) ||
                        email.contains(searchQuery) ||
                        number.contains(searchQuery);
                  }).toList();

                  if (students.isEmpty) {
                    return const Center(
                      child: Text(
                        'No matching students found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: availableWidth),
                        child: Wrap(
                          spacing: 20, // Horizontal space between containers
                          runSpacing: 20, // Vertical space between rows
                          alignment: WrapAlignment.start,
                          children: students.map((student) {
                            return LectureStudentContainers(
                              image: student['profileImageUrl'] ?? '',
                              name: student['name'] ?? 'No Name',
                              number: student['studentNumber'] ?? 'No ID',
                              isStudent: true,
                              onMessageTap: () => _handleMessageTap(student),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
