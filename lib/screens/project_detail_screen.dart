import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CrewDetail {
  final String title;
  final String author;
  final String createdAt;
  final String location;
  final String route;
  final String date;
  final String time;
  final int participants;
  final int capacity;
  final String additionalInfo;

  CrewDetail({
    required this.title,
    required this.author,
    required this.createdAt,
    required this.location,
    required this.route,
    required this.date,
    required this.time,
    required this.participants,
    required this.capacity,
    required this.additionalInfo,
  });

  factory CrewDetail.fromJson(Map<String, dynamic> json) {
    return CrewDetail(
      title: json['crewName'],
      author: json['userNickname'],
      createdAt: json['crewWriteTime'],
      location: json['projectSName'],
      route: json['projectDName'],
      date: json['projectDate'],
      time: json['projectTime'],
      participants: json['memberCount'],
      capacity: json['crewRecruitment'],
      additionalInfo: json['crewContent'],
    );
  }
}

class ProjectDetailScreen extends StatefulWidget {
  final int crewNumber;

  ProjectDetailScreen({required this.crewNumber});

  @override
  _ProjectDetailScreenState createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late Future<CrewDetail> crewDetailFuture;

  @override
  void initState() {
    super.initState();
    crewDetailFuture = fetchCrewDetail();
  }

  Future<CrewDetail> fetchCrewDetail() async {
    // Mock data를 사용하여 CrewDetail 객체 생성
    var mockData = {
      "crewNumber": 1,
      "userNumber": 1,
      "crewName": "크루AAA",
      "crewWriteTime": "2024년 04월 22일",
      "crewContent": "같이 플로깅 하실 분들 모집합니다~",
      "crewRecruitment": 5,
      "crewRoleNumber": 1,
      "crewProjectNumber": 1,
      "projectDate": "2024년 04월 22일",
      "projectTime": "10:00",
      "projectSLng": 127.058,
      "projectSLat": 37.512,
      "projectSName": "서울시 노원구 공릉동 서울산업대학교",
      "projectVLng": 127.058,
      "projectVLat": 37.512,
      "projectVName": "출발지",
      "projectDLng": 127.061,
      "projectDLat": 37.510,
      "projectDName": "목적지",
      "memberCount": 0,
      "userNickname": "user1"
    };

    // 실제 서버를 사용할 때
    // String url = '${dotenv.env['NGROK_URL']}/crew/detail/${widget.crewNumber}';
    // var response = await http.get(Uri.parse(url));
    // if (response.statusCode == 200) {
    //   return CrewDetail.fromJson(json.decode(response.body));
    // } else {
    //   throw Exception('Failed to load crew details');
    // }

    return CrewDetail.fromJson(mockData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Details'),
        actions: [
          Icon(Icons.share),
          SizedBox(width: 16),
          Icon(Icons.star_border),
          SizedBox(width: 16),
        ],
      ),
      body: FutureBuilder<CrewDetail>(
        future: crewDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return buildDetailLayout(snapshot.data!);
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget buildDetailLayout(CrewDetail detail) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 0, 0),
            child: Text(
              detail.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
            title: Text(detail.author),
            subtitle: Text(detail.createdAt),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('모임 위치', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(detail.location),
                Divider(),
                Text('루트', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(detail.route),
                Divider(),
                Text('날짜', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(detail.date),
                Divider(),
                Text('시간', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(detail.time),
                Divider(),
                Text('참여 인원', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('${detail.participants} / ${detail.capacity}명'),
                Divider(),
                Text('추가 정보', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(detail.additionalInfo),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
