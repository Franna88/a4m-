class MembersDummyData {
  final bool? isContentDev;
  final bool? isFacilitator;
  final bool? isLecturer;
  final String name;
  final String number;
  final String students;
  final String content;
  final String image;
  final String rating;

  const MembersDummyData(
      {required this.name,
      required this.number,
      required this.content,
      required this.students,
      required this.image,
      required this.rating,
      this.isContentDev,
      this.isFacilitator,
      this.isLecturer});
}

List<MembersDummyData> memberdummyData = [
  MembersDummyData(
      name: 'Jesse Pikmon',
      rating: '4.4',
      number: '093 484 772',
      content: '',
      students: '122',
      isLecturer: true,
      image: 'images/person1.png'),
  MembersDummyData(
      name: 'Kurt Ames',
      number: '093 484 772',
      content: '3',
      students: '122',
      isContentDev: true,
      image: 'images/person2.png',
      rating: ''),
  MembersDummyData(
      name: 'Jesse Pikmon',
      number: '093 484 772',
      content: '',
      students: '122',
      isLecturer: true,
      image: 'images/person1.png',
      rating: '3.3'),
  MembersDummyData(
      name: 'Kurt Ames',
      number: '093 484 772',
      content: '',
      students: '122',
      isLecturer: true,
      image: 'images/person2.png',
      rating: '5'),
  MembersDummyData(
      name: 'Jesse Pikmon',
      number: '093 484 772',
      content: '',
      students: '122',
      isFacilitator: true,
      image: 'images/person1.png',
      rating: '3.3'),
  MembersDummyData(
      name: 'Kurt Ames',
      number: '093 484 772',
      content: '',
      students: '122',
      isFacilitator: true,
      image: 'images/person2.png',
      rating: '5'),
];
