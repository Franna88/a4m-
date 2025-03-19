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

      final ref = FirebaseStorage.instance.refFromURL(storedPath);
      final freshUrl = await ref.getDownloadURL();
      print("🔄 Fresh Firebase PDF URL: $freshUrl");
      return freshUrl;
    } catch (e) {
      print("❌ Error fetching fresh PDF URL: $e");
      return storedPath; // Fallback to original URL
    }
  }

  @override
  Widget build(BuildContext context) {
    final String viewId = 'pdf-viewer-${pdfUrl.hashCode}';
    print("PdfViewerWeb: Building HtmlElementView with viewId: $viewId");

    return FutureBuilder<String>(
      future: _getFreshPdfUrl(pdfUrl), // Fetch fresh URL
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text("Error loading PDF"));
        }

        final String freshUrl = snapshot.data!;
        final String decodedUrl = Uri.decodeComponent(freshUrl);

        final String iframeUrl =
            'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(decodedUrl)}';

        // Fallback Viewer: Google Drive Viewer
        final String driveViewerUrl =
            'https://drive.google.com/viewerng/viewer?embedded=true&url=${Uri.encodeComponent(decodedUrl)}';

        print("PdfViewerWeb: Decoded PDF URL: $decodedUrl");
        print("PdfViewerWeb: Constructed iframe URL: $iframeUrl");

        (ui.platformViewRegistry as dynamic).registerViewFactory(viewId,
            (int _) {
          final iframe = html.IFrameElement()
            ..src = iframeUrl // Try Google Docs Viewer first
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..allowFullscreen = true;

          // If Google Docs Viewer fails, switch to Google Drive Viewer
          iframe.onError.listen((event) {
            print(
                "PdfViewerWeb: Google Docs Viewer failed. Trying Google Drive Viewer.");
            iframe.src = driveViewerUrl;
          });

          return iframe;
        });

        return Column(
          children: [
            Expanded(
              child: HtmlElementView(viewType: viewId),
            ),
            TextButton(
              onPressed: () async {
                if (await canLaunchUrl(Uri.parse(freshUrl))) {
                  await launchUrl(Uri.parse(freshUrl),
                      mode: LaunchMode.externalApplication);
                } else {
                  print("PdfViewerWeb: Unable to open PDF in a new tab.");
                }
              },
              child: Text("Open in New Tab"),
            ),
          ],
        );
      },
    );
  }
}
