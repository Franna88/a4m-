import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Constants/myColors.dart';

class StudentPdfViewer extends StatefulWidget {
  final String pdfUrl;
  final bool showDownloadButton;
  final String title;

  const StudentPdfViewer({
    Key? key,
    required this.pdfUrl,
    this.showDownloadButton = false,
    required this.title,
  }) : super(key: key);

  @override
  State<StudentPdfViewer> createState() => _StudentPdfViewerState();
}

class _StudentPdfViewerState extends State<StudentPdfViewer> {
  late Future<String> _freshUrlFuture;

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
    // Create an anchor element with download attribute
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', '${widget.title}.pdf')
      ..style.display = 'none';

    // Add to document body
    html.document.body?.children.add(anchor);

    // Trigger click and remove
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
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Center(
                  child: Text(
                      'Error loading PDF: ${snapshot.error ?? 'Unknown error'}'),
                );
              }

              final String viewerId = 'pdf-viewer-${widget.pdfUrl.hashCode}';
              final String freshUrl = snapshot.data!;

              // Try multiple PDF viewer services
              final List<String> viewerUrls = [
                // Google Docs Viewer
                'https://docs.google.com/viewer?url=${Uri.encodeComponent(freshUrl)}&embedded=true',
                // PDF.js Viewer
                'https://mozilla.github.io/pdf.js/web/viewer.html?file=${Uri.encodeComponent(freshUrl)}',
                // PDF24 Viewer
                'https://viewer.pdf24.org/online-pdf-viewer.html?file=${Uri.encodeComponent(freshUrl)}',
                // PDF Viewer
                'https://www.pdfviewer.org/view?file=${Uri.encodeComponent(freshUrl)}',
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

                // Handle viewer errors and try next viewer
                iframe.onError.listen((event) {
                  debugPrint(
                      "PdfViewerWeb: Viewer ${currentViewerIndex + 1} failed");
                  if (currentViewerIndex < viewerUrls.length - 1) {
                    currentViewerIndex++;
                    iframe.src = viewerUrls[currentViewerIndex];
                  } else {
                    // If all viewers fail, show error message
                    iframe.remove();
                    final errorDiv = html.DivElement()
                      ..style.padding = '20px'
                      ..style.textAlign = 'center'
                      ..innerHtml = '''
                        <p style="color: red;">Unable to load PDF. Please try opening in a new tab.</p>
                        <button onclick="window.open('$freshUrl', '_blank')" 
                                style="padding: 10px 20px; margin-top: 10px; cursor: pointer;">
                          Open in New Tab
                        </button>
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
                  if (widget.showDownloadButton)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: ElevatedButton.icon(
                        onPressed: () => _downloadPdf(freshUrl),
                        icon: Icon(Icons.download),
                        label: Text('Download ${widget.title}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Mycolors().green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
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
