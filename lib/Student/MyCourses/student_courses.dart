import 'package:a4m/CommonComponents/inputFields/mySearchBar.dart';
import 'package:a4m/Student/MyCourses/reusable_course_container.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

class StudentCourses extends StatefulWidget {
  final Function(int, String) changePageWithCourseId;
  final String lecturerId;

  const StudentCourses({
    super.key,
    required this.changePageWithCourseId,
    required this.lecturerId,
  });

  @override
  State<StudentCourses> createState() => _StudentCoursesState();
}

class _StudentCoursesState extends State<StudentCourses> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth ~/ 400).clamp(1, 6);

    return Container(
      width: MyUtility(context).width - 320,
      height: MyUtility(context).height - 80,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 300,
                  height: 50,
                  child: MySearchBar(
                    textController: TextEditingController(),
                    hintText: 'Search Course',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Courses Grid
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ReusableCourseContainer(
                        imagePath: 'images/course5.png',
                        courseName: "Production Technology",
                        courseDescription:
                            "Lorem ipsum dolor sit amet. Non dolorem optio quo aperiam obcaecati est nihil velit sit nemo quisquam ut culpa esse aut corporis amet et numquam galisum? Quo rerum consequatur aut optio velit vel iste rerum non atque quaerat est rerum dicta. Est voluptatem debitis qui autem maiores eum facilis nostrum eos enim accusamus rem possimus dicta?"),
                    ReusableCourseContainer(
                        imagePath: 'images/course5.png',
                        courseName: "Production Technology",
                        courseDescription:
                            "Lorem ipsum dolor sit amet. Non dolorem optio quo aperiam obcaecati est nihil velit sit nemo quisquam ut culpa esse aut corporis amet et numquam galisum? Quo rerum consequatur aut optio velit vel iste rerum non atque quaerat est rerum dicta. Est voluptatem debitis qui autem maiores eum facilis nostrum eos enim accusamus rem possimus dicta?"),
                    ReusableCourseContainer(
                        imagePath: 'images/course5.png',
                        courseName: "Production Technology",
                        courseDescription:
                            "Lorem ipsum dolor sit amet. Non dolorem optio quo aperiam obcaecati est nihil velit sit nemo quisquam ut culpa esse aut corporis amet et numquam galisum? Quo rerum consequatur aut optio velit vel iste rerum non atque quaerat est rerum dicta. Est voluptatem debitis qui autem maiores eum facilis nostrum eos enim accusamus rem possimus dicta?"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
