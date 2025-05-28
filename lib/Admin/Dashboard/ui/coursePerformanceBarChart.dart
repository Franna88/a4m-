import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CoursePerformanceBarChart extends StatefulWidget {
  const CoursePerformanceBarChart({super.key});

  @override
  State<CoursePerformanceBarChart> createState() =>
      _CoursePerformanceBarChartState();
}

class _CoursePerformanceBarChartState extends State<CoursePerformanceBarChart> {
  List<CoursePerformanceData> courseData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourseData();
  }

  Future<void> _fetchCourseData() async {
    try {
      // Get all module submissions to track completions
      final submissionsSnapshot = await FirebaseFirestore.instance
          .collection('moduleSubmissions')
          .get();

      // Get all courses
      final coursesSnapshot =
          await FirebaseFirestore.instance.collection('courses').get();

      Map<String, CourseData> coursesMap = {};

      // Initialize course data
      for (var course in coursesSnapshot.docs) {
        final courseId = course.id;
        final courseName =
            course.data()['courseName'] as String? ?? 'Unnamed Course';

        coursesMap[courseId] = CourseData(
          courseName: courseName,
          totalStudents: 0,
          completedStudents: 0,
        );
      }

      // Process module submissions
      Map<String, Set<String>> courseStudents = {};
      Map<String, Set<String>> courseCompletions = {};

      for (var submission in submissionsSnapshot.docs) {
        final data = submission.data();
        final courseId = data['courseId'] as String;
        final studentId = data['studentId'] as String;
        final isCompleted = data['status'] == 'completed';

        // Initialize sets if needed
        courseStudents.putIfAbsent(courseId, () => {});
        courseCompletions.putIfAbsent(courseId, () => {});

        // Add student to total students
        courseStudents[courseId]!.add(studentId);

        // Add to completions if module is completed
        if (isCompleted) {
          courseCompletions[courseId]!.add(studentId);
        }
      }

      // Update course data with student counts
      for (var entry in courseStudents.entries) {
        final courseId = entry.key;
        if (coursesMap.containsKey(courseId)) {
          coursesMap[courseId]!.totalStudents = entry.value.length;
          coursesMap[courseId]!.completedStudents =
              courseCompletions[courseId]?.length ?? 0;
        }
      }

      // Convert to list and sort by completion rate
      List<CoursePerformanceData> data = coursesMap.entries.map((entry) {
        final completionRate = entry.value.totalStudents > 0
            ? (entry.value.completedStudents / entry.value.totalStudents) * 100
            : 0.0;

        return CoursePerformanceData(
          courseName: entry.value.courseName,
          totalStudents: entry.value.totalStudents,
          completedStudents: entry.value.completedStudents,
          completionRate: completionRate,
        );
      }).toList();

      // Sort by completion rate
      data.sort((a, b) => b.completionRate.compareTo(a.completionRate));

      // Take top 10 courses
      if (data.length > 10) {
        data = data.sublist(0, 10);
      }

      if (mounted) {
        setState(() {
          courseData = data;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching course data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Course Performance',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Student progress and completion rates',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Top 10 Courses',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : courseData.isEmpty
                    ? Center(
                        child: Text(
                          'No course data available',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 100, // Percentage scale
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              tooltipBgColor: Colors.grey[800]!,
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) {
                                final course = courseData[group.x.toInt()];
                                return BarTooltipItem(
                                  '${course.courseName}\n',
                                  GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          'Completion: ${course.completionRate.toStringAsFixed(1)}%\n',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          'Completed: ${course.completedStudents}/${course.totalStudents} students',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  if (value >= courseData.length)
                                    return const Text('');
                                  return Transform.rotate(
                                    angle: -0.5,
                                    child: SizedBox(
                                      width: 60,
                                      child: Text(
                                        courseData[value.toInt()]
                                                    .courseName
                                                    .length >
                                                15
                                            ? '${courseData[value.toInt()].courseName.substring(0, 15)}...'
                                            : courseData[value.toInt()]
                                                .courseName,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${value.toInt()}%',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 20,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey[300]!,
                                strokeWidth: 1,
                              );
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: courseData.asMap().entries.map((entry) {
                            final index = entry.key;
                            final data = entry.value;
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: data.completionRate,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green[300]!,
                                      Colors.green[600]!
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  width: 16,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class CoursePerformanceData {
  final String courseName;
  final int totalStudents;
  final int completedStudents;
  final double completionRate;

  CoursePerformanceData({
    required this.courseName,
    required this.totalStudents,
    required this.completedStudents,
    required this.completionRate,
  });
}

class CourseData {
  final String courseName;
  int totalStudents;
  int completedStudents;

  CourseData({
    required this.courseName,
    required this.totalStudents,
    required this.completedStudents,
  });
}
