import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart'; // Import the path_provider package

import 'pdf_viewer_page.dart';

class ChapterUnit {
  final String title;
  final String downloadUrl;
  final String pdfUrl;

  ChapterUnit({
    required this.title,
    required this.downloadUrl,
    required this.pdfUrl,
  });
}

class SubjectDetailPage extends StatefulWidget {
  final String subjectName;
  final Color iconColor;

  SubjectDetailPage({required this.subjectName, Color? iconColor})
      : iconColor = iconColor ?? Colors.black;

  @override
  _SubjectDetailPageState createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<SubjectDetailPage> {
  List<ChapterUnit> chapterUnits = [];

  @override
  void initState() {
    super.initState();
    if (widget.subjectName == 'Environmental Education') {
      fetchChapterUnits();
    }
    FlutterDownloader.initialize(); // Initialize the downloader
  }

  Future<void> fetchChapterUnits() async {
    final url =
        'https://www.eschool2go.org/api/v1/project/ba7ea038-2e2d-4472-a7c2-5e4dad7744e3?path=Environmental%20Education';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        setState(() {
          chapterUnits = data.map((unit) {
            final title = unit['title'] ?? ''; // Handle potential null value
            final downloadUrl = unit['download_url'] ?? ''; // Handle potential null value
            final pdfUrl = unit['id'] ?? ''; // Use 'id' as PDF URL
            return ChapterUnit(
              title: title,
              downloadUrl: downloadUrl,
              pdfUrl: pdfUrl, // Use 'id' as PDF URL
            );
          }).toList();
        });
      }
    } else {
      // Handle errors here
      print('Failed to fetch data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectName),
      ),
      body: chapterUnits.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
  itemCount: chapterUnits.length,
  itemBuilder: (context, index) {
    final chapterUnit = chapterUnits[index];
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), // Add border radius
        color: Colors.white, // Add a background color
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // Add shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chapterUnit.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Handle downloading the chapter PDF here
                  _downloadPDF(chapterUnit.pdfUrl, chapterUnit.title);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green, // Green color for download button
                ),
                child: Text('Download PDF'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle opening the PDF viewer here
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PdfViewerPage(
                        pdfUrl: chapterUnit.pdfUrl,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.grey, // Grey color for view button
                ),
                child: Text('View PDF'),
              ),
            ],
          ),
        ],
      ),
    );
  },
)

    );
  }

  Future<void> _downloadPDF(String pdfUrl, String title) async {
    final directory = await getDownloadsDirectory(); // Use getDownloadsDirectory from path_provider
    if (directory != null) {
      final taskId = await FlutterDownloader.enqueue(
        url: pdfUrl,
        savedDir: directory.path,
        fileName: '$title.pdf',
        showNotification: true,
        openFileFromNotification: true,
      );
    } else {
      // Handle the case where the downloads directory is null
      print('Downloads directory is null');
    }
  }
}
