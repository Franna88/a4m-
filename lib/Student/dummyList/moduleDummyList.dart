class Moduledummylist {
  final String moduleName;
  final String moduleDescription;
  final String assessmentCount;
  final String moduleImage;

  const Moduledummylist(
      {required this.assessmentCount,
      required this.moduleDescription,
      required this.moduleImage,
      required this.moduleName});
}

List<Moduledummylist> dummyModuleList = [
  Moduledummylist(
      assessmentCount: '5',
      moduleDescription: 'This skills program provides learners with the range of learning and skills required to be able to perform a series of activities to support manufacturing, engineering....',
      moduleImage: 'images/course1.png',
      moduleName: 'Module 1'),
      Moduledummylist(
      assessmentCount: '8',
      moduleDescription: 'This skills program provides learners with the range of learning and skills required to be able to perform a series of activities to support manufacturing, engineering....',
      moduleImage: 'images/course2.png',
      moduleName: 'Module 2'),
      Moduledummylist(
      assessmentCount: '3',
      moduleDescription: 'This skills program provides learners with the range of learning and skills required to be able to perform a series of activities to support manufacturing, engineering....',
      moduleImage: 'images/course3.png',
      moduleName: 'Module 3'),
];
