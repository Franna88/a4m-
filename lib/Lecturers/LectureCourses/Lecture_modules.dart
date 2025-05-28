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
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:async';

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
  Timer? _debounceTimer;
  final TextEditingController _searchController = TextEditingController();

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

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
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

  // Perform search with debounce
  void _performSearch(String query) {
    // Cancel previous timer if it exists
    _debounceTimer?.cancel();

    // Create a new timer that will execute after 300ms (reduced from 500ms)
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        // Check if widget is still mounted
        setState(() {
          searchQuery = query.toLowerCase();
          _applyFilters();
        });
      }
    });
  }

  void _applyFilters() {
    if (modules.isEmpty) return;

    filteredModules = modules.where((module) {
      // Apply search filter first
      if (searchQuery.isNotEmpty) {
        final nameMatches = module['moduleName']
                ?.toString()
                .toLowerCase()
                .contains(searchQuery) ??
            false;
        final descriptionMatches = module['moduleDescription']
                ?.toString()
                .toLowerCase()
                .contains(searchQuery) ??
            false;

        if (!nameMatches && !descriptionMatches) return false;
      }

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

    // Only show download for Test Sheet and Assessment
    final lowerTitle = title.toLowerCase();
    final showDownload =
        lowerTitle.contains('test') || lowerTitle.contains('assessment');

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
            showDownloadButton: showDownload,
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

  void _showIndexPdfDialog(BuildContext context, String pdfUrl) {
    final viewType = 'index-pdf-viewer';
    // Register the view factory only once
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) {
        final html.IFrameElement element = html.IFrameElement()
          ..src =
              'https://docs.google.com/viewer?embedded=true&url=${Uri.encodeComponent(pdfUrl)}'
          ..style.border = 'none'
          ..width = '600'
          ..height = '800';
        return element;
      },
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 600,
          height: 800,
          child: HtmlElementView(viewType: viewType),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
            // Keep backButton at the top for module complete list view
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    widget.changePage(1);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Courses'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Mycolors().green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: Container()),
              ],
            ),
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
            // Search Bar and Back Button Row
            Row(
              children: [
                // Back Button
                ElevatedButton.icon(
                  onPressed: () {
                    widget.changePage(1);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Mycolors().green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    minimumSize: const Size(0, 40),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Search Bar (smaller)
                Expanded(
                  flex: 2,
                  child: MySearchBar(
                    textController: _searchController,
                    hintText: 'Search Module',
                    onChanged: (value) {
                      _performSearch(value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Filter Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
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
                    underline: const SizedBox(),
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
                                              // Text(
                                              //   module['moduleDescription'] ??
                                              //       'No description available',
                                              //   style: GoogleFonts.poppins(
                                              //     fontSize: 14,
                                              //     color: Colors.grey[600],
                                              //     height: 1.5,
                                              //   ),
                                              //   maxLines: 2,
                                              //   overflow: TextOverflow.ellipsis,
                                              // ),
                                              // const SizedBox(height: 16),
                                              // Info Icon Button
                                              if (module['indexPdfUrl'] !=
                                                      null &&
                                                  (module['indexPdfUrl']
                                                          as String)
                                                      .isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0,
                                                          bottom: 8.0),
                                                  child: Tooltip(
                                                    message: 'View Index',
                                                    child: IconButton(
                                                      icon: Icon(
                                                        Icons.info_outline,
                                                        color: Colors.blue,
                                                        size: 28,
                                                      ),
                                                      onPressed: () {
                                                        _showIndexPdfDialog(
                                                            context,
                                                            module[
                                                                'indexPdfUrl']);
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              // Action Buttons
                                              _buildActionButtonsGrid(module),
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

  Widget _buildActionButtonsGrid(Map<String, dynamic> module) {
    final List<Widget> buttons = [];
    if (module['studentGuidePdfUrl'] != null)
      buttons.add(Tooltip(
        message: 'View Student Guide',
        child: _buildActionButton(
          icon: Icons.school_outlined,
          label: 'Student Guide',
          onTap: () => _openPdf(module['studentGuidePdfUrl'], 'Student Guide'),
        ),
      ));
    if (module['lecturerGuidePdfUrl'] != null)
      buttons.add(Tooltip(
        message: 'View Lecturer Guide',
        child: _buildActionButton(
          icon: Icons.description_outlined,
          label: 'Lecturer Guide',
          onTap: () =>
              _openPdf(module['lecturerGuidePdfUrl'], 'Lecturer Guide'),
        ),
      ));
    if (module['testSheetPdfUrl'] != null)
      buttons.add(Tooltip(
        message: 'View Test',
        child: _buildActionButton(
          icon: Icons.quiz_outlined,
          label: 'Test',
          onTap: () => _openPdf(module['testSheetPdfUrl'], 'Test Sheet'),
        ),
      ));
    if (module['assessmentsPdfUrl'] != null)
      buttons.add(Tooltip(
        message: 'View Assessment',
        child: _buildActionButton(
          icon: Icons.assignment_outlined,
          label: 'Assessment',
          onTap: () => _openPdf(module['assessmentsPdfUrl'], 'Assessment'),
        ),
      ));
    if (module['answerSheetPdfUrl'] != null)
      buttons.add(Tooltip(
        message: 'View Answers',
        child: _buildActionButton(
          icon: Icons.check_circle_outline,
          label: 'Answers',
          onTap: () => _openPdf(module['answerSheetPdfUrl'], 'Answer Sheet'),
        ),
      ));
    // Add Index PDF button

    // Display buttons in a grid: 2 per row (or 3 if you want)
    int buttonsPerRow = 2;
    List<Widget> rows = [];
    for (int i = 0; i < buttons.length; i += buttonsPerRow) {
      rows.add(Row(
        children: [
          for (int j = i; j < i + buttonsPerRow && j < buttons.length; j++)
            Expanded(child: buttons[j]),
          if ((i + buttonsPerRow) > buttons.length)
            for (int k = 0; k < (i + buttonsPerRow - buttons.length); k++)
              const Expanded(child: SizedBox()),
        ],
      ));
      rows.add(const SizedBox(height: 8));
    }
    return Column(children: rows);
  }
}
