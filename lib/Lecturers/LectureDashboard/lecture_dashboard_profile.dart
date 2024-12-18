import 'package:a4m/myutility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LectureDashboardProfile extends StatefulWidget {
  final String lecturerId;

  const LectureDashboardProfile({
    Key? key,
    required this.lecturerId, // Pass the lecturer ID to fetch data
  }) : super(key: key);

  @override
  State<LectureDashboardProfile> createState() =>
      _LectureDashboardProfileState();
}

class _LectureDashboardProfileState extends State<LectureDashboardProfile> {
  String profileImageUrl = 'images/person2.png'; // Default profile image
  String userName = 'Loading...'; // Placeholder name
  final double userRating = 3.5; // Example rating, replace if needed

  @override
  void initState() {
    super.initState();
    _fetchLecturerDetails();
  }

  Future<void> _fetchLecturerDetails() async {
    try {
      print("Fetching details for lecturer ID: ${widget.lecturerId}");

      // Directly fetch the document using the lecturerId
      var lecturerDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.lecturerId)
          .get();

      if (lecturerDoc.exists) {
        var lecturerData = lecturerDoc.data();

        setState(() {
          userName = lecturerData?['name'] ?? 'Unknown Lecturer';
          profileImageUrl = lecturerData?['profileImageUrl'] ?? profileImageUrl;
        });

        print("Fetched name: $userName, Profile Image: $profileImageUrl");
      } else {
        setState(() {
          userName = 'Lecturer Not Found';
        });
        print("No lecturer found with ID: ${widget.lecturerId}");
      }
    } catch (e) {
      print("Error fetching lecturer details: $e");
      setState(() {
        userName = 'Error Loading Name';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MyUtility(context).width * 0.26,
        height: MyUtility(context).height * 0.52,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 2.0,
              spreadRadius: 2.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            CircleAvatar(
              radius: 88,
              backgroundImage: NetworkImage(profileImageUrl),
            ),
            const SizedBox(height: 16.0),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.black,
                  size: 20.0,
                ),
                const SizedBox(width: 4.0),
                Text(
                  '${userRating.toStringAsFixed(1)} Rating',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
