import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class MyProject extends StatefulWidget {
  @override
  _MyProjectState createState() => _MyProjectState();
}

class _MyProjectState extends State<MyProject> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("내 프로젝트"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "진행 예정"),
            Tab(text: "진행 완료"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ProjectList(isUpcoming: true),
          ProjectList(isUpcoming: false),
        ],
      ),
    );
  }
}

class ProjectList extends StatefulWidget {
  final bool isUpcoming;

  ProjectList({required this.isUpcoming});

  @override
  _ProjectListState createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectList> {
  late Future<List<Map<String, dynamic>>> futureProjects;

  Future<List<Map<String, dynamic>>> fetchProjects() async {
    String url = '${dotenv.env['NGROK_URL']}/mypage/myplogging';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var projectsJson = json.decode(utf8.decode(response.bodyBytes)) as List;
      return projectsJson.map((p) => p as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load projects');
    }
  }

  @override
  void initState() {
    super.initState();
    futureProjects = fetchProjects();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futureProjects,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            var filteredProjects = snapshot.data!.where((project) {
              return (widget.isUpcoming && project['isPastProject'] == 'N') || (!widget.isUpcoming && project['isPastProject'] == 'Y');
            }).toList();

            return ListView.builder(
              itemCount: filteredProjects.length,
              itemBuilder: (context, index) {
                var project = filteredProjects[index];
                return ListTile(
                  title: Text(project['projectTitle'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project['projectDate']),
                      Text(project['crewName'], style: TextStyle(color: Colors.grey))
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

