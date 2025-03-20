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

  ReviewModule({
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
      return storedPath; // Fallback to original URL if error
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
    final moduleName = currentModule['moduleName'] ?? 'Unknown Module Name';
    final moduleDescription =
        currentModule['moduleDescription'] ?? 'No Description';
    final pdfUrl = currentModule['modulePdfUrl'] ?? '';
    final moduleImageUrl = currentModule['moduleImageUrl'] ?? '';

    final studentGuidePdfUrl = currentModule['studentGuidePdfUrl'] ?? '';
    final facilitatorGuidePdfUrl =
        currentModule['facilitatorGuidePdfUrl'] ?? '';
    final answerSheetPdfUrl = currentModule['answerSheetPdfUrl'] ?? '';
    final activitiesPdfUrl = currentModule['activitiesPdfUrl'] ?? '';
    final assessmentsPdfUrl = currentModule['assessmentsPdfUrl'] ?? '';
    final testSheetPdfUrl = currentModule['testSheetPdfUrl'] ?? '';

    return Material(
      color: Mycolors().offWhite,
      child: SizedBox(
        width: MyUtility(context).width - 280,
        height: MyUtility(context).height - 80,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Mycolors().darkTeal,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: MyUtility(context).height * 0.06,
                    width: MyUtility(context).width,
                    child: Center(
                      child: Text(
                        'Review Module',
                        style: MyTextStyles(context).headerWhite,
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: ContentDevTextfields(
                                inputController:
                                    TextEditingController(text: moduleName),
                                headerText: 'Module Name',
                                keyboardType: '',
                              ),
                            ),
                            Spacer(),
                            SlimButtons(
                              buttonText: 'Assessments',
                              textColor: Mycolors().darkGrey,
                              buttonColor: Colors.white,
                              borderColor: Mycolors().darkGrey,
                              onPressed: () {
                                widget.changePageIndex(5);
                              },
                              customWidth: 125,
                              customHeight: 40,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          moduleImageUrl.isNotEmpty
                              ? ImageNetwork(
                                  image: moduleImageUrl,
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  borderRadius: BorderRadius.circular(10),
                                  fitWeb: BoxFitWeb.cover,
                                  fitAndroidIos: BoxFit.cover,
                                )
                              : Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  decoration: BoxDecoration(
                                    color: Mycolors().offWhite,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 50,
                                      color: Mycolors().darkGrey,
                                    ),
                                  ),
                                ),
                          Spacer(),
                          Column(
                            children: [
                              if (studentGuidePdfUrl.isNotEmpty) ...[
                                _buildViewButton(
                                    'View Student Guide', studentGuidePdfUrl),
                                SizedBox(height: 10),
                              ],
                              if (facilitatorGuidePdfUrl.isNotEmpty) ...[
                                _buildViewButton('View Facilitator Guide',
                                    facilitatorGuidePdfUrl),
                                SizedBox(height: 10),
                              ],
                              if (answerSheetPdfUrl.isNotEmpty) ...[
                                _buildViewButton(
                                    'View Answer Sheet', answerSheetPdfUrl),
                                SizedBox(height: 10),
                              ],
                              if (activitiesPdfUrl.isNotEmpty) ...[
                                _buildViewButton(
                                    'View Activities', activitiesPdfUrl),
                                SizedBox(height: 10),
                              ],
                              if (assessmentsPdfUrl.isNotEmpty) ...[
                                _buildViewButton(
                                    'View Assessments', assessmentsPdfUrl),
                                SizedBox(height: 10),
                              ],
                              if (testSheetPdfUrl.isNotEmpty) ...[
                                _buildViewButton(
                                    'View Test Sheet', testSheetPdfUrl),
                                SizedBox(height: 10),
                              ],
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.82,
                            child: ContentDevTextfields(
                              inputController: TextEditingController(
                                  text: moduleDescription),
                              headerText: 'Module Description',
                              keyboardType: '',
                              maxLines: 9,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      if (pdfUrl.isNotEmpty)
                        SlimButtons(
                          buttonText: 'View Module PDF',
                          buttonColor: Colors.white,
                          borderColor: Mycolors().darkGrey,
                          textColor: Mycolors().darkGrey,
                          onPressed: () async {
                            String freshPdfUrl =
                                await _getFreshPdfUrl(pdfUrl); // Get fresh URL

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  appBar: AppBar(title: Text('View PDF')),
                                  body: PdfViewerWeb(
                                      pdfUrl: freshPdfUrl), // Use fresh URL
                                ),
                              ),
                            );
                          },
                          customWidth: 160,
                          customHeight: 40,
                        ),
                      SizedBox(height: 30),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewButton(String text, String path) {
    return FutureBuilder<String>(
      future: _getFreshPdfUrl(path), // Get fresh URL before opening
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error loading PDF');
        }
        final freshPdfUrl = snapshot.data ?? path; // Use fresh URL

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
                  appBar: AppBar(title: Text(text)), // Show correct title
                  body: PdfViewerWeb(pdfUrl: freshPdfUrl), // Open correct PDF
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
