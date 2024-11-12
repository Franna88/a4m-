class ContentDevData {
  final bool? isContentDev;

  final String name;
  final String number;

  final String content;
  final String image;

  const ContentDevData({
    required this.name,
    required this.number,
    required this.content,
    required this.image,
    this.isContentDev,
  });
}

List<ContentDevData> contentDevs = [
  ContentDevData(
      name: 'Jesse Pikmon',
      number: '093 484 772',
      content: '34',
      image: 'images/person1.png',
      isContentDev: true),
  ContentDevData(
    name: 'Kurt Ames',
    number: '093 484 772',
    content: '3',
    isContentDev: true,
    image: 'images/person2.png',
  ),
  ContentDevData(
    name: 'Jesse Pikmon',
    number: '093 484 772',
    content: '7',
    image: 'images/person1.png',
    isContentDev: true
  ),
  ContentDevData(
    name: 'Kurt Ames',
    number: '093 484 772',
    content: '17',
    image: 'images/person2.png',
    isContentDev: true
  ),
];
