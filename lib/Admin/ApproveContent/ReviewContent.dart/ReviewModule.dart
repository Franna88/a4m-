import 'package:a4m/Admin/ApproveContent/ReviewContent.dart/pdfViewScreen.dart';
import 'package:a4m/Admin/Dashboard/ui/coursePerformancePieChart.dart';
import 'package:a4m/Admin/Dashboard/ui/monthlySalesChart.dart';
import 'package:a4m/Admin/Dashboard/ui/monthlyStatSumContainers.dart';
import 'package:a4m/CommonComponents/buttons/slimButtons.dart';
import 'package:a4m/CommonComponents/inputFields/contentDevTextfields.dart';
import 'package:a4m/CommonComponents/inputFields/myTextFields.dart';
import 'package:a4m/ContentDev/add_content_popup.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/Themes/text_style.dart';
import 'package:a4m/myutility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';

class ReviewModule extends StatefulWidget {
  final Function(int, [Map<String, dynamic>?]) changePageIndex;
  final String courseId;
  final bool isEdited;

  const ReviewModule({
    super.key,
    required this.changePageIndex,
    required this.courseId,
    required this.isEdited,
  });

  @override
  State<ReviewModule> createState() => _ReviewModuleState();
}

class _ReviewModuleState extends State<ReviewModule> {
  int currentIndex = 0;
  List<DocumentSnapshot> modules = [];

  @override
  void initState() {
    super.initState();
    _fetchModules();
  }

  Future<void> _fetchModules() async {
    try {
      String collectionPath = widget.isEdited ? 'pendingCourses' : 'courses';

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(collectionPath)
          .doc(widget.courseId)
          .collection('modules')
          .get();

      if (snapshot.docs.isEmpty) {
        print(
            "⚠️ No modules found in $collectionPath/${widget.courseId}/modules");
      } else {
        print(
            "✅ Loaded ${snapshot.docs.length} modules from $collectionPath/${widget.courseId}/modules");
      }

      setState(() {
        modules = snapshot.docs;
      });
    } catch (e) {
      print("❌ Error fetching modules: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch modules: $e')),
      );
    }
  }

  Future<String> _getFreshPdfUrl(String storedPath) async {
    try {
      if (storedPath.isEmpty) return '';

      final ref = FirebaseStorage.instance.ref(
          storedPath.contains('module_pdfs')
              ? storedPath
              : 'module_pdfs/$storedPath');

      final freshUrl = await ref.getDownloadURL();
      print("🔄 Fresh Firebase PDF URL: $freshUrl");
      return freshUrl;
    } catch (e) {
      print("❌ Error fetching fresh PDF URL: $e");
      return storedPath;
    }
  }

  void _navigateToNextModule() {
    if (currentIndex < modules.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void _navigateToPreviousModule() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    } else {
      _navigateBackToCourseReview();
    }
  }

  void _navigateBackToCourseReview() {
    widget.changePageIndex(
        9, {'courseId': widget.courseId, 'isEdited': widget.isEdited});
  }

  @override
  Widget build(BuildContext context) {
    if (modules.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    final currentModule = modules[currentIndex];
    final moduleData = currentModule.data() as Map<String, dynamic>;

    final moduleName = moduleData['moduleName'] ?? 'Unknown Module Name';
    final moduleDescription =
        moduleData['moduleDescription'] ?? 'No Description';
    final moduleImageUrl = moduleData['moduleImageUrl'] ?? '';

    // Get all PDF URLs with null safety
    final modulePdfUrl = moduleData['modulePdfUrl'] ?? '';
    final studentGuidePdfUrl = moduleData['studentGuidePdfUrl'] ?? '';
    final facilitatorGuidePdfUrl = moduleData['facilitatorGuidePdfUrl'] ?? '';
    final lecturerGuidePdfUrl = moduleData['lecturerGuidePdfUrl'] ?? '';
    final answerSheetPdfUrl = moduleData['answerSheetPdfUrl'] ?? '';
    final activitiesPdfUrl = moduleData['activitiesPdfUrl'] ?? '';
    final assessmentsPdfUrl = moduleData['assessmentsPdfUrl'] ?? '';
    final testSheetPdfUrl = moduleData['testSheetPdfUrl'] ?? '';
    final assignmentsPdfUrl = moduleData['assignmentsPdfUrl'] ?? '';
    final indexPdfUrl = moduleData['indexPdfUrl'] ?? '';

    return Material(
      color: Mycolors().offWhite,
      child: SizedBox(
        width: MyUtility(context).width - 280,
        height: MyUtility(context).height - 80,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Modern Header with gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Mycolors().darkTeal, Mycolors().blue],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                height: MyUtility(context).height * 0.08,
                width: MyUtility(context).width,
                child: Center(
                  child: Text(
                    'Review Module',
                    style: MyTextStyles(context).headerWhite.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Main Content Card
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Module Navigation and Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Module ${currentIndex + 1} of ${modules.length}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Mycolors().darkGrey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        // Module Name
                        ContentDevTextfields(
                          inputController:
                              TextEditingController(text: moduleName),
                          headerText: 'Module Name',
                          keyboardType: '',
                          readOnly: true,
                        ),
                        SizedBox(height: 30),
                        // Module Content Section
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Module Image
                            Flexible(
                              flex: 2,
                              child: Container(
                                height: 250,
                                decoration: BoxDecoration(
                                  color: Mycolors().offWhite,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                ),
                                child: moduleImageUrl.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: ImageNetwork(
                                          image: moduleImageUrl,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          height: 250,
                                          fitWeb: BoxFitWeb.cover,
                                          fitAndroidIos: BoxFit.cover,
                                          onLoading: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          onError: Icon(
                                            Icons.error_outline,
                                            color: Colors.red,
                                            size: 50,
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 50,
                                          color: Mycolors().darkGrey,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(width: 30),
                            // PDF Documents Section
                            Flexible(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Module Documents',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Mycolors().darkGrey,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      if (studentGuidePdfUrl.isNotEmpty)
                                        _buildViewButton('View Student Guide',
                                            studentGuidePdfUrl),
                                      if (facilitatorGuidePdfUrl.isNotEmpty)
                                        _buildViewButton(
                                            'View Facilitator Guide',
                                            facilitatorGuidePdfUrl),
                                      if (lecturerGuidePdfUrl.isNotEmpty)
                                        _buildViewButton('View Lecturer Guide',
                                            lecturerGuidePdfUrl),
                                      if (answerSheetPdfUrl.isNotEmpty)
                                        _buildViewButton('View Answer Sheet',
                                            answerSheetPdfUrl),
                                      if (activitiesPdfUrl.isNotEmpty)
                                        _buildViewButton('View Activities',
                                            activitiesPdfUrl),
                                      if (assessmentsPdfUrl.isNotEmpty)
                                        _buildViewButton('View Assessments',
                                            assessmentsPdfUrl),
                                      if (testSheetPdfUrl.isNotEmpty)
                                        _buildViewButton(
                                            'View Test Sheet', testSheetPdfUrl),
                                      if (assignmentsPdfUrl.isNotEmpty)
                                        _buildViewButton('View Assignments',
                                            assignmentsPdfUrl),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  if (indexPdfUrl.isNotEmpty)
                                    _buildViewButton(
                                        'View Index PDF', indexPdfUrl),
                                  if (modulePdfUrl.isNotEmpty)
                                    _buildViewButton(
                                        'View Module PDF', modulePdfUrl),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        // Module Description
                        ContentDevTextfields(
                          headerText: 'Module Description',
                          inputController:
                              TextEditingController(text: moduleDescription),
                          keyboardType: '',
                          maxLines: 9,
                          readOnly: true,
                        ),
                        SizedBox(height: 30),
                        // Navigation Buttons Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (currentIndex == 0)
                              SlimButtons(
                                buttonText: 'Back to Course Review',
                                buttonColor: Colors.white,
                                borderColor: Mycolors().darkGrey,
                                textColor: Mycolors().darkGrey,
                                onPressed: _navigateBackToCourseReview,
                                customWidth: 180,
                                customHeight: 40,
                              )
                            else
                              SlimButtons(
                                buttonText: 'Previous Module',
                                buttonColor: Colors.white,
                                borderColor: Mycolors().darkGrey,
                                textColor: Mycolors().darkGrey,
                                onPressed: _navigateToPreviousModule,
                                customWidth: 150,
                                customHeight: 40,
                              ),
                            Text(
                              '${currentIndex + 1} / ${modules.length}',
                              style: MyTextStyles(context).mediumBlack,
                            ),
                            SlimButtons(
                              buttonText: 'Next Module',
                              buttonColor: Colors.white,
                              borderColor: Mycolors().darkGrey,
                              textColor: Mycolors().darkGrey,
                              onPressed: _navigateToNextModule,
                              customWidth: 150,
                              customHeight: 40,
                            ),
                          ],
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
    );
  }

  Widget _buildViewButton(String text, String path) {
    return FutureBuilder<String>(
      future: _getFreshPdfUrl(path),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error loading PDF');
        }
        final freshPdfUrl = snapshot.data ?? path;

        return SlimButtons(
          buttonText: text,
          buttonColor: Colors.white,
          borderColor: Mycolors().darkGrey,
          textColor: Mycolors().darkGrey,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text(text)),
                  body: PdfViewerWeb(pdfUrl: freshPdfUrl),
                ),
              ),
            );
          },
          customWidth: 180,
          customHeight: 40,
        );
      },
    );
  }
}
