import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../myutility.dart';

class StudentProgressListItem extends StatelessWidget {
  final String studentName;
  final String courseName;
  final double progress;

  const StudentProgressListItem({
    super.key,
    required this.studentName,
    required this.courseName,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      width: MyUtility(context).width * 0.78 - 330,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 247, 247, 247),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            const CircleAvatar(backgroundColor: Colors.grey),
            // ImageNetwork(
            //     image: imageUrl, // Use the passed image URL
            //     height: 40,
            //     width: 40,
            //     fitWeb: BoxFitWeb.cover,
            //     onError: const Icon(Icons.error,
            //         size: 40, color: Colors.grey), // Handle image errors
            //   ),
            const SizedBox(width: 15),
            Text(
              studentName,
              style:
                  GoogleFonts.kanit(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              courseName,
              style: GoogleFonts.montserrat(
                  fontSize: 13, fontWeight: FontWeight.w400),
            ),
            const Spacer(),
            SizedBox(
              width: MyUtility(context).width * 0.15,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
                backgroundColor: const Color.fromARGB(255, 221, 221, 221),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
