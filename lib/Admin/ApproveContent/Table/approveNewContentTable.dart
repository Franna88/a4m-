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
          : FirebaseFirestore.instance
              .collection('courses')
              .where('status', isEqualTo: widget.status)
              .snapshots(),
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
                      widget.status == 'removed' ? 'Restore' : 'Approve',
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
                                'isEdited': isEdited,
                              });
                            },
                            customWidth: 100,
                          ),
                          if (widget.status != 'removed')
                            Row(
                              children: [
                                const SizedBox(
                                    width: 10), // Space between buttons
                                IconButton(
                                  icon: Icon(Icons.info, color: Colors.blue),
                                  onPressed: () {
                                    _showChangesDialog(context,
                                        course.data() as Map<String, dynamic>);
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Approve/Decline/Restore Buttons
                  TableCell(
                    child: TableStructure(
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 350),
                        child: widget.status == 'approved'
                            ? Container(
                                width: 350,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 100,
                                      child: SlimButtons(
                                        buttonText: 'Remove',
                                        buttonColor: Mycolors().red,
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text('Remove Course'),
                                              content: Text(
                                                  'Are you sure you want to remove "${data['courseName']}"?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    try {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('courses')
                                                          .doc(course.id)
                                                          .update({
                                                        'status': 'removed',
                                                        'removedAt': FieldValue
                                                            .serverTimestamp(),
                                                        'removedBy': 'admin'
                                                      });
                                                      Navigator.pop(context);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                            content: Text(
                                                                'Course removed successfully')),
                                                      );
                                                    } catch (e) {
                                                      print(
                                                          'Error removing course: $e');
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                            content: Text(
                                                                'Error removing course')),
                                                      );
                                                    }
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Mycolors().red,
                                                  ),
                                                  child: Text('Remove'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        customWidth: 100,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Container(
                                      width: 100,
                                      alignment: Alignment.center,
                                      child: Text(
                                        (data['isUpdated'] == true)
                                            ? 'Updated'
                                            : '',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : widget.status == 'declined'
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        child: SlimButtons(
                                          buttonText: 'View Reason',
                                          buttonColor: Mycolors().peach,
                                          onPressed: () {
                                            _showDeclineReasonDialog(
                                                context, data);
                                          },
                                          customWidth: 100,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 100,
                                        child: SlimButtons(
                                          buttonText: 'Restore',
                                          buttonColor: Mycolors().blue,
                                          onPressed: () {
                                            _restoreCourse(course.id);
                                          },
                                          customWidth: 100,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (widget.status == 'removed')
                                        SizedBox(
                                          width: 100,
                                          child: SlimButtons(
                                            buttonText: 'Restore',
                                            buttonColor: Mycolors().blue,
                                            onPressed: () {
                                              _restoreCourse(course.id);
                                            },
                                            customWidth: 100,
                                          ),
                                        )
                                      else if (widget.status ==
                                              'pending_approval' ||
                                          isEdited)
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 100,
                                              child: SlimButtons(
                                                buttonText: 'Approve',
                                                buttonColor: Mycolors().blue,
                                                onPressed: () {
                                                  _approveCourse(
                                                      course.id, isEdited);
                                                },
                                                customWidth: 100,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            SizedBox(
                                              width: 100,
                                              child: SlimButtons(
                                                buttonText: 'Decline',
                                                buttonColor: Mycolors().red,
                                                onPressed: () {
                                                  _declineCourse(
                                                      course.id, isEdited);
                                                },
                                                customWidth: 100,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                      ),
                    ),
                  ),
                ],
              );
            }),
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
    // Show dialog to get decline reason
    final TextEditingController reasonController = TextEditingController();

    bool? dialogResult = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Decline Course',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please provide a reason for declining this course:',
                style: GoogleFonts.montserrat(),
              ),
              SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: 'Enter reason for declining...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Please provide a reason for declining')),
                  );
                  return;
                }
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors().red,
              ),
              child: Text('Decline'),
            ),
          ],
        );
      },
    );

    // If user canceled or didn't provide a reason, return
    if (dialogResult != true || reasonController.text.trim().isEmpty) {
      return;
    }

    String declineReason = reasonController.text.trim();

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      if (isEdited) {
        // For edited courses, mark them as declined in pendingCourses
        await firestore.collection('pendingCourses').doc(courseId).update({
          'status': 'declined',
          'declineReason': declineReason,
          'declinedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // For new courses, mark them as declined in the courses collection
        await firestore.collection('courses').doc(courseId).update({
          'status': 'declined',
          'declineReason': declineReason,
          'declinedAt': FieldValue.serverTimestamp(),
        });
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

  Future<void> _restoreCourse(String courseId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Update the course status to 'approved' and remove the removedAt timestamp
      await firestore.collection('courses').doc(courseId).update({
        'status': 'approved',
        'removedAt': FieldValue.delete(),
        'removedBy': FieldValue.delete(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course restored successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to restore course: $e')),
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
                ...courseChanges.map((change) => Text("- $change"))
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

void _showDeclineReasonDialog(BuildContext context, Map<String, dynamic> data) {
  String declineReason = data['declineReason'] ?? 'No reason provided';
  String declinedAt = 'Unknown date';
  String removedAt = 'Unknown date';
  String removedBy = data['removedBy'] ?? 'Unknown';

  if (data['declinedAt'] != null) {
    Timestamp timestamp = data['declinedAt'];
    declinedAt = DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate());
  }

  if (data['removedAt'] != null) {
    Timestamp timestamp = data['removedAt'];
    removedAt = DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate());
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          data['status'] == 'removed'
              ? "Removal Information"
              : "Decline Reason",
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (data['status'] == 'declined') ...[
                Text(
                  "Declined on: $declinedAt",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Reason:",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    declineReason,
                    style: GoogleFonts.montserrat(),
                  ),
                ),
              ] else if (data['status'] == 'removed') ...[
                Text(
                  "Removed on: $removedAt",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Removed by: $removedBy",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
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
