import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerPage extends StatelessWidget {
  final String pdfUrl;

  PdfViewerPage({required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('syncfusion PDF viewer'),
      ),
      body: SfPdfViewer.network(pdfUrl),
    );
  }
}
