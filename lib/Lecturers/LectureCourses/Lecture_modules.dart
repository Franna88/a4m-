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
import 'package:a4m/Lecturers/LectureCourses/assessment_submissions_view.dart';
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
  bool isHovered = false;

  final List<String> filterOptions = [
    'All',
    'With Activities',
    'With Assessments',
    'With Tests',
    'With Answers',
  ];

  @override
  void initState() {
    super.initState();
    print(
        "LectureModulesContainer initialized with courseId: ${widget.courseId}");
    if (widget.courseId.isNotEmpty) {
      fetchModules();
    } else {
      print("Warning: courseId is empty in LectureModulesContainer");
    }
  }

  // Fetch modules dynamically from Firestore
  Future<void> fetchModules() async {
    try {
      print("Fetching modules for course ID: ${widget.courseId}");

      var querySnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .get();

      print("Found ${querySnapshot.docs.length} modules");

      modules = querySnapshot.docs.map((doc) {
        final data = doc.data();
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
    print(
        "Opening assessment marking for module: $moduleId in course: ${widget.courseId}");
    if (moduleId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: Module ID is missing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.courseId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: Course ID is missing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.changePage(7, courseId: widget.courseId, moduleId: moduleId);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth ~/ 400).clamp(1, 6);

    if (showModuleCompleteList && selectedModuleId != null) {
      return SizedBox(
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

    return SizedBox(
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
                    hintText: 'Search Module',
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: selectedFilter,
                    items: filterOptions.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Modules Grid
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredModules.isEmpty
                      ? Center(
                          child: Text(
                            'No modules found.',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          child: LayoutGrid(
                            columnSizes: List.generate(
                              crossAxisCount,
                              (_) => FlexibleTrackSize(1),
                            ),
                            rowSizes: List.generate(
                              (filteredModules.length / crossAxisCount).ceil(),
                              (_) => auto,
                            ),
                            rowGap: 20,
                            columnGap: 20,
                            children: [
                              for (var module in filteredModules)
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: isHovered ? 2 : 1,
                                        blurRadius: isHovered ? 15 : 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: MouseRegion(
                                    onEnter: (_) =>
                                        setState(() => isHovered = true),
                                    onExit: (_) =>
                                        setState(() => isHovered = false),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          widget.changePage(
                                            7,
                                            courseId: widget.courseId,
                                            moduleId: module['id'],
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // Module Image
                                              Container(
                                                height: 160,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  color: Colors.grey[200],
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child:
                                                      module['moduleImageUrl'] !=
                                                              null
                                                          ? ImageNetwork(
                                                              image: module[
                                                                  'moduleImageUrl'],
                                                              height: 160,
                                                              width: 400,
                                                              duration: 100,
                                                              fitAndroidIos:
                                                                  BoxFit.cover,
                                                              fitWeb: BoxFitWeb
                                                                  .cover,
                                                              onLoading:
                                                                  Container(
                                                                color: Colors
                                                                    .grey[200],
                                                                child:
                                                                    const Center(
                                                                  child:
                                                                      CircularProgressIndicator(),
                                                                ),
                                                              ),
                                                              onError:
                                                                  Container(
                                                                color: Colors
                                                                    .grey[200],
                                                                child:
                                                                    const Icon(
                                                                  Icons
                                                                      .error_outline,
                                                                  color: Colors
                                                                      .red,
                                                                  size: 32,
                                                                ),
                                                              ),
                                                            )
                                                          : Container(
                                                              color: Mycolors()
                                                                  .darkGrey,
                                                              child:
                                                                  const Center(
                                                                child: Icon(
                                                                  Icons.book,
                                                                  size: 48,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              // Module Header
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      module['moduleName'] ??
                                                          'Unnamed Module',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.grey[800],
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              // Module Description
                                              Text(
                                                module['moduleDescription'] ??
                                                    'No description available',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                  height: 1.5,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 16),
                                              // Action Buttons
                                              SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  children: [
                                                    // Student Guide
                                                    if (module[
                                                            'studentGuidePdfUrl'] !=
                                                        null)
                                                      _buildActionButton(
                                                        icon: Icons
                                                            .school_outlined,
                                                        label: 'Student Guide',
                                                        onTap: () => _openPdf(
                                                          module[
                                                              'studentGuidePdfUrl'],
                                                          'Student Guide',
                                                        ),
                                                      ),
                                                    if (module[
                                                            'studentGuidePdfUrl'] !=
                                                        null)
                                                      const SizedBox(width: 8),
                                                    // Lecturer Guide
                                                    if (module[
                                                            'lecturerGuidePdfUrl'] !=
                                                        null)
                                                      _buildActionButton(
                                                        icon: Icons
                                                            .description_outlined,
                                                        label: 'Lecturer Guide',
                                                        onTap: () => _openPdf(
                                                          module[
                                                              'lecturerGuidePdfUrl'],
                                                          'Lecturer Guide',
                                                        ),
                                                      ),
                                                    if (module[
                                                            'lecturerGuidePdfUrl'] !=
                                                        null)
                                                      const SizedBox(width: 8),
                                                    // Test Sheet
                                                    if (module[
                                                            'testSheetPdfUrl'] !=
                                                        null)
                                                      _buildActionButton(
                                                        icon:
                                                            Icons.quiz_outlined,
                                                        label: 'Test',
                                                        onTap: () => _openPdf(
                                                          module[
                                                              'testSheetPdfUrl'],
                                                          'Test Sheet',
                                                        ),
                                                      ),
                                                    if (module[
                                                            'testSheetPdfUrl'] !=
                                                        null)
                                                      const SizedBox(width: 8),
                                                    // Assessments
                                                    if (module[
                                                            'assessmentsPdfUrl'] !=
                                                        null)
                                                      _buildActionButton(
                                                        icon: Icons
                                                            .assignment_outlined,
                                                        label: 'Assessment',
                                                        onTap: () => _openPdf(
                                                          module[
                                                              'assessmentsPdfUrl'],
                                                          'Assessment',
                                                        ),
                                                      ),
                                                    if (module[
                                                            'assessmentsPdfUrl'] !=
                                                        null)
                                                      const SizedBox(width: 8),
                                                    // Answer Sheet
                                                    if (module[
                                                            'answerSheetPdfUrl'] !=
                                                        null)
                                                      _buildActionButton(
                                                        icon: Icons
                                                            .check_circle_outline,
                                                        label: 'Answers',
                                                        onTap: () => _openPdf(
                                                          module[
                                                              'answerSheetPdfUrl'],
                                                          'Answer Sheet',
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Mycolors().green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: Mycolors().green,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Mycolors().green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
