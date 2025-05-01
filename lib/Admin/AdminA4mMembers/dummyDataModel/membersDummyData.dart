import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final String? id;

  const MembersDummyData({
    required this.name,
    required this.number,
    required this.content,
    required this.students,
    required this.image,
    required this.rating,
    this.isContentDev,
    this.isFacilitator,
    this.isLecturer,
    this.id,
  });

  // Factory constructor to create from Firestore data
  factory MembersDummyData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String userType = data['userType'] ?? '';

    // Determine user type flags
    final bool isLecturer = userType == 'lecturer';
    final bool isContentDev =
        userType == 'contentDev' || userType == 'content_dev';
    final bool isFacilitator = userType == 'facilitator';

    // Get profile image or use default
    final String imageUrl = data['profileImageUrl'] ?? 'images/person1.png';

    // Get phone number or use default
    final String phoneNumber = data['phoneNumber'] ?? 'No phone number';

    // Get rating or use default
    final String userRating = data['rating'] ?? '0.0';

    // Get student count or use default
    final String studentCount = data['studentCount']?.toString() ?? '0';

    // Get content count or use default
    final String contentCount = data['contentCount']?.toString() ?? '0';

    return MembersDummyData(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      number: phoneNumber,
      content: contentCount,
      students: studentCount,
      image: imageUrl,
      rating: userRating,
      isContentDev: isContentDev,
      isFacilitator: isFacilitator,
      isLecturer: isLecturer,
    );
  }
}

// Static list for backward compatibility
List<MembersDummyData> memberdummyData = [];

// Function to fetch real data from Firebase
Future<List<MembersDummyData>> fetchMembersData() async {
  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Query users collection for lecturers, content developers, and facilitators
    final QuerySnapshot querySnapshot = await firestore
        .collection('Users')
        .where('userType',
            whereIn: ['lecturer', 'contentDev', 'content_dev', 'facilitator'])
        .where('status', isEqualTo: 'approved')
        .get();

    // Convert Firestore documents to MembersDummyData objects
    final List<MembersDummyData> members = querySnapshot.docs
        .map((doc) => MembersDummyData.fromFirestore(doc))
        .toList();

    // Update the static list for backward compatibility
    memberdummyData = members;

    return members;
  } catch (e) {
    print('Error fetching members data: $e');
    return [];
  }
}
