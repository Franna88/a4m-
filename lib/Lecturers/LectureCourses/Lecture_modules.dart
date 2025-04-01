import 'package:a4m/Lecturers/LectureCourses/Lecture_display_Module.dart';
import 'package:a4m/CommonComponents/inputFields/mySearchBar.dart';
import 'package:a4m/Lecturers/commonUi/lecturerPdfViewer.dart';
import 'package:a4m/Lecturers/LectureCourses/module_complete_list.dart';
import 'package:a4m/myutility.dart';
import 'package:a4m/Constants/myColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a4m/CommonComponents/displayCardIcons.dart';
import 'package:a4m/Lecturers/LectureCourses/view_modules_complete.dart';
import 'package:image_network/image_network.dart';

class LectureModulesContainer extends StatefulWidget {
  final Function(int, {String courseId, String moduleId}) changePage;
  final String courseId;

  const LectureModulesContainer({
    super.key,
    required this.changePage,
    required this.courseId,
  });

  @override
  State<LectureModulesContainer> createState() =>
      _LectureModulesContainerState();
}

class _LectureModulesContainerState extends State<LectureModulesContainer> {
  List<Map<String, dynamic>> modules = [];
  List<Map<String, dynamic>> filteredModules = [];
  bool isLoading = true;
  String? selectedPdfUrl;
  String? selectedPdfTitle;
  String searchQuery = '';
  String selectedFilter = 'All';
  bool showModuleCompleteList = false;
  String? selectedModuleId;
  String? selectedModuleName;

  final List<String> filterOptions = [
    'All',
    'With Activities',
    'With Assessments',
    'With Tests',
    'With Answers',
  ];

  // Fetch modules dynamically from Firestore
  Future<void> fetchModules() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .get();

      modules = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      _applyFilters();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching modules: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _applyFilters() {
    filteredModules = modules.where((module) {
      // Apply search filter
      final nameMatches = module['moduleName']
              ?.toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ??
          false;
      final descriptionMatches = module['moduleDescription']
              ?.toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ??
          false;

      if (!nameMatches && !descriptionMatches) return false;

      // Apply category filter
      switch (selectedFilter) {
        case 'With Activities':
          return module['activitiesPdfUrl'] != null &&
              module['activitiesPdfUrl'].toString().isNotEmpty;
        case 'With Assessments':
          return module['assessmentsPdfUrl'] != null &&
              module['assessmentsPdfUrl'].toString().isNotEmpty;
        case 'With Tests':
          return module['testSheetPdfUrl'] != null &&
              module['testSheetPdfUrl'].toString().isNotEmpty;
        case 'With Answers':
          return module['answerSheetPdfUrl'] != null &&
              module['answerSheetPdfUrl'].toString().isNotEmpty;
        default:
          return true;
      }
    }).toList();

    setState(() {});
  }

  void _openPdf(String url, String title) {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No PDF available for $title',
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(
              title,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Mycolors().darkGrey,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: LecturerPdfViewer(
            pdfUrl: url,
            title: title,
            showDownloadButton: !title.toLowerCase().contains('activities'),
          ),
        ),
      ),
    );
  }

  void _showAssessmentMarking(String moduleId, String moduleName) {
    print("Opening assessment marking for module: $moduleId");
    if (moduleId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: Module ID is missing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewModulesComplete(
          courseId: widget.courseId,
          moduleId: moduleId,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchModules();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth ~/ 400).clamp(1, 6);

    if (showModuleCompleteList && selectedModuleId != null) {
      return Container(
        width: MyUtility(context).width - 320,
        height: MyUtility(context).height - 80,
        child: Column(
          children: [
            // Header with back button
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        showModuleCompleteList = false;
                        selectedModuleId = null;
                        selectedModuleName = null;
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Assessment Submissions - ${selectedModuleName ?? ""}',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Module Complete List
            Expanded(
              child: ModuleCompleteList(
                courseId: widget.courseId,
                moduleId: selectedModuleId!,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: MyUtility(context).width - 320,
      height: MyUtility(context).height - 80,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search and Filter Row
            Row(
              children: [
                // Search Bar
                Expanded(
                  flex: 2,
                  child: MySearchBar(
                    textController: TextEditingController(text: searchQuery),
                    hintText: 'Search modules by name or description',
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                        _applyFilters();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Filter Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButton<String>(
                    value: selectedFilter,
                    items: filterOptions.map((String filter) {
                      return DropdownMenuItem<String>(
                        value: filter,
                        child: Text(
                          filter,
                          style: GoogleFonts.montserrat(),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedFilter = newValue;
                          _applyFilters();
                        });
                      }
                    },
                    style: GoogleFonts.montserrat(),
                    underline: Container(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Results Count
            Text(
              '${filteredModules.length} modules found',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            // Modules Grid
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredModules.isEmpty
                      ? Center(
                          child: Text(
                            'No modules found matching your criteria',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : LayoutGrid(
                          columnGap: 20,
                          rowGap: 20,
                          columnSizes: List.generate(
                            crossAxisCount,
                            (_) => 1.fr,
                          ),
                          rowSizes: List.generate(
                            (filteredModules.length / crossAxisCount).ceil(),
                            (_) => auto,
                          ),
                          children: [
                            for (var module in filteredModules)
                              SizedBox(
                                width: 320,
                                height: 340,
                                child: LectureDisplayModule(
                                  courseName: module['moduleName'] ?? 'No Name',
                                  modulesComplete: '3',
                                  courseDescription:
                                      module['moduleDescription'] ??
                                          'No Description',
                                  totalStudents: '30',
                                  moduleAmount: '5',
                                  assessmentAmount: '2',
                                  courseImage: module['moduleImageUrl'] ??
                                      'assets/placeholder_image.png',
                                  onTap: () {
                                    widget.changePage(5,
                                        courseId: widget.courseId,
                                        moduleId: module['id']);
                                  },
                                  changePage: widget.changePage,
                                  onActivitiesTap: () => _openPdf(
                                    module['activitiesPdfUrl'] ?? '',
                                    '${module['moduleName']} - Activities',
                                  ),
                                  onAssessmentsTap: () => _openPdf(
                                    module['assessmentsPdfUrl'] ?? '',
                                    '${module['moduleName']} - Assessments',
                                  ),
                                  onTestSheetTap: () => _openPdf(
                                    module['testSheetPdfUrl'] ?? '',
                                    '${module['moduleName']} - Test Sheet',
                                  ),
                                  onAnswerSheetTap: () => _openPdf(
                                    module['answerSheetPdfUrl'] ?? '',
                                    '${module['moduleName']} - Answer Sheet',
                                  ),
                                  moduleId: module['id'],
                                  courseId: widget.courseId,
                                  onAssessmentMarkingTap:
                                      _showAssessmentMarking,
                                ),
                              ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
