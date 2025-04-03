import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Constants/myColors.dart';

class LecturerPdfViewer extends StatefulWidget {
  final String pdfUrl;
  final bool showDownloadButton;
  final String title;

  const LecturerPdfViewer({
    super.key,
    required this.pdfUrl,
    this.showDownloadButton = false,
    required this.title,
  });

  @override
  State<LecturerPdfViewer> createState() => _LecturerPdfViewerState();
}

class _LecturerPdfViewerState extends State<LecturerPdfViewer> {
  late Future<String> _freshUrlFuture;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _freshUrlFuture = _getFreshUrl(widget.pdfUrl);
  }

  Future<String> _getFreshUrl(String storedPath) async {
    try {
      if (storedPath.startsWith('http')) {
        return storedPath;
      }

      final ref = FirebaseStorage.instance.ref(
        storedPath.contains('module_pdfs')
            ? storedPath
            : 'module_pdfs/$storedPath',
      );
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error getting fresh URL: $e');
      return storedPath;
    }
  }

  void _downloadPdf(String url) {
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', '${widget.title}.pdf')
      ..style.display = 'none';

    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<String>(
            future: _freshUrlFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Mycolors().darkTeal,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading PDF...',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: Colors.red[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading PDF',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.red[400],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error?.toString() ?? 'Unknown error',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final String viewerId = 'pdf-viewer-${widget.pdfUrl.hashCode}';
              final String freshUrl = snapshot.data!;

              // Try multiple PDF viewer services
              final List<String> viewerUrls = [
                'https://docs.google.com/viewer?url=${Uri.encodeComponent(freshUrl)}&embedded=true',
                'https://mozilla.github.io/pdf.js/web/viewer.html?file=${Uri.encodeComponent(freshUrl)}',
              ];

              int currentViewerIndex = 0;

              (ui.platformViewRegistry as dynamic).registerViewFactory(viewerId,
                  (int _) {
                final iframe = html.IFrameElement()
                  ..src = viewerUrls[currentViewerIndex]
                  ..style.border = 'none'
                  ..style.width = '100%'
                  ..style.height = '100%'
                  ..allowFullscreen = true;

                iframe.onError.listen((event) {
                  debugPrint(
                      "PdfViewerWeb: Viewer ${currentViewerIndex + 1} failed");
                  if (currentViewerIndex < viewerUrls.length - 1) {
                    currentViewerIndex++;
                    iframe.src = viewerUrls[currentViewerIndex];
                  } else {
                    iframe.remove();
                    final errorDiv = html.DivElement()
                      ..style.padding = '20px'
                      ..style.textAlign = 'center'
                      ..innerHtml = '''
                        <div style="display: flex; flex-direction: column; align-items: center; gap: 16px;">
                          <p style="color: #f44336; font-family: 'Montserrat', sans-serif; font-size: 16px; margin: 0;">
                            Unable to load PDF viewer
                          </p>
                          <button onclick="window.open('$freshUrl', '_blank')" 
                                  style="background-color: #2E7D32; color: white; border: none; border-radius: 4px; padding: 8px 16px; cursor: pointer; font-family: 'Montserrat', sans-serif;">
                            Open in New Tab
                          </button>
                        </div>
                      ''';
                    (ui.platformViewRegistry as dynamic)
                        .registerViewFactory(viewerId, (int _) => errorDiv);
                  }
                });

                return iframe;
              });

              return Stack(
                children: [
                  HtmlElementView(viewType: viewerId),
                  if (widget.showDownloadButton &&
                      !widget.title.toLowerCase().contains('activities'))
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: ElevatedButton.icon(
                        onPressed: () => _downloadPdf(freshUrl),
                        icon: const Icon(Icons.download),
                        label: Text(
                          'Download ${widget.title}',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Mycolors().green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          elevation: 2,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
