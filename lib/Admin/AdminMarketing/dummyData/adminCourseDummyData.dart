class AdminCourseDummyData {
  final String courseName;
  final String price;
  final String courseDescription;
  final String totalStudents;
  final String moduleAmount;
  final String assessmentAmount;
  final String courseImage;

  const AdminCourseDummyData(
      {required this.assessmentAmount,
      required this.courseDescription,
      required this.courseImage,
      required this.courseName,
      required this.moduleAmount,
      required this.price,
      required this.totalStudents});
}

List<AdminCourseDummyData> adminCourseDummy = [
  const AdminCourseDummyData(
    assessmentAmount: '7',
    courseDescription:
        'This learnership provides a solid foundation in operations, quality, maintenance and safety aspects of a business. ',
    courseImage: 'images/course1.png',
    courseName: 'Manufacturing 1',
    moduleAmount: '5',
    price: 'R 1443',
    totalStudents: '127',
  ),
  const AdminCourseDummyData(
    assessmentAmount: '2',
    courseDescription:
        'This skills program provides learners with the range of learning and skills required to be able to perform a series of activities to support manufacturing, engineering...',
    courseImage: 'images/course2.png',
    courseName: 'Production Systems',
    moduleAmount: '4',
    price: 'R 1553',
    totalStudents: '1217',
  ),
  const AdminCourseDummyData(
    assessmentAmount: '8',
    courseDescription:
        'This skills program provides learners with the range of learning and skills required to be able to perform a series of activities to support manufacturing, engineering...',
    courseImage: 'images/course3.png',
    courseName: 'Planning & Logistics',
    moduleAmount: '9',
    price: 'R 263',
    totalStudents: '117',
  ),
  const AdminCourseDummyData(
    assessmentAmount: '8',
    courseDescription:
        'This skills program provides learners with the range of learning and skills required to be able to perform a series of activities to support manufacturing, engineering...',
    courseImage: 'images/course4.png',
    courseName: 'Planning & Logistics',
    moduleAmount: '9',
    price: 'R 263',
    totalStudents: '117',
  ),
  const AdminCourseDummyData(
    assessmentAmount: '8',
    courseDescription:
        'This skills program provides learners with the range of learning and skills required to be able to perform a series of activities to support manufacturing, engineering...',
    courseImage: 'images/course5.png',
    courseName: 'Planning & Logistics',
    moduleAmount: '9',
    price: 'R 263',
    totalStudents: '117',
  ),
  const AdminCourseDummyData(
    assessmentAmount: '8',
    courseDescription:
        'This skills program provides learners with the range of learning and skills required to be able to perform a series of activities to support manufacturing, engineering...',
    courseImage: 'images/course6.png',
    courseName: 'Planning & Logistics',
    moduleAmount: '9',
    price: 'R 263',
    totalStudents: '117',
  ),
];
