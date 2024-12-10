import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../CommonComponents/displayCardIcons.dart';
import '../../../Constants/myColors.dart';

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
  const MemberContainers(
      {super.key,
      this.isLecturer,
      this.isContentDev,
      this.isFacilitator,
      required this.image,
      required this.name,
      required this.number,
      this.studentAmount,
      this.contentTotal,
      this.rating});

  @override
  State<MemberContainers> createState() => _MemberContainersState();
}

class _MemberContainersState extends State<MemberContainers> {
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
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                image: DecorationImage(
                  image: AssetImage(widget.image),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    height: 60,
                    width: 320,
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
                    child: Visibility(
                      visible: widget.isLecturer == true,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Container(
                            height: 30,
                            width: 80,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Mycolors().darkTeal),
                            child: Center(
                              child: Text(
                                widget.rating ?? '',
                                style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 5, bottom: 5),
              child: Text(
                widget.number,
                style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600),
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
            Visibility(
              visible: widget.isContentDev == true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: DisplayCardIcons(
                        icon: Icons.library_books_outlined,
                        count: widget.contentTotal ?? '',
                        tooltipText: 'Courses'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          color: Colors.grey,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          'Content Dev',
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
            ),
            Visibility(
              visible: widget.isLecturer == true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: DisplayCardIcons(
                        icon: Icons.person_outline,
                        count: widget.studentAmount ?? '',
                        tooltipText: 'Students'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        Image.asset('images/hatIcon.png'),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          'Lecturer',
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
            ),
            Visibility(
              visible: widget.isFacilitator == true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: DisplayCardIcons(
                        icon: Icons.person_outline,
                        count: widget.studentAmount ?? '',
                        tooltipText: 'Students'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
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
                          'Admin',
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
            ),
          ],
        ),
      ),
    );
  }
}
