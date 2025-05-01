import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class FacilitatorPdfViewer extends StatefulWidget {
  final String pdfUrl;
  final String title;
  final bool showDownloadButton;

  const FacilitatorPdfViewer({
    super.key,
    required this.pdfUrl,
    required this.title,
    this.showDownloadButton = true,
  });

  @override
  State<FacilitatorPdfViewer> createState() => _FacilitatorPdfViewerState();
}

class _FacilitatorPdfViewerState extends State<FacilitatorPdfViewer> {
  late PdfViewerController _pdfViewerController;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showDownloadButton)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement download functionality
                  },
                  icon: const Icon(Icons.download),
                  label: Text(
                    'Download PDF',
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: SfPdfViewer.network(
            widget.pdfUrl,
            controller: _pdfViewerController,
          ),
        ),
      ],
    );
  }
}
