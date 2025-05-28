import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:universal_html/js_util.dart';

import '../../../../../CommonComponents/inputFields/mySearchBar.dart';
import '../../../../../myutility.dart';
import '../../../../AdminA4mMembers/ui/memberContainers.dart';
import '../../../../../CommonComponents/dialogs/submitUserReportDialog.dart';

class StudentList extends StatefulWidget {
  final Function(String id, String name, String userType)? onStudentSelected;
  final String? currentUserId;

  const StudentList({
    super.key,
    this.onStudentSelected,
    this.currentUserId,
  });

  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  final TextEditingController searchStudent = TextEditingController();
  String searchQuery = '';
  String? _selectedCourseId;
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];

  @override
  void initState() {
    super.initState();
    searchStudent.addListener(() {
      setState(() {
        searchQuery = searchStudent.text.toLowerCase();
        _filterStudents();
      });
    });
    fetchLecturerStudents(widget.currentUserId ?? '', [])
        .then((fetchedStudents) {
      setState(() {
        students = fetchedStudents;
        filteredStudents = fetchedStudents;
      });
    });
  }

  @override
  void dispose() {
    searchStudent.dispose();
    super.dispose();
  }

  void _filterStudents() {
    setState(() {
      filteredStudents = students.where((student) {
        final name = (student['name'] ?? '').toString().toLowerCase();
        return name.contains(searchQuery);
      }).toList();
    });
  }

  void _showReportDialog(
      BuildContext context, String studentId, String studentName) {
    showDialog(
      context: context,
      builder: (context) => SubmitUserReportDialog(
        userId: studentId,
        userName: studentName,
        userType: 'student',
      ),
    );
  }

  Future<void> showStudentProgressDialog(BuildContext context, String studentId,
      List<Map<String, dynamic>> lecturerCourses) async {
    List<Map<String, dynamic>> courseProgress = [];

    for (var course in lecturerCourses) {
      final courseId = course['id'];
      final courseName = course['name'];
      final studentsList = (course['students'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((student) => student['studentId'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toList();
      if (!studentsList.contains(studentId)) continue;
      int submittedAssessments = 0;
      int totalAssessments = 0;
      int submittedTests = 0;
      int totalTests = 0;

      final modulesSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('modules')
          .get();

      for (var moduleDoc in modulesSnapshot.docs) {
        final moduleData = moduleDoc.data();
        if (moduleData['assessmentsPdfUrl'] != null &&
            (moduleData['assessmentsPdfUrl'] as String).isNotEmpty) {
          totalAssessments++;
        }
        if (moduleData['testSheetPdfUrl'] != null &&
            (moduleData['testSheetPdfUrl'] as String).isNotEmpty) {
          totalTests++;
        }
        final submissionDoc = await moduleDoc.reference
            .collection('submissions')
            .doc(studentId)
            .get();
        if (submissionDoc.exists) {
          final submissionData = submissionDoc.data();
          final submittedAssessmentsArr =
              submissionData?['submittedAssessments'] ?? [];
          for (var assessment in submittedAssessmentsArr) {
            if (assessment['assessmentName'] != null &&
                moduleData['assessmentsPdfUrl'] != null &&
                (moduleData['assessmentsPdfUrl'] as String).isNotEmpty) {
              submittedAssessments++;
            }
            if (assessment['assessmentName'] != null &&
                moduleData['testSheetPdfUrl'] != null &&
                (moduleData['testSheetPdfUrl'] as String).isNotEmpty) {
              submittedTests++;
            }
          }
        }
      }

      courseProgress.add({
        'courseId': courseId,
        'courseName': courseName,
        'submittedAssessments': submittedAssessments,
        'totalAssessments': totalAssessments,
        'submittedTests': submittedTests,
        'totalTests': totalTests,
      });
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Student Progress',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 600,
          height: 500,
          child: FutureBuilder<Map<String, dynamic>>(
            future: _fetchDetailedStudentProgress(studentId, courseProgress),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading results: ${snapshot.error}',
                    style: GoogleFonts.montserrat(color: Colors.red),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.assignment_late,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No results available for this student',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return _buildDetailedResultsContent(snapshot.data!);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.montserrat()),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchLecturerCourses(
      String lecturerId) async {
    final coursesSnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .where('assignedLecturers', isNotEqualTo: null)
        .get();
    return coursesSnapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      if (!data.containsKey('assignedLecturers')) return false;
      final assignedLecturers = data['assignedLecturers'] as List<dynamic>?;
      if (assignedLecturers == null) return false;
      return assignedLecturers.any((lecturer) =>
          lecturer is Map<String, dynamic> &&
          lecturer['id'].toString().trim() == lecturerId.trim());
    }).map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'name': data['courseName'] ?? data['name'] ?? '',
        'students': data['students'] ?? [],
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchLecturerStudents(
      String lecturerId, List<Map<String, dynamic>> lecturerCourses) async {
    final studentIds = lecturerCourses
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
    if (studentIds.isEmpty) return [];
    final studentsSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where(FieldPath.documentId, whereIn: studentIds)
        .get();
    return studentsSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'uid': doc.id,
        'name': data['name'] ?? '',
        'email': data['email'] ?? '',
        'profileImageUrl': data['profileImageUrl'] ?? '',
        'phoneNumber': data['phoneNumber'] ?? '',
        'userType': data['userType'] ?? 'student',
      };
    }).toList();
  }

  Future<Map<String, dynamic>> _fetchDetailedStudentProgress(
      String studentId, List<Map<String, dynamic>> courseProgress) async {
    try {
      final results = <String, dynamic>{
        'courses': <Map<String, dynamic>>[],
      };

      for (final course in courseProgress) {
        final courseName = course['courseName'] as String;
        final courseId = course['courseId'] as String;

        // Create course data structure
        final courseData = {
          'id': courseId,
          'courseName': courseName,
          'overallMark': 'N/A',
          'modules': <Map<String, dynamic>>[],
          'totalAssessments': 0,
          'completedAssessments': 0,
        };

        // Fetch all modules for this course
        final modulesSnapshot = await FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('modules')
            .get();

        double totalMarks = 0;
        int totalAssessments = 0;
        int completedAssessments = 0;

        // Process each module
        for (final moduleDoc in modulesSnapshot.docs) {
          final moduleId = moduleDoc.id;
          final moduleName = moduleDoc.data()['moduleName'] ?? 'Unknown Module';

          // Create module data structure
          final moduleData = {
            'id': moduleId,
            'name': moduleName,
            'completed': false,
            'assessments': <Map<String, dynamic>>[],
          };

          // Fetch student submissions for this module
          final submissionDoc = await FirebaseFirestore.instance
              .collection('courses')
              .doc(courseId)
              .collection('modules')
              .doc(moduleId)
              .collection('submissions')
              .doc(studentId)
              .get();

          if (submissionDoc.exists && submissionDoc.data() != null) {
            final data = submissionDoc.data()!;

            // Process submitted assessments
            final submittedAssessments = List<Map<String, dynamic>>.from(
                data['submittedAssessments'] ?? []);

            for (var assessment in submittedAssessments) {
              final assessmentName =
                  assessment['assessmentName'] ?? 'Unknown Assessment';
              final mark = assessment['mark'];
              final submittedAt = assessment['submittedAt'];

              // Only count graded assessments for the total
              if (mark != null &&
                  (mark is double || (mark is String && mark.isNotEmpty))) {
                double markValue = 0;
                if (mark is double) {
                  markValue = mark;
                } else if (mark is String) {
                  markValue = double.tryParse(mark) ?? 0;
                }

                totalMarks += markValue;
                totalAssessments++;
                completedAssessments++;

                // Add to module's assessments
                if (moduleData['assessments'] == null) {
                  moduleData['assessments'] = <Map<String, dynamic>>[];
                }
                (moduleData['assessments'] as List<Map<String, dynamic>>).add({
                  'name': assessmentName,
                  'mark': '$markValue%',
                  'status': 'Completed',
                  'submittedAt': submittedAt,
                });
              } else {
                // Assessment submitted but not yet graded
                if (moduleData['assessments'] == null) {
                  moduleData['assessments'] = <Map<String, dynamic>>[];
                }
                (moduleData['assessments'] as List<Map<String, dynamic>>).add({
                  'name': assessmentName,
                  'mark': 'Pending',
                  'status': 'Submitted',
                  'submittedAt': submittedAt,
                });
              }
            }

            // Mark module as completed if all assessments are submitted
            if (submittedAssessments.isNotEmpty) {
              moduleData['completed'] = true;
            }
          }

          // Add module to course data
          (courseData['modules'] as List).add(moduleData);
        }

        // Calculate overall mark percentage
        courseData['overallMark'] = totalAssessments > 0
            ? (totalMarks / totalAssessments).toStringAsFixed(1) + '%'
            : 'N/A';

        courseData['totalAssessments'] = totalAssessments;
        courseData['completedAssessments'] = completedAssessments;

        // Add course to results
        results['courses'].add(courseData);
      }

      return results;
    } catch (e) {
      debugPrint('Error fetching detailed student progress: $e');
      return {};
    }
  }

  Widget _buildDetailedResultsContent(Map<String, dynamic> data) {
    final courses = List<Map<String, dynamic>>.from(data['courses'] ?? []);

    if (courses.isEmpty) {
      return Center(
        child: Text(
          'No course data available',
          style: GoogleFonts.montserrat(color: Colors.grey[700]),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: DefaultTabController(
            length: courses.length,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  tabs: courses.map((course) {
                    return Tab(
                      child: Text(
                        course['courseName'],
                        style: GoogleFonts.montserrat(),
                      ),
                    );
                  }).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: courses.map((course) {
                      return _buildCourseResultsContent(course);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseResultsContent(Map<String, dynamic> course) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall mark
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.stars,
                  color: Colors.teal,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Course Mark',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      course['overallMark'],
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[700],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Assessments Completed',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${course['completedAssessments']}/${course['totalAssessments']}',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Module progress
          Text(
            'Module Progress',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              itemCount: course['modules']?.length ?? 0,
              itemBuilder: (context, index) {
                final module = course['modules'][index];
                return ExpansionTile(
                  title: Text(
                    module['name'],
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    module['completed'] ? 'Completed' : 'In Progress',
                    style: GoogleFonts.montserrat(
                      color: module['completed'] ? Colors.green : Colors.orange,
                    ),
                  ),
                  leading: Icon(
                    module['completed'] ? Icons.check_circle : Icons.pending,
                    color: module['completed'] ? Colors.green : Colors.orange,
                  ),
                  children: [
                    ...List.generate(
                      module['assessments']?.length ?? 0,
                      (i) => ListTile(
                        title: Text(
                          module['assessments'][i]['name'],
                          style: GoogleFonts.montserrat(),
                        ),
                        trailing: Text(
                          module['assessments'][i]['mark'],
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: module['assessments'][i]['mark'] != 'N/A' &&
                                    module['assessments'][i]['mark'] !=
                                        'Pending'
                                ? Colors.teal[700]
                                : Colors.grey,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              module['assessments'][i]['status'],
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: module['assessments'][i]['status'] ==
                                        'Completed'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                            if (module['assessments'][i]['submittedAt'] != null)
                              Text(
                                'Submitted: ${_formatTimestamp(module['assessments'][i]['submittedAt'])}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final dt = timestamp.toDate();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return timestamp.toString();
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
          Row(
            children: [
              Container(
                width: 300,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchLecturerCourses(widget.currentUserId ?? ''),
                  builder: (context, lecturerCoursesSnapshot) {
                    if (lecturerCoursesSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const SizedBox();
                    }
                    if (lecturerCoursesSnapshot.hasError) {
                      return const SizedBox();
                    }
                    final lecturerCourses = lecturerCoursesSnapshot.data ?? [];
                    return DropdownButton<String>(
                      value: _selectedCourseId,
                      hint: const Text('Filter by Course'),
                      isExpanded: true,
                      underline: Container(),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Courses'),
                        ),
                        ...lecturerCourses.map((course) {
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
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: MySearchBar(
                  textController: searchStudent,
                  hintText: 'Search Students',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchLecturerCourses(widget.currentUserId ?? ''),
              builder: (context, lecturerCoursesSnapshot) {
                if (lecturerCoursesSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (lecturerCoursesSnapshot.hasError) {
                  return Center(
                      child: Text('Error: ${lecturerCoursesSnapshot.error}'));
                }
                final lecturerCourses = lecturerCoursesSnapshot.data ?? [];
                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchLecturerStudents(
                      widget.currentUserId ?? '', lecturerCourses),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final students = (snapshot.data ?? []).where((student) {
                      final name =
                          (student['name'] ?? '').toString().toLowerCase();
                      final id = student['uid'] ?? '';
                      if (_selectedCourseId != null) {
                        final course = lecturerCourses.firstWhere(
                          (c) => c['id'] == _selectedCourseId,
                          orElse: () => <String, dynamic>{},
                        );
                        if (course.isEmpty) return false;
                        final studentsList =
                            (course['students'] as List<dynamic>? ?? [])
                                .whereType<Map<String, dynamic>>()
                                .map((s) => s['studentId'] as String?)
                                .where((id) => id != null)
                                .cast<String>()
                                .toList();
                        if (!studentsList.contains(id)) return false;
                      }
                      return id != widget.currentUserId &&
                          (searchQuery.isEmpty || name.contains(searchQuery));
                    }).toList();
                    if (students.isEmpty) {
                      return const Center(
                          child: Text('No students match your search'));
                    }
                    return SizedBox(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: LayoutGrid(
                          gridFit: GridFit.loose,
                          columnSizes: List.generate(columns, (index) => 1.fr),
                          rowSizes:
                              List.generate(students.length, (index) => auto),
                          rowGap: 15,
                          columnGap: 8,
                          children: students.map((student) {
                            final studentId = student['uid'] ?? '';
                            final name = student['name'] ?? 'Unknown';
                            final phone = student['phoneNumber'] ?? '';
                            final profileImage =
                                student['profileImageUrl'] ?? '';
                            final userType = student['userType'] ?? 'student';
                            return MemberContainers(
                              image: profileImage.isNotEmpty
                                  ? profileImage
                                  : 'images/person1.png',
                              name: name,
                              number: phone,
                              isLecturer: false,
                              studentAmount: '',
                              onTap: () {
                                if (widget.onStudentSelected != null) {
                                  widget.onStudentSelected!(
                                      studentId, name, userType);
                                }
                              },
                              trailing: IconButton(
                                icon: const Icon(Icons.info_outline,
                                    size: 20, color: Colors.grey),
                                onPressed: () => showStudentProgressDialog(
                                    context, studentId, lecturerCourses),
                                tooltip: 'View Student Progress',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
