import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

class LectureDashboardProfile extends StatelessWidget {
  final String? profileImageUrl = 'images/person2.png';
  final String? userName = 'Stephan Harmse';
  final double? userRating = 3.5;

  const LectureDashboardProfile({
    Key? key,
  }) : super(key: key);

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
            Text(
              'Welcome Back',
              style: const TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            CircleAvatar(
              radius: 88,
              backgroundImage: NetworkImage(profileImageUrl!),
            ),
            const SizedBox(height: 16.0),
            Text(
              userName!,
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
                  '${userRating?.toStringAsFixed(1)} Rating',
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
