import 'package:a4m/CommonComponents/displayCardIcons.dart';
import 'package:a4m/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';
import 'dart:html' as html;
import 'dart:js' as js;

class DevelopedCourseEdit extends StatefulWidget {
  final String courseName;
  final String modulesComplete;
  final String courseDescription;
  final String totalStudents;
  final String moduleAmount;
  final String assessmentAmount;
  final String courseImage;
  final Function() onTap;
  final Function(int) changePage;
  final String? courseStatus;
  final String? declineReason;
  final String? previewPdfUrl;
  const DevelopedCourseEdit(
      {super.key,
      required this.courseName,
      required this.modulesComplete,
      required this.courseDescription,
      required this.totalStudents,
      required this.moduleAmount,
      required this.assessmentAmount,
      required this.courseImage,
      required this.onTap,
      required this.changePage,
      this.courseStatus,
      this.declineReason,
      this.previewPdfUrl});

  @override
  State<DevelopedCourseEdit> createState() => _DevelopedCourseEditState();
}

class _DevelopedCourseEditState extends State<DevelopedCourseEdit> {
  var pageIndex = 0;

  void changePage(int index) {
    setState(() {
      pageIndex = index;
    });
    changePage(5);
  }

  void _handleEditNavigation() {
    widget.changePage(2);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(15),
      elevation: 5,
      child: Container(
        height: 340,
        width: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main clickable area (image, title, description, decline reason)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _handleEditNavigation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 320,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        child: Stack(
                          children: [
                            // Background Image using ImageNetwork
                            Positioned.fill(
                              child: ImageNetwork(
                                image: widget.courseImage,
                                fitWeb: BoxFitWeb.cover,
                                fitAndroidIos: BoxFit.cover,
                                height: 180,
                                width: 320,
                                duration: 500,
                                onLoading: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                            // Gradient Overlay
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Mycolors().green,
                                      const Color.fromARGB(0, 255, 255, 255),
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: widget.previewPdfUrl != null &&
                                              widget.previewPdfUrl!.isNotEmpty
                                          ? IconButton(
                                              icon: Icon(
                                                Icons.info_outline,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                              onPressed: () {
                                                _showPreviewPdfDialog(context);
                                              },
                                            )
                                          : SizedBox
                                              .shrink(), // Hide if no preview PDF
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Status Badge
                            if (widget.courseStatus != null)
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        _getStatusColor(widget.courseStatus!),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getStatusText(widget.courseStatus!),
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.courseName,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 8, right: 5, bottom: 5),
                      child: Text(
                        widget.courseDescription,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    // Decline Reason (if course is declined)
                    if (widget.courseStatus == 'declined' &&
                        widget.declineReason != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: InkWell(
                          onTap: () {
                            _showDeclineReasonDialog(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: Colors.red.shade700, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Course Declined - Tap to view reason',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: 300,
                height: 2,
                color: const Color.fromARGB(255, 189, 189, 189),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: DisplayCardIcons(
                      icon: Icons.person_outline,
                      count: widget.totalStudents,
                      tooltipText: 'Students'),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: DisplayCardIcons(
                      icon: Icons.format_list_numbered,
                      count: widget.assessmentAmount,
                      tooltipText: 'Assessments'),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: DisplayCardIcons(
                      icon: Icons.library_books,
                      count: widget.moduleAmount,
                      tooltipText: 'Modules'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending_approval':
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'removed':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  // Helper method to get status text
  String _getStatusText(String status) {
    switch (status) {
      case 'pending_approval':
        return 'Pending';
      case 'pending':
        return 'Updated';
      case 'approved':
        return 'Approved';
      case 'declined':
        return 'Declined';
      case 'removed':
        return 'Removed';
      default:
        return status;
    }
  }

  // Show decline reason dialog
  void _showDeclineReasonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Decline Reason",
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    widget.declineReason!,
                    style: GoogleFonts.montserrat(),
                  ),
                ),
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

  // Show preview PDF in a small popup
  void _showPreviewPdfDialog(BuildContext context) {
    if (widget.previewPdfUrl == null || widget.previewPdfUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No preview PDF available for this course')));
      return;
    }

    // Create popup dimensions similar to the course card
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final popupWidth = 350; // Slightly wider than course card
    final popupHeight = 450; // Taller to fit PDF content

    // Calculate centered position
    final left = (screenWidth / 2) - (popupWidth / 2);
    final top = (screenHeight / 2) - (popupHeight / 2);

    // Open popup with Google Docs PDF viewer
    final url =
        'https://docs.google.com/viewer?embedded=true&url=${Uri.encodeComponent(widget.previewPdfUrl!)}';
    final features =
        'width=$popupWidth,height=$popupHeight,top=$top,left=$left,location=no,menubar=no,toolbar=no,status=no,scrollbars=yes,resizable=yes';
    js.context.callMethod('open', [url, 'PDF Preview', features]);
  }
}
