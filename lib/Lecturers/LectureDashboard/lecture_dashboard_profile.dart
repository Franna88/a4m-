import 'package:a4m/myutility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';

class LectureDashboardProfile extends StatefulWidget {
  final String lecturerId;

  const LectureDashboardProfile({
    super.key,
    required this.lecturerId,
  });

  @override
  State<LectureDashboardProfile> createState() =>
      _LectureDashboardProfileState();
}

class _LectureDashboardProfileState extends State<LectureDashboardProfile> {
  String profileImageUrl = 'images/person2.png';
  String userName = 'Loading...';
  final double userRating = 3.5;

  @override
  void initState() {
    super.initState();
    _fetchLecturerDetails();
  }

  Future<void> _fetchLecturerDetails() async {
    try {
      var lecturerDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.lecturerId)
          .get();

      if (lecturerDoc.exists) {
        var lecturerData = lecturerDoc.data();
        setState(() {
          userName = lecturerData?['name'] ?? 'Unknown Lecturer';
          profileImageUrl =
              lecturerData?['profileImageUrl'] ?? 'images/person2.png';
        });
      } else {
        setState(() {
          userName = 'Lecturer Not Found';
        });
      }
    } catch (e) {
      setState(() {
        userName = 'Error Loading Name';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200, width: 2),
            ),
            child: ClipOval(
              child: profileImageUrl.startsWith('http')
                  ? ImageNetwork(
                      image: profileImageUrl,
                      height: 80,
                      width: 80,
                      duration: 500,
                      onLoading: const Center(
                        child: CircularProgressIndicator(),
                      ),
                      onError: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('images/person2.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  : Image.asset(
                      profileImageUrl,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          Text(
            userName,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 20.0,
              ),
              const SizedBox(width: 4.0),
              Text(
                '${userRating.toStringAsFixed(1)} Rating',
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
