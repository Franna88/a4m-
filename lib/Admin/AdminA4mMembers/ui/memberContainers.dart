import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';

import '../../../CommonComponents/displayCardIcons.dart';
import '../../../Themes/Constants/myColors.dart';

class MemberContainers extends StatefulWidget {
  final bool? isLecturer;
  final bool? isContentDev;
  final bool? isFacilitator;
  final String image;
  final String name;
  final String number;
  final String? studentAmount;
  final String? contentTotal;
  final String? rating;
  final VoidCallback? onTap;
  final Widget? trailing;

  const MemberContainers({
    super.key,
    this.isLecturer,
    this.isContentDev,
    this.isFacilitator,
    required this.image,
    required this.name,
    required this.number,
    this.studentAmount,
    this.contentTotal,
    this.rating,
    this.onTap,
    this.trailing,
  });

  @override
  State<MemberContainers> createState() => _MemberContainersState();
}

class _MemberContainersState extends State<MemberContainers> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Material(
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
              Stack(
                children: [
                  // Profile Image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: widget.image.startsWith('http') ||
                            widget.image.startsWith('https')
                        ? ImageNetwork(
                            image: widget.image,
                            height: 180,
                            width: 250,
                            fitAndroidIos: BoxFit.cover,
                            fitWeb: BoxFitWeb.cover,
                            onLoading: const Center(
                              child: CircularProgressIndicator(),
                            ),
                            onError: Image.asset(
                              'images/person1.png',
                              height: 180,
                              width: 250,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            widget.image,
                            height: 180,
                            width: 250,
                            fit: BoxFit.cover,
                          ),
                  ),
                  // Green Gradient Overlay
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Mycolors().green.withOpacity(0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Rating Tag for Lecturers
                  if (widget.isLecturer == true && widget.rating != null)
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Mycolors().darkTeal,
                        ),
                        child: Text(
                          widget.rating!,
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
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
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 5, bottom: 5),
                child: Text(
                  widget.number,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
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
              if (widget.isContentDev == true)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: DisplayCardIcons(
                        icon: Icons.library_books_outlined,
                        count: widget.contentTotal ?? '',
                        tooltipText: 'Courses',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.edit_outlined,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Content Dev',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              if (widget.isLecturer == true)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: DisplayCardIcons(
                        icon: Icons.person_outline,
                        count: widget.studentAmount ?? '',
                        tooltipText: 'Students',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          Image.asset('images/hatIcon.png'),
                          const SizedBox(width: 8),
                          Text(
                            'Lecturer',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (widget.trailing != null) ...[
                            const SizedBox(width: 8),
                            widget.trailing!,
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              if (widget.isFacilitator == true)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: DisplayCardIcons(
                        icon: Icons.person_outline,
                        count: widget.studentAmount ?? '',
                        tooltipText: 'Students',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.groups,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Facilitator',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              // Add bottom section for students
              if (widget.isLecturer == false &&
                  widget.isContentDev != true &&
                  widget.isFacilitator != true)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: DisplayCardIcons(
                        icon: Icons.book_outlined,
                        count: widget.studentAmount ?? '0',
                        tooltipText: 'Courses',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.school_outlined,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Student',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (widget.trailing != null) ...[
                            const SizedBox(width: 8),
                            widget.trailing!,
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
