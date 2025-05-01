import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/Themes/text_style.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;

class CoursePreviewPdf extends StatefulWidget {
  final String pdfUrl;
  final String courseName;
  final VoidCallback onBack;

  const CoursePreviewPdf({
    super.key,
    required this.pdfUrl,
    required this.courseName,
    required this.onBack,
  });

  @override
  State<CoursePreviewPdf> createState() => _CoursePreviewPdfState();
}

class _CoursePreviewPdfState extends State<CoursePreviewPdf> {
  late String viewerId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      viewerId = 'pdf-viewer-${DateTime.now().millisecondsSinceEpoch}';
      _initializeWebPdfViewer();
    }
  }

  void _initializeWebPdfViewer() {
    // Register the view factory
    ui.platformViewRegistry.registerViewFactory(viewerId, (int viewId) {
      // Create an iframe element
      final iframe = html.IFrameElement()
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..src =
            'https://docs.google.com/viewer?url=${Uri.encodeComponent(widget.pdfUrl)}&embedded=true';

      return iframe;
    });

    // Set loading to false after a short delay to allow the iframe to load
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Mycolors().darkTeal),
              onPressed: widget.onBack,
            ),
            Expanded(
              child: Text(
                'Preview: ${widget.courseName}',
                style: MyTextStyles(context).subHeaderBlack,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Divider(
          color: Mycolors().green,
          thickness: 6,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  HtmlElementView(viewType: viewerId),
                  if (isLoading)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Mycolors().darkTeal,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading PDF...',
                            style: MyTextStyles(context).mediumBlack,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
