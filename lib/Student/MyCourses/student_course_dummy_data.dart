class StudentCourseDummyData  {
  final String courseName;
  final String modulesComplete;
  final String courseDescription;
  final String totalStudents;
  final String moduleAmount;
  final String assessmentAmount;
  final String courseImage;

  const StudentCourseDummyData (
      {required this.assessmentAmount,
      required this.courseDescription,
      required this.courseImage,
      required this.courseName,
      required this.moduleAmount,
      required this.modulesComplete,
      required this.totalStudents});
}

List<StudentCourseDummyData > lectureCourseDummy = [
  const StudentCourseDummyData (
    assessmentAmount: '7',
    courseDescription:
        'This learnership provides a solid foundation in operations, quality, maintenance and safety aspects of a business. ',
    courseImage: 'images/course1.png',
    courseName: 'Manufacturing 1',
    moduleAmount: '5',
    modulesComplete: '10',
    totalStudents: '127',
  ),
  const StudentCourseDummyData (
    assessmentAmount: '2',
    courseDescription:
        'This skills program provides learners with the range of learning and skills required to be able to perform a series of activities to support manufacturing, engineering...',
    courseImage: 'images/course2.png',
    courseName: 'Production Systems',
    moduleAmount: '4',
    modulesComplete: '14',
    totalStudents: '1217',
  ),
  const StudentCourseDummyData (
    assessmentAmount: '8',
    courseDescription:
        'This skills program provides learners with the range of learning and skills required to be able to perform a series of activities to support manufacturing, engineering...',
    courseImage: 'images/course3.png',
    courseName: 'Planning & Logistics',
    moduleAmount: '9',
    modulesComplete: '23',
    totalStudents: '117',
  ),
  const StudentCourseDummyData (
    assessmentAmount: '8',
    courseDescription:
        'This skills program provides learners with the range of learning and skills required to be able to perform a series of activities to support manufacturing, engineering...',
    courseImage: 'images/course4.png',
    courseName: 'Planning & Logistics',
    moduleAmount: '9',
    modulesComplete: '6',
    totalStudents: '117',
  ),
  const StudentCourseDummyData (
    assessmentAmount: '8',
    courseDescription:
        'This skills program provides learners with the range of learning and skills required to be able to perform a series of activities to support manufacturing, engineering...',
    courseImage: 'images/course5.png',
    courseName: 'Planning & Logistics',
    moduleAmount: '9',
    modulesComplete: '21',
    totalStudents: '117',
  ),
  const StudentCourseDummyData(
    assessmentAmount: '8',
    courseDescription:
        'This skills program provides learners with the range of learning and skills required to be able to perform a series of activities to support manufacturing, engineering...',
    courseImage: 'images/course6.png',
    courseName: 'Planning & Logistics',
    moduleAmount: '9',
    modulesComplete: '23',
    totalStudents: '117',
  ),
];
