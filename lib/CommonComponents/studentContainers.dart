import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';

import '../../../CommonComponents/displayCardIcons.dart';
import '../Themes/Constants/myColors.dart';

class StudentContainers extends StatefulWidget {
  final String image;
  final String name;
  final List<String> courses;
  final String courseAmount;
  final VoidCallback? onTap;

  const StudentContainers({
    super.key,
    required this.image,
    required this.name,
    required this.courses,
    required this.courseAmount,
    this.onTap,
  });

  @override
  State<StudentContainers> createState() => _StudentContainersState();
}

class _StudentContainersState extends State<StudentContainers> {
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
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: 300,
                  height: 2,
                  color: const Color.fromARGB(255, 189, 189, 189),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: DisplayCardIcons(
                      icon: Icons.library_books_outlined,
                      count: widget.courseAmount,
                      tooltipText: widget.courses.toString(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person,
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
