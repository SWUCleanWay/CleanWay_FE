import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class Project {
  final String projectName;
  final String projectDate;
  final int memberCount;
  final String isPastProject;

  Project({
    required this.projectName,
    required this.projectDate,
    required this.memberCount,
    required this.isPastProject,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectName: json['projectContent'],
      projectDate: json['projectDate'],
      memberCount: json['projectMemberCount'],
      isPastProject: json['isPastProject'],
    );
  }
}

class CrewDetailPage extends StatefulWidget {
  final int crewNumber;
  final String crewName;

  CrewDetailPage({Key? key, required this.crewNumber, required this.crewName}) : super(key: key);

  @override
  _CrewDetailPageState createState() => _CrewDetailPageState();
}

class _CrewDetailPageState extends State<CrewDetailPage> {
  late Future<List<Project>> projects;

  @override
  void initState() {
    super.initState();
    projects = fetchProjects();
  }

  Future<List<Project>> fetchProjects() async {
    String url = '${dotenv.env['NGROK_URL']}/crew-project/team/${widget.crewNumber}';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> projectsJson = json.decode(utf8.decode(response.bodyBytes));
      return projectsJson.map((json) => Project.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load projects');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.crewName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Project>>(
        future: projects,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }
            if (snapshot.hasData) {
              List<Project> upcomingProjects = snapshot.data!.where((p) => p.isPastProject == 'N').toList();
              List<Project> completedProjects = snapshot.data!.where((p) => p.isPastProject == 'Y').toList();
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...buildProjectSection('새 프로젝트', upcomingProjects),
                    ...buildProjectSection('완료된 프로젝트', completedProjects),
                  ],
                ),
              );
            }
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }

  List<Widget> buildProjectSection(String title, List<Project> projects) {
    return [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      for (var project in projects)
        ListTile(
          title: Text(project.projectName),
          subtitle: Text('${project.projectDate} - 참여 인원: ${project.memberCount}명'),
        ),
      Divider(),
    ];
  }
}
