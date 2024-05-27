import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import  'crew_detail_screen.dart';

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
      title: json['projectTitle'] as String? ?? 'Unknown',
      author: json['userNickname'] as String? ?? 'Unknown',
      createdAt: json['crewWriteTime'] as String? ?? 'Unknown',
      location: json['projectSName'] as String? ?? 'Unknown',
      route: json['projectDName'] as String? ?? 'Unknown',
      date: json['projectDate'] as String? ?? 'Unknown',
      time: json['projectTime'] as String? ?? 'Unknown',
      participants: json['memberCount'] as int? ?? 0,
      capacity: json['crewRecruitment'] as int? ?? 0,
      additionalInfo: json['crewContent'] as String? ?? 'No additional info',
      projectSName: json['projectSName'] as String? ?? 'Unknown',
      projectVName: json['projectVName'] as String? ?? 'Unknown',
      projectDName: json['projectDName'] as String? ?? 'Unknown',
    );
  }
}

class CrewProjectDetailScreen extends StatefulWidget {
  final int crewNumber;
  final int crewProjectNumber;

  CrewProjectDetailScreen({required this.crewNumber, required this.crewProjectNumber});

  @override
  _CrewProjectDetailScreenState createState() => _CrewProjectDetailScreenState();
}

class _CrewProjectDetailScreenState extends State<CrewProjectDetailScreen> {
  late Future<CrewDetail> crewDetailFuture;
  bool hasJoined = false;

  @override
  void initState() {
    super.initState();
    crewDetailFuture = fetchCrewDetail();
  }

  Future<CrewDetail> fetchCrewDetail() async {
    String url = '${dotenv.env['NGROK_URL']}/crew-project/detail/${widget.crewNumber}/${widget.crewProjectNumber}';
    print("Fetching details from: $url");  // URL 로그 출력
    var response = await http.get(Uri.parse(url));
    print("Response status: ${response.statusCode}");  // 상태 코드 로그 출력

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
      if (responseData.isNotEmpty) {
        Map<String, dynamic> crewData = responseData.first;
        return CrewDetail.fromJson(crewData);
      } else {
        throw Exception("Received empty data from the server");
      }
    } else {
      print("Error fetching data: ${response.body}");  // 에러 내용 로그 출력
      throw Exception('Failed to load crew details with status code ${response.statusCode}');
    }
  }

  Future<void> joinProject() async {
    if (!hasJoined) {  // Check if not already joined
      String url = '${dotenv.env['NGROK_URL']}/crew-project/join/${widget.crewNumber}/${widget.crewProjectNumber}';
      try {
        var response = await http.post(Uri.parse(url));
        if (response.statusCode == 303) {
          setState(() {
            hasJoined = true;  // Update state to reflect join status
          });
        } else if (response.statusCode == 500) {
          showErrorDialog('Failed to join the project. Please try again.');
        }
      } catch (e) {
        showErrorDialog('Network error: $e');
      }
    } else {
      // 인증로직
      // authenticateUser();
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }


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
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: joinProject, 
          child: Text(hasJoined ? '인증하기' : '참여하기'),  
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
                Text('모임 위치', style: TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(detail.location),
                Divider(),
                Text('루트', style: TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold)),
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
                Text('날짜', style: TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(detail.date),
                Divider(),
                Text('시간', style: TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(detail.time),
                Divider(),
                Text('참여 인원', style: TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('${detail.participants} / ${detail.capacity}명'),
                Divider(),
                Text('추가 정보', style: TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold)),
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
