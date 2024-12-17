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
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_network/image_network.dart';

class ReviewModule extends StatefulWidget {
  final Function(int, [Map<String, dynamic>?]) changePageIndex;
  final String courseId;

  ReviewModule({
    super.key,
    required this.changePageIndex,
    required this.courseId,
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
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .get();

      setState(() {
        modules = snapshot.docs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch modules: $e')),
      );
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
    widget.changePageIndex(9, {'courseId': widget.courseId});
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
                                _buildDownloadButton('Download Student Guide',
                                    studentGuidePdfUrl),
                                SizedBox(height: 10),
                              ],
                              if (facilitatorGuidePdfUrl.isNotEmpty) ...[
                                _buildDownloadButton(
                                    'Download Facilitator Guide',
                                    facilitatorGuidePdfUrl),
                                SizedBox(height: 10),
                              ],
                              if (answerSheetPdfUrl.isNotEmpty) ...[
                                _buildDownloadButton(
                                    'Download Answer Sheet', answerSheetPdfUrl),
                                SizedBox(height: 10),
                              ],
                              if (activitiesPdfUrl.isNotEmpty) ...[
                                _buildDownloadButton(
                                    'Download Activities', activitiesPdfUrl),
                                SizedBox(height: 10),
                              ],
                              if (assessmentsPdfUrl.isNotEmpty) ...[
                                _buildDownloadButton(
                                    'Download Assessments', assessmentsPdfUrl),
                                SizedBox(height: 10),
                              ],
                              if (testSheetPdfUrl.isNotEmpty) ...[
                                _buildDownloadButton(
                                    'Download Test Sheet', testSheetPdfUrl),
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
                          buttonText: 'Download Module PDF',
                          buttonColor: Colors.white,
                          borderColor: Mycolors().darkGrey,
                          textColor: Mycolors().darkGrey,
                          onPressed: () async {
                            final Uri pdfUri = Uri.parse(pdfUrl);
                            if (await canLaunchUrl(pdfUri)) {
                              await launchUrl(pdfUri);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Could not launch PDF download link')),
                              );
                            }
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

  Widget _buildDownloadButton(String text, String url) {
    return SlimButtons(
      buttonText: text,
      buttonColor: Colors.white,
      borderColor: Mycolors().darkGrey,
      textColor: Mycolors().darkGrey,
      onPressed: () async {
        final Uri pdfUri = Uri.parse(url);
        if (await canLaunchUrl(pdfUri)) {
          await launchUrl(pdfUri);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch $text link')),
          );
        }
      },
      customWidth: 180,
      customHeight: 40,
    );
  }
}
