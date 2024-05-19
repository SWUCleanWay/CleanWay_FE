import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

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
  final String projectSName, projectVName, projectDName;

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
    required this.projectSName,
    required this.projectVName,
    required this.projectDName,
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
      projectSName: json['projectSName'],
      projectVName: json['projectVName'],
      projectDName: json['projectDName'],
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
    /*var mockData = {
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
    };*/

    // 실제 서버를 사용할 때
    String url = '${dotenv.env['NGROK_URL']}/crew/detail/${widget.crewNumber}';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> crewList = json.decode(utf8.decode(response.bodyBytes));
      // crewNumber에 해당하는 객체를 찾습니다.
      Map<String, dynamic>? crewData = crewList.firstWhere(
              (element) => element['crewNumber'] == widget.crewNumber,
          orElse: () => null
      );

      if (crewData != null) {
        // 조건에 맞는 데이터로 CrewDetail 인스턴스를 생성합니다.
        return CrewDetail.fromJson(crewData);
      } else {
        // crewNumber에 해당하는 데이터가 없는 경우 예외를 발생시킵니다.
        throw Exception('Crew with number ${widget.crewNumber} not found');
      }
    } else {
      // HTTP 요청이 실패한 경우 예외를 발생시킵니다.
      throw Exception('Failed to load crew details with status code ${response.statusCode}');
    }

    //return CrewDetail.fromJson(mockData);
  }

  /*Widget buildDetailLayout(CrewDetail detail) {
    // 마커를 생성합니다.
    final List<Marker> markers = [
      Marker(
        markerId: 'start',
        position: LatLng(detail.projectSLat, detail.projectSLng),
        captionText: '출발지: ${detail.projectSName}',
        captionColor: Colors.black,
        captionTextSize: 14.0,
        captionOffset: 20,
        icon: MarkerIcons.black,
        alpha: 0.8,
      ),
      Marker(
        markerId: 'via',
        position: LatLng(detail.projectVLat, detail.projectVLng),
        captionText: '경유지: ${detail.projectVName}',
        captionColor: Colors.black,
        captionTextSize: 14.0,
        captionOffset: 20,
        icon: MarkerIcons.blue,
        alpha: 0.8,
      ),
      Marker(
        markerId: 'destination',
        position: LatLng(detail.projectDLat, detail.projectDLng),
        captionText: '목적지: ${detail.projectDName}',
        captionColor: Colors.black,
        captionTextSize: 14.0,
        captionOffset: 20,
        icon: MarkerIcons.yellow,
        alpha: 0.8,
      ),
    ];*/


    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Implement 'Browse Around' functionality
                  },
                  child: Text('둘러보기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Implement 'Join' functionality
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('참여하기'),
                ),
              ),
            ],
          ),
        ),
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
                Text('출발지 : ${detail.projectSName}'),
                Text('경유지 : ${detail.projectVName}'),
                Text('목적지 : ${detail.projectDName}'),
                SizedBox(
                  /*height: 200,  // 지도의 높이를 설정합니다.
                  child: NaverMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(detail.projectSLat, detail.projectSLng),  // 초기 위치를 출발지로 설정합니다.
                      zoom: 13,  // 초기 줌 레벨을 설정합니다.
                    ),
                    markers: markers,  // 위에서 정의한 마커 리스트를 사용합니다.
                    onMapCreated: onMapCreated,
                  ),*/
                  height: 10,
                ),
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
