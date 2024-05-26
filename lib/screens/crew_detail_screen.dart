import 'package:clean_way/screens/create_crew_project_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import './crew_project_detail_screen.dart';

class Project {
  final int crewProjectNumber;
  final String projectName;
  final String projectDate;
  final int memberCount;
  final String isPastProject;

  Project({
    required this.crewProjectNumber,
    required this.projectName,
    required this.projectDate,
    required this.memberCount,
    required this.isPastProject,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      crewProjectNumber: json['crewProjectNumber']as int? ?? 0,
      projectName: json['projectTitle'] as String? ?? 'Unknown',
      projectDate: json['projectDate'] as String? ?? 'Unknown',
      memberCount: json['projectMemberCount'] as int? ?? 0,
      isPastProject: json['isPastProject'] as String? ?? 'Unknown',
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

    // // 서버 연결 대신 mock data 반환
    // var mockData = '[{"crewProjectNumber": 1, "projectContent": "Sample Project", "projectDate": "2024-01-01", "projectMemberCount": 10, "isPastProject": "N"}]';
    // List<dynamic> projectsJson = json.decode(mockData);
    // return projectsJson.map((json) => Project.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.crewName),
      ),
      body: FutureBuilder<List<Project>>(
        future: projects,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              List<Project> pastProjects = snapshot.data!.where((p) => p.isPastProject == 'Y').toList();
              List<Project> upcomingProjects = snapshot.data!.where((p) => p.isPastProject == 'N').toList();

              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    sectionHeader("모집 중인 프로젝트"),
                    projectList(upcomingProjects),
                    SizedBox(height: 20),
                    sectionHeader("지난 프로젝트"),
                    projectList(pastProjects),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
          }
          return CircularProgressIndicator();
        },
      ),
      floatingActionButton: floatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Widget sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget projectList(List<Project> projects) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: projects.length,
      itemBuilder: (context, index) {
        Project project = projects[index];
        return ListTile(
          title: Text(project.projectName),
          subtitle: Text('Date: ${project.projectDate}'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CrewProjectDetailScreen(crewNumber: widget.crewNumber, crewProjectNumber: project.crewProjectNumber),
              ),
            );
          },
        );
      },
    );
  }

  Widget floatingActionButton(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 64.0),
          child: FloatingActionButton(
            onPressed: () => showAddMenu(context),
            child: Icon(Icons.add),
            tooltip: 'Create Project',
            shape: CircleBorder(),
          ),
        );
      },
    );
  }

  void showAddMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final Offset buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);
    final RelativeRect position = RelativeRect.fromLTRB(
      buttonPosition.dx - 180,
      buttonPosition.dy - button.size.height / 2,
      buttonPosition.dx,
      overlay.size.height - buttonPosition.dy,
    );
    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => CreateCrewProjectScreen(crewName: widget.crewName, crewNumber: widget.crewNumber,)),
              );
            },
            child: Text('크루 프로젝트 생성하기'),
          ),
        ),
        PopupMenuItem(
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
              // Navigator.of(context).push(
              //   MaterialPageRoute(builder: (context) => Create()),
              // );
            },
            child: Text('크루원 모집하기'),
          ),
        ),
      ],
    );
  }
}