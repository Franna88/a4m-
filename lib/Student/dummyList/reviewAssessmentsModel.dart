class ReviewAssessmentsModel {
  final String moduleName;
  final String moduleImage;
  final String moduleDescription;
  final String moduleCount;
  final String assessmentCount;
  final bool isPassed;

  const ReviewAssessmentsModel(
      {required this.assessmentCount,
      required this.moduleDescription,
      required this.moduleImage,
      required this.moduleName,
      required this.moduleCount,
      required this.isPassed});
}

List<ReviewAssessmentsModel> dummyRieviewAssessmentList = [
  ReviewAssessmentsModel(
      assessmentCount: '4',
      moduleDescription:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut',
      moduleImage: 'images/course4.png',
      moduleName: 'Production Technology',
      moduleCount: '2', isPassed: true),
  ReviewAssessmentsModel(
      assessmentCount: '4',
      moduleDescription:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut',
      moduleImage: 'images/course5.png',
      moduleName: 'Production Technology',
      moduleCount: '2', isPassed: true),
  ReviewAssessmentsModel(
      assessmentCount: '4',
      moduleDescription:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut',
      moduleImage: 'images/course6.png',
      moduleName: 'Production Technology',
      moduleCount: '2', isPassed: false),
];
