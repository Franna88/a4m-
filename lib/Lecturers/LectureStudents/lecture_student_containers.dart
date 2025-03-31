import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';

import '../../../CommonComponents/displayCardIcons.dart';
import '../../../Constants/myColors.dart';

class LectureStudentContainers extends StatefulWidget {
  final bool? isLecturer;
  final bool? isContentDev;
  final bool? isFacilitator;
  final bool? isStudent;
  final String image;
  final String name;
  final String number;
  final String? studentAmount;
  final String? contentTotal;
  final String? rating;
  final VoidCallback? onMessageTap;
  const LectureStudentContainers(
      {super.key,
      this.isLecturer,
      this.isContentDev,
      this.isFacilitator,
      this.isStudent,
      required this.image,
      required this.name,
      required this.number,
      this.studentAmount,
      this.contentTotal,
      this.rating,
      this.onMessageTap});

  @override
  State<LectureStudentContainers> createState() =>
      _LectureStudentContainersState();
}

class _LectureStudentContainersState extends State<LectureStudentContainers> {
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(15),
      elevation: 5,
      child: Container(
        height: 300,
        width: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 250,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Stack(
                  children: [
                    // Profile Image
                    Positioned.fill(
                      child: widget.image.startsWith('http') &&
                              widget.image.isNotEmpty
                          ? ImageNetwork(
                              image: widget.image,
                              fitWeb: BoxFitWeb.cover,
                              fitAndroidIos: BoxFit.cover,
                              height: 180,
                              width: 250,
                              duration: 500,
                              onLoading: const Center(
                                child: CircularProgressIndicator(),
                              ),
                              onError: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  image: const DecorationImage(
                                    image: AssetImage('images/person2.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('images/person2.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                    ),
                    // Gradient Overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Mycolors().green,
                              const Color.fromARGB(0, 255, 255, 255),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.name,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: widget.onMessageTap,
              icon: Icon(
                Icons.mail_outline, // Replace with your desired icon
                color: Colors.white, // White icon
                size: 25,
              ),
              label: Text(
                'Message', // Replace with your desired text
                style: TextStyle(
                  color: Colors.white, // White text
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4880FF), // Button background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
              ),
            ),

            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: 300,
                height: 2,
                color: const Color.fromARGB(255, 189, 189, 189),
              ),
            ),
            // Visibility(
            //   visible: widget.isContentDev == true,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Padding(
            //         padding: const EdgeInsets.all(15),
            //         child: DisplayCardIcons(
            //             icon: Icons.library_books_outlined,
            //             count: widget.contentTotal ?? '',
            //             tooltipText: 'Courses'),
            //       ),
            //       Padding(
            //         padding: const EdgeInsets.all(15),
            //         child: Row(
            //           children: [
            //             Icon(
            //               Icons.edit_outlined,
            //               color: Colors.grey,
            //             ),
            //             const SizedBox(
            //               width: 8,
            //             ),
            //             Text(
            //               'Content Dev',
            //               style: GoogleFonts.montserrat(
            //                   fontSize: 12,
            //                   color: Colors.grey,
            //                   fontWeight: FontWeight.w600),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // Visibility(
            //   visible: widget.isLecturer == true,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Padding(
            //         padding: const EdgeInsets.all(15),
            //         child: DisplayCardIcons(
            //             icon: Icons.person_outline,
            //             count: widget.studentAmount ?? '',
            //             tooltipText: 'Students'),
            //       ),
            //       Padding(
            //         padding: const EdgeInsets.all(15),
            //         child: Row(
            //           children: [
            //             Image.asset('images/hatIcon.png'),
            //             const SizedBox(
            //               width: 8,
            //             ),
            //             Text(
            //               'Lecturer',
            //               style: GoogleFonts.montserrat(
            //                   fontSize: 12,
            //                   color: Colors.grey,
            //                   fontWeight: FontWeight.w600),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // Visibility(
            //   visible: widget.isFacilitator == true,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Padding(
            //         padding: const EdgeInsets.all(15),
            //         child: DisplayCardIcons(
            //             icon: Icons.person_outline,
            //             count: widget.studentAmount ?? '',
            //             tooltipText: 'Students'),
            //       ),
            //       Padding(
            //         padding: const EdgeInsets.all(15),
            //         child: Row(
            //           children: [
            //             const Icon(
            //               Icons.groups,
            //               color: Colors.grey,
            //             ),
            //             const SizedBox(
            //               width: 8,
            //             ),
            //             Text(
            //               'Facilitator',
            //               style: GoogleFonts.montserrat(
            //                   fontSize: 12,
            //                   color: Colors.grey,
            //                   fontWeight: FontWeight.w600),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: DisplayCardIcons(
                      icon: Icons.library_books,
                      count: widget.studentAmount ?? '',
                      tooltipText: 'Students'),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.groups,
                        color: Colors.grey,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Student',
                        style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
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
