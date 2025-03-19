import 'package:a4m/CommonComponents/buttons/slimButtons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/TableWidgets/tableStructure.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ApproveNewContentTable extends StatefulWidget {
  final Function(int, [Map<String, dynamic>?]) changePage;
  final String status;

  const ApproveNewContentTable({
    super.key,
    required this.changePage,
    required this.status,
  });

  @override
  State<ApproveNewContentTable> createState() => _ApproveNewContentTableState();
}

class _ApproveNewContentTableState extends State<ApproveNewContentTable> {
  @override
  Widget build(BuildContext context) {
    // If the status is 'pending', we treat it as "updated courses"
    // that live in the pendingCourses collection.
    bool isEdited = (widget.status == 'pending');

    return StreamBuilder<QuerySnapshot>(
      stream: isEdited
          ? FirebaseFirestore.instance
              .collection('pendingCourses')
              .where('status', isEqualTo: widget.status)
              .snapshots()
          : FirebaseFirestore.instance.collection('courses').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading data'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No Course available'));
        }

        final List<DocumentSnapshot> courses = snapshot.data!.docs;

        return Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            // Table Header
            TableRow(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                color: Mycolors().green,
                border: const Border(
                  bottom: BorderSide(color: Colors.black),
                ),
              ),
              children: [
                TableCell(
                  child: TableStructure(
                    child: Text(
                      'Course/Module Name',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                TableCell(
                  child: TableStructure(
                    child: Text(
                      'Date',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                TableCell(
                  child: TableStructure(
                    child: Text(
                      'Review',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                TableCell(
                  child: TableStructure(
                    child: Text(
                      'Approve',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Build rows for each course document
            ...courses.map((course) {
              final data = course.data() as Map<String, dynamic>;

              // For "updated" (here called 'pending') courses, we might have 'editedAt'.
              final timestamp = (data.containsKey('editedAt') &&
                      data['editedAt'] != null)
                  ? data['editedAt']
                  : (data.containsKey('createdAt') ? data['createdAt'] : null);

              final createdAt = timestamp != null
                  ? DateFormat('yyyy-MM-dd')
                      .format((timestamp as Timestamp).toDate())
                  : 'Unknown Date';

              final courseName = data['courseName'] ?? 'Unknown';

              return TableRow(
                decoration: BoxDecoration(
                  color: courses.indexOf(course) % 2 == 1
                      ? Colors.white
                      : const Color.fromRGBO(209, 210, 146, 0.50),
                  border: const Border(
                    bottom: BorderSide(width: 1, color: Colors.black),
                  ),
                ),
                children: [
                  // Course/Module Name
                  TableCell(
                    child: TableStructure(
                      child: Text(
                        courseName,
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  // Date Column
                  TableCell(
                    child: TableStructure(
                      child: Text(
                        createdAt,
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  // Review Button
                  TableCell(
                    child: TableStructure(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SlimButtons(
                            buttonText: 'View',
                            buttonColor: Mycolors().peach,
                            onPressed: () {
                              widget.changePage(9, {
                                'courseId': course.id,
                                'isEdited': true,
                              });
                            },
                            customWidth: 100,
                          ),
                          const SizedBox(width: 10), // Space between buttons
                          IconButton(
                            icon: Icon(Icons.info, color: Colors.blue),
                            onPressed: () {
                              _showChangesDialog(context,
                                  course.data() as Map<String, dynamic>);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Approve/Decline Buttons
                  TableCell(
                    child: TableStructure(
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 350),
                        child: (widget.status ==
                                'approved') // Check if the course is approved
                            ? Center(
                                child: Text(
                                  (data['isUpdated'] == true) ? 'Updated' : '',
                                  style: GoogleFonts.montserrat(
                                    color:
                                        Colors.red, // Highlight updated courses
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Show Approve/Decline only if it's 'pending' (edited) or 'pending_approval'
                                  if (widget.status == 'pending_approval' ||
                                      isEdited)
                                    SizedBox(
                                      width: 100,
                                      child: SlimButtons(
                                        buttonText: 'Approve',
                                        buttonColor: Mycolors().blue,
                                        onPressed: () {
                                          _approveCourse(course.id, isEdited);
                                        },
                                        customWidth: 100,
                                      ),
                                    ),
                                  if (widget.status == 'pending_approval' ||
                                      isEdited)
                                    const SizedBox(width: 8),
                                  if (widget.status == 'pending_approval' ||
                                      isEdited)
                                    SizedBox(
                                      width: 100,
                                      child: SlimButtons(
                                        buttonText: 'Decline',
                                        buttonColor: Mycolors().red,
                                        onPressed: () {
                                          _declineCourse(course.id, isEdited);
                                        },
                                        customWidth: 100,
                                      ),
                                    ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Future<void> _approveCourse(String courseId, bool isEdited) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      if (isEdited) {
        // Handling an updated course (migrating from pendingCourses)
        DocumentSnapshot pendingDoc =
            await firestore.collection('pendingCourses').doc(courseId).get();

        Map<String, dynamic>? updatedData =
            pendingDoc.data() as Map<String, dynamic>?;

        if (updatedData != null) {
          updatedData['status'] = 'approved'; // Mark as approved
          updatedData['isUpdated'] = true; // Mark as updated

          // Step 1: Move course data to the live `courses/` collection
          await firestore
              .collection('courses')
              .doc(courseId)
              .set(updatedData, SetOptions(merge: true));

          // Step 2: Fetch all modules from `pendingCourses/{courseId}/modules`
          QuerySnapshot pendingModules = await firestore
              .collection('pendingCourses')
              .doc(courseId)
              .collection('modules')
              .get();

          // Step 3: Loop through each pending module
          for (var module in pendingModules.docs) {
            String moduleId = module.id; // Keep the original module ID
            Map<String, dynamic> moduleData =
                module.data() as Map<String, dynamic>;

            // Check if the module already exists in `courses/{courseId}/modules`
            DocumentSnapshot existingModule = await firestore
                .collection('courses')
                .doc(courseId)
                .collection('modules')
                .doc(moduleId)
                .get();

            if (existingModule.exists) {
              // If module exists, merge the new changes
              await firestore
                  .collection('courses')
                  .doc(courseId)
                  .collection('modules')
                  .doc(moduleId)
                  .set(moduleData, SetOptions(merge: true));
            } else {
              // If module does not exist, add it as a new one
              await firestore
                  .collection('courses')
                  .doc(courseId)
                  .collection('modules')
                  .doc(moduleId)
                  .set(moduleData);
            }
          }

          // Step 4: Delete the pending course and its modules
          for (var module in pendingModules.docs) {
            await firestore
                .collection('pendingCourses')
                .doc(courseId)
                .collection('modules')
                .doc(module.id)
                .delete();
          }

          await firestore.collection('pendingCourses').doc(courseId).delete();
          print("✅ Approved and moved updated course & modules to `courses/`.");
        } else {
          throw Exception("Failed to retrieve pending course data.");
        }
      } else {
        // Handling a new course approval (migrating from pendingCourses)
        DocumentSnapshot newCourseDoc =
            await firestore.collection('pendingCourses').doc(courseId).get();

        Map<String, dynamic>? newCourseData =
            newCourseDoc.data() as Map<String, dynamic>?;

        if (newCourseData != null) {
          newCourseData['status'] = 'approved'; // Mark as approved
          newCourseData['isUpdated'] = false; // Mark as NOT updated

          // Step 1: Move new course data to `courses/`
          await firestore
              .collection('courses')
              .doc(courseId)
              .set(newCourseData, SetOptions(merge: true));

          // Step 2: Fetch modules if they exist
          QuerySnapshot newModules = await firestore
              .collection('pendingCourses')
              .doc(courseId)
              .collection('modules')
              .get();

          // Step 3: Move modules to `courses/{courseId}/modules`
          for (var module in newModules.docs) {
            String moduleId = module.id; // Keep original module ID
            Map<String, dynamic> moduleData =
                module.data() as Map<String, dynamic>;

            // Ensure the module does not already exist before adding
            DocumentSnapshot existingModule = await firestore
                .collection('courses')
                .doc(courseId)
                .collection('modules')
                .doc(moduleId)
                .get();

            if (existingModule.exists) {
              await firestore
                  .collection('courses')
                  .doc(courseId)
                  .collection('modules')
                  .doc(moduleId)
                  .set(moduleData, SetOptions(merge: true));
            } else {
              await firestore
                  .collection('courses')
                  .doc(courseId)
                  .collection('modules')
                  .doc(moduleId)
                  .set(moduleData);
            }
          }

          // Step 4: Delete from pendingCourses
          for (var module in newModules.docs) {
            await firestore
                .collection('pendingCourses')
                .doc(courseId)
                .collection('modules')
                .doc(module.id)
                .delete();
          }

          await firestore.collection('pendingCourses').doc(courseId).delete();
          print("✅ Approved and moved new course & modules to `courses/`.");
        } else {
          // If it's already in `courses/`, just update status
          await firestore
              .collection('courses')
              .doc(courseId)
              .update({'status': 'approved', 'isUpdated': false});
          print("✅ Course was already live; status updated to 'approved'.");
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course approved successfully!')),
      );
    } catch (e) {
      print("❌ Error approving course: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve course: $e')),
      );
    }
  }

  Future<void> _declineCourse(String courseId, bool isEdited) async {
    try {
      if (isEdited) {
        // Remove the doc from pendingCourses
        await FirebaseFirestore.instance
            .collection('pendingCourses')
            .doc(courseId)
            .delete();
      } else {
        // For non-edited courses, mark them 'declined' in the courses collection
        await FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .update({'status': 'declined'});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course declined successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to decline course: $e')),
      );
    }
  }
}

void _showChangesDialog(BuildContext context, Map<String, dynamic> data) {
  List<dynamic>? courseChanges = data['changes'];
  List<dynamic>? moduleChanges = data['moduleChanges'];

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Changes Overview"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Course Changes:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              if (courseChanges != null && courseChanges.isNotEmpty)
                ...courseChanges.map((change) => Text("- $change")).toList()
              else
                Text("No course changes."),
              SizedBox(height: 10),
              Text("Module Changes:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              if (moduleChanges != null && moduleChanges.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: moduleChanges.map((module) {
                    List<String> changes =
                        List<String>.from(module['changes'] ?? []);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Module: ${module['moduleName'] ?? 'Unknown'}",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        if (changes.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: changes
                                .map((change) => Text("  - $change"))
                                .toList(),
                          )
                        else
                          Text("  No changes."),
                        SizedBox(height: 8),
                      ],
                    );
                  }).toList(),
                )
              else
                Text("No module changes."),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      );
    },
  );
}
