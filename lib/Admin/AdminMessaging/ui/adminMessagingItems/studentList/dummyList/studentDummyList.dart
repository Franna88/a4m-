class Studentdummylist {
  final String image;
  final String name;
  final List<String> courses;
  final String courseAmount;

  const Studentdummylist(
      {required this.courseAmount,
      required this.courses,
      required this.image,
      required this.name});
}

List<Studentdummylist> students = [
  Studentdummylist(
      courseAmount: '4',
      courses: ['Test Course1', 'Test Course2', 'Test Course3', 'Test Course4'],
      image: 'images/person1.png',
      name: 'Anton Clark'),
  Studentdummylist(
      courseAmount: '4',
      courses: ['Test Course1', 'Test Course2', 'Test Course3', 'Test Course4'],
      image: 'images/person2.png',
      name: 'Anton Clark'),
  Studentdummylist(
      courseAmount: '4',
      courses: ['Test Course1', 'Test Course2', 'Test Course3', 'Test Course4'],
      image: 'images/person1.png',
      name: 'Anton Clark'),
  Studentdummylist(
      courseAmount: '4',
      courses: ['Test Course1', 'Test Course2', 'Test Course3', 'Test Course4'],
      image: 'images/person2.png',
      name: 'Anton Clark'),
];
