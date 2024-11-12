class FacilitatorDummyList {
  final bool? isFacilitator;

  final String name;
  final String number;

  final String studentAmount;
  final String image;

  const FacilitatorDummyList({
    required this.name,
    required this.number,
    required this.studentAmount,
    required this.image,
    this.isFacilitator,
  });
}

List<FacilitatorDummyList> facilitators = [
  FacilitatorDummyList(
    name: 'Jesse Pikmon',
    number: '093 484 772',
    studentAmount: '34',
    image: 'images/person1.png',
    isFacilitator: true,
  ),
  FacilitatorDummyList(
    name: 'Kurt Ames',
    number: '093 484 772',
    studentAmount: '3',
    isFacilitator: true,
    image: 'images/person2.png',
  ),
  FacilitatorDummyList(
    name: 'Jesse Pikmon',
    number: '093 484 772',
    studentAmount: '7',
    image: 'images/person1.png',
    isFacilitator: true,
  ),
  FacilitatorDummyList(
    name: 'Kurt Ames',
    number: '093 484 772',
    studentAmount: '17',
    image: 'images/person2.png',
    isFacilitator: true,
  ),
];
