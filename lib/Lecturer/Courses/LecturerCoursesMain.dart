import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Themes/Constants/myColors.dart';
import 'LecturerCourseContainer.dart';

class LecturerCoursesMain extends StatefulWidget {
  final String lecturerId;

  const LecturerCoursesMain({
    super.key,
    required this.lecturerId,
  });

  @override
  State<LecturerCoursesMain> createState() => _LecturerCoursesMainState();
}

class _LecturerCoursesMainState extends State<LecturerCoursesMain> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String _sortBy = 'Recent';

  final List<String> _filterOptions = [
    'All',
    'Active',
    'Completed',
    'Pending Review'
  ];
  final List<String> _sortOptions = [
    'Recent',
    'Oldest',
    'Name A-Z',
    'Name Z-A'
  ];

  List<Map<String, dynamic>> _filteredCourses = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filterCourses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCourses() {
    // TODO: Replace with actual course data from Firebase
    final allCourses = [
      {
        'name': 'Introduction to Programming',
        'image': 'https://example.com/course1.jpg',
        'description':
            'Learn the basics of programming with this comprehensive course.',
        'moduleCount': '8',
        'assessmentCount': '12',
        'studentCount': '45',
        'pendingAssessments': '5',
        'status': 'Active',
        'lastUpdated': DateTime.now(),
      },
      // ... other courses
    ];

    var filtered = allCourses.where((course) {
      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final name = course['name'].toString().toLowerCase();
        final description = course['description'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        if (!name.contains(query) && !description.contains(query)) {
          return false;
        }
      }

      // Apply status filter
      if (_selectedFilter != 'All') {
        return course['status'] == _selectedFilter;
      }

      return true;
    }).toList();

    // Apply sorting
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'Recent':
          return (b['lastUpdated'] as DateTime)
              .compareTo(a['lastUpdated'] as DateTime);
        case 'Oldest':
          return (a['lastUpdated'] as DateTime)
              .compareTo(b['lastUpdated'] as DateTime);
        case 'Name A-Z':
          return a['name'].toString().compareTo(b['name'].toString());
        case 'Name Z-A':
          return b['name'].toString().compareTo(a['name'].toString());
        default:
          return 0;
      }
    });

    setState(() {
      _filteredCourses = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSearchAndFilters(),
          const SizedBox(height: 24),
          Expanded(
            child: _buildCourseList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Courses',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage and monitor your courses',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implement create course functionality
          },
          icon: const Icon(Icons.add),
          label: Text(
            'Create Course',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Mycolors().green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _filterCourses();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search courses...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                                _filterCourses();
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Mycolors().green),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _buildFilterDropdown(),
              const SizedBox(width: 16),
              _buildSortDropdown(),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions
                  .map((filter) => _buildFilterChip(filter))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFilter,
          icon: const Icon(Icons.filter_list),
          items: _filterOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: GoogleFonts.poppins(),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedFilter = newValue;
                _filterCourses();
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sortBy,
          icon: const Icon(Icons.sort),
          items: _sortOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: GoogleFonts.poppins(),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _sortBy = newValue;
                _filterCourses();
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(
          filter,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.grey[800],
            fontSize: 14,
          ),
        ),
        backgroundColor: Colors.grey[50],
        selectedColor: Mycolors().green,
        onSelected: (bool selected) {
          setState(() {
            _selectedFilter = selected ? filter : 'All';
            _filterCourses();
          });
        },
      ),
    );
  }

  Widget _buildCourseList() {
    if (_filteredCourses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No courses found',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            if (_searchQuery.isNotEmpty)
              Text(
                'Try adjusting your search or filters',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCourses.length,
      itemBuilder: (context, index) {
        final course = _filteredCourses[index];
        return LecturerCourseContainer(
          courseName: course['name']!,
          courseImage: course['image']!,
          courseDescription: course['description']!,
          moduleCount: course['moduleCount']!,
          assessmentCount: course['assessmentCount']!,
          studentCount: course['studentCount']!,
          pendingAssessments: course['pendingAssessments']!,
          onTap: () {
            // TODO: Navigate to course details
          },
          onMarkAssessments: () {
            // TODO: Navigate to assessment marking
          },
          onViewAnalytics: () {
            // TODO: Navigate to course analytics
          },
        );
      },
    );
  }
}
