class AssessmentsDummtList {
  final String courseName;
  final String courseImage;
  final String courseDescription;
  final String moduleCount;
  final String assessmentCount;

  const AssessmentsDummtList(
      {required this.assessmentCount,
      required this.courseDescription,
      required this.courseImage,
      required this.courseName,
      required this.moduleCount});
}

List<AssessmentsDummtList> DummyAssessments = [
  AssessmentsDummtList(
      assessmentCount: '4/6',
      courseDescription:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut',
      courseImage: 'images/course1.png',
      courseName: 'Production Technology',
      moduleCount: '2'),
  AssessmentsDummtList(
      assessmentCount: '4/6',
      courseDescription:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut',
      courseImage: 'images/course2.png',
      courseName: 'Production Technology',
      moduleCount: '2'),
  AssessmentsDummtList(
      assessmentCount: '4/6',
      courseDescription:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut',
      courseImage: 'images/course3.png',
      courseName: 'Production Technology',
      moduleCount: '2'),
];
