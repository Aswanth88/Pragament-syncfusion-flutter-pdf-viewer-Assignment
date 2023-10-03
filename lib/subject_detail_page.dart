import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
    FlutterDownloader.initialize();
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
            final title = unit['title'] ?? '';
            final downloadUrl = unit['download_url'] ?? '';
            final pdfUrl = unit['id'] ?? '';
            return ChapterUnit(
              title: title,
              downloadUrl: downloadUrl,
              pdfUrl: pdfUrl,
            );
          }).toList();
        });
      }
    } else {
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
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
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
                              _downloadPDF(
                                  chapterUnit.pdfUrl, chapterUnit.title);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                            ),
                            child: Text('Download PDF'),
                          ),
                          ElevatedButton(
                            onPressed: () {
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
                              primary: Colors.grey,
                            ),
                            child: Text('View PDF'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Future<void> _downloadPDF(String pdfUrl, String title) async {
  try {
    final output = await getExternalStorageDirectory();
    RegExp pathToDownloads = RegExp(r'.+0\/');
    final outputPath =
        '${pathToDownloads.stringMatch(output!.path).toString()}Download';
    final filePath = '$outputPath/$title.pdf';

    // Check if storage permission is not granted
    final status = await Permission.storage.request();
    if (status.isGranted) {
      // Permission granted, proceed with download
      final response = await http.get(Uri.parse(pdfUrl));
      if (response.statusCode == 200) {
        final pdfBytes = response.bodyBytes;
        final file = File(filePath);
        await file.writeAsBytes(pdfBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File has been downloaded'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print('Failed to download PDF');
      }
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied by the user, show a dialog or navigate to app settings
      openAppSettings();
    } else {
      // Permission denied by the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage permission denied'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (error) {
    print('Error: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('An error occurred while downloading the PDF'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

}
