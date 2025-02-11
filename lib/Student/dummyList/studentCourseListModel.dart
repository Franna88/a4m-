class Studentcourselistmodel {
  final String courseName;
  final String courseImage;
  final String courseDescription;
  final String moduleCount;
  final String assessmentCount;
  final String courseId; // Add a unique course ID

  const Studentcourselistmodel({
    required this.assessmentCount,
    required this.courseDescription,
    required this.courseImage,
    required this.courseName,
    required this.moduleCount,
    required this.courseId, // Initialize it
  });
}

List<Studentcourselistmodel> dummyStudentCourseList = [
  Studentcourselistmodel(
    assessmentCount: '4',
    courseDescription:
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut',
    courseImage: 'images/course1.png',
    courseName: 'Production Technology',
    moduleCount: '2',
    courseId: 'course_1', // Unique identifier for the course
  ),
  Studentcourselistmodel(
    assessmentCount: '4',
    courseDescription:
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut',
    courseImage: 'images/course2.png',
    courseName: 'Production Technology',
    moduleCount: '2',
    courseId: 'course_2', // Unique identifier for the course
  ),
  Studentcourselistmodel(
    assessmentCount: '4',
    courseDescription:
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut',
    courseImage: 'images/course3.png',
    courseName: 'Production Technology',
    moduleCount: '2',
    courseId: 'course_3', // Unique identifier for the course
  ),
];
