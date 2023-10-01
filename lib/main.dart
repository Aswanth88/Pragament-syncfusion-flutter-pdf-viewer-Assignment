import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:weeklynuget/subject_detail_page.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  Map<String, dynamic> subjects = {};
  Random random = Random();

  @override
  void initState() {
    super.initState();
    getSubjectsFromApi();
  }

  Future<void> getSubjectsFromApi() async {
    try {
      final response = await http.get(Uri.parse(
          'https://www.eschool2go.org/api/v1/project/ba7ea038-2e2d-4472-a7c2-5e4dad7744e3'));

      if (response.statusCode == 200) {
        final subjectData = json.decode(response.body);
        setState(() {
          subjects = subjectData;
        });
      } else {
        print('Failed to fetch subjects: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching subjects: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subjects List'),
      ),
      body: SingleChildScrollView(
        child: buildSubjectsGrid(subjects),
      ),
    );
  }

  Widget buildSubjectsGrid(Map<String, dynamic> subjects) {
    if (subjects.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    List<Widget> subjectWidgets = [];

    subjects.forEach((key, value) {
      final String subjectName = value['name'];
      final Color randomColor = Color.fromRGBO(
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
        1.0,
      );

      subjectWidgets.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubjectDetailPage(
                  subjectName: subjectName,
                  iconColor: randomColor,
                ),
              ),
            );
          },
          child: Container(
            width: MediaQuery.of(context).size.width / 2,
            height: MediaQuery.of(context).size.height / 4,
            padding: EdgeInsets.all(10.0),
            margin: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: randomColor,
                  ),
                  child: Center(
                    child: Text(
                      subjectName.isNotEmpty ? subjectName[0] : '',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  subjectName,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });

    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: subjectWidgets,
    );
  }
}
