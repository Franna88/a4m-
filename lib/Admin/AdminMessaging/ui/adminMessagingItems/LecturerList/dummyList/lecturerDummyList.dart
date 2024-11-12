class LecturerDummyList {
  final bool? isLecturer;

  final String name;
  final String number;
  final String rating;
  final String studentAmount;
  final String image;

  const LecturerDummyList({
    required this.rating,
    required this.name,
    required this.number,
    required this.studentAmount,
    required this.image,
    this.isLecturer,
  });
}

List<LecturerDummyList> lecturers = [
  LecturerDummyList(
      name: 'Jesse Pikmon',
      number: '093 484 772',
      studentAmount: '34',
      image: 'images/person1.png',
      isLecturer: true,
      rating: '4.4'),
  LecturerDummyList(
    name: 'Kurt Ames',
    number: '093 484 772',
    studentAmount: '3',
    isLecturer: true,
    image: 'images/person2.png',
    rating: '5',
  ),
  LecturerDummyList(
      name: 'Jesse Pikmon',
      number: '093 484 772',
      studentAmount: '7',
      image: 'images/person1.png',
      isLecturer: true,
      rating: '3.4'),
  LecturerDummyList(
      name: 'Kurt Ames',
      number: '093 484 772',
      studentAmount: '17',
      image: 'images/person2.png',
      isLecturer: true,
      rating: '4.1'),
];
