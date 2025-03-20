import 'dart:html' as html;
import 'dart:ui_web' as ui; // Use dart:ui_web for Flutter Web
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // For opening PDFs in a new tab
import 'package:firebase_storage/firebase_storage.dart'; // Firebase for fresh URLs

class PdfViewerWeb extends StatelessWidget {
  final String pdfUrl;

  PdfViewerWeb({Key? key, required this.pdfUrl}) : super(key: key) {
    print("PdfViewerWeb: Received PDF URL: $pdfUrl");
  }

  Future<String> _getFreshPdfUrl(String storedPath) async {
    try {
      if (storedPath.isEmpty) return '';

      // Handle both direct URLs and storage paths
      if (storedPath.startsWith('http')) {
        return storedPath;
      }

      final ref = FirebaseStorage.instance.ref(
          storedPath.contains('module_pdfs')
              ? storedPath
              : 'module_pdfs/$storedPath');
      final freshUrl = await ref.getDownloadURL();
      print("🔄 Fresh Firebase PDF URL: $freshUrl");
      return freshUrl;
    } catch (e) {
      print("❌ Error fetching fresh PDF URL: $e");
      return storedPath;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String viewId = 'pdf-viewer-${pdfUrl.hashCode}';
    print("PdfViewerWeb: Building HtmlElementView with viewId: $viewId");

    return FutureBuilder<String>(
      future: _getFreshPdfUrl(pdfUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text("Error loading PDF"));
        }

        final String freshUrl = snapshot.data!;
        print("PdfViewerWeb: Processing URL: $freshUrl");

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

        (ui.platformViewRegistry as dynamic).registerViewFactory(viewId,
            (int _) {
          final iframe = html.IFrameElement()
            ..src = viewerUrls[currentViewerIndex]
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..allowFullscreen = true;

          // Handle viewer errors and try next viewer
          iframe.onError.listen((event) {
            print("PdfViewerWeb: Viewer ${currentViewerIndex + 1} failed");
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
                  .registerViewFactory(viewId, (int _) => errorDiv);
            }
          });

          return iframe;
        });

        return Column(
          children: [
            Expanded(
              child: HtmlElementView(viewType: viewId),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      if (await canLaunchUrl(Uri.parse(freshUrl))) {
                        await launchUrl(Uri.parse(freshUrl),
                            mode: LaunchMode.externalApplication);
                      } else {
                        print("PdfViewerWeb: Unable to open PDF in a new tab.");
                      }
                    },
                    icon: Icon(Icons.open_in_new),
                    label: Text("Open in New Tab"),
                  ),
                  SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: () async {
                      final downloadUrl = freshUrl;
                      final anchor = html.AnchorElement(href: downloadUrl)
                        ..setAttribute("download", "document.pdf")
                        ..click();
                    },
                    icon: Icon(Icons.download),
                    label: Text("Download PDF"),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
