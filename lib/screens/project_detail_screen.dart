import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'crew_detail_screen.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:clean_way/token_manager.dart' as myToken;

class CrewDetail {
  final String title;
  final String crewName;
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
  final double projectSLng, projectSLat, projectVLng, projectVLat, projectDLng, projectDLat;

  CrewDetail({
    required this.title,
    required this.crewName,
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
    required this.projectDLat,
    required this.projectDLng,
    required this.projectSLat,
    required this.projectSLng,
    required this.projectVLat,
    required this.projectVLng,
  });

  factory CrewDetail.fromJson(Map<String, dynamic> json) {
    return CrewDetail(
      title: json['crewName'],
      crewName: json['crewName'],
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
      projectDLat: json['projectDLat']?.toDouble() ?? 0.0,
      projectDLng: json['projectDLng']?.toDouble() ?? 0.0,
      projectVLat: json['projecVLat']?.toDouble() ?? 0.0,
      projectVLng: json['projectVLng']?.toDouble() ?? 0.0,
      projectSLat: json['projectSLat']?.toDouble() ?? 0.0,
      projectSLng: json['projectSLng']?.toDouble() ?? 0.0,
    );
  }
}

class ProjectDetailScreen extends StatefulWidget {
  final int crewNumber;
  final String crewName;
  final int crewProjectNumber;

  ProjectDetailScreen({required this.crewNumber,required this.crewName, required this.crewProjectNumber });

  @override
  _ProjectDetailScreenState createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late Future<CrewDetail> crewDetailFuture;
  bool isJoined = false;
  NaverMapController? _controller;

  @override
  void initState() {
    super.initState();
    crewDetailFuture = fetchCrewDetail();
  }

  Future<CrewDetail> fetchCrewDetail() async {
    String? token = await myToken.TokenManager.instance.getToken();
    String? baseUrl = dotenv.env['NGROK_URL'];
    //String url = '${dotenv.env['NGROK_URL']}/crew/detail/${widget.crewNumber}';
    var url = Uri.parse('$baseUrl/crew/detail/${widget.crewNumber}');
    // var response = await http.get(Uri.parse(url));
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
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

  }

  Future<void> joinCrew() async {
    if (!isJoined) { // 아직 참여하지 않았다면
      // String url = '${dotenv.env['NGROK_URL']}/crew/join/${widget.crewNumber}';
      String? token = await myToken.TokenManager.instance.getToken();
      String? baseUrl = dotenv.env['NGROK_URL'];
      var url = Uri.parse('$baseUrl/crew/join/${widget.crewNumber}');
      try {
        // var response = await http.post(Uri.parse(url));
        var response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == 303) {
          setState(() {
            isJoined = true;
          });
          print("크루 가입 완료");
          // 상태가 변경된 후 다이얼로그를 표시하기 위해 대기
          Future.delayed(Duration.zero, () {
            showSuccessDialog('크루에 가입되었습니다.');
          });
        } else if (response.statusCode == 500) {
          showErrorDialog('이미 참여한 프로젝트입니다.');
        }
      } catch (e) {
        showErrorDialog('네트워크 오류: $e');
      }
    } else {
      showErrorDialog('프로젝트 참여에 실패했습니다. 다시 시도해주세요.');
    }
  }


  void showSuccessDialog(String message) {
    print("Showing Success Dialog: $message");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CrewDetailPage(
                    crewNumber: widget.crewNumber,
                    crewName: widget.crewName,
                  ),
                ),
              );
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void showErrorDialog(String message) {
    print("Showing Error Dialog: $message");
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
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CrewDetailPage(
                          crewNumber: widget.crewNumber,
                          crewName: widget.crewName,
                        ),
                      ),
                    );
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
                  onPressed: joinCrew,
                  child: Text(isJoined ? '참여됨' : '참여하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isJoined ? Colors.grey : Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    }
}

Widget buildDetailLayout(CrewDetail detail) {
  final markerS = NMarker(
      id: "start",
      position: NLatLng(detail.projectSLat, detail.projectSLng),
    );
  final markerV =NMarker(
      id: "via",
      position: NLatLng(detail.projectVLat, detail.projectVLng),
    );
  final markerD =NMarker(
      id: "destination",
      position: NLatLng(detail.projectDLat, detail.projectDLng),
    );

  final onMarkerinfoWindowS = NInfoWindow.onMarker(
    id: markerS.info.id,
    text: "출발지: ${detail.projectSName}",
  );
  final onMarkerinfoWindowV = NInfoWindow.onMarker(
    id: markerV.info.id,
    text: "경유지: ${detail.projectVName}",
  );
  final onMarkerinfoWindowD = NInfoWindow.onMarker(
    id: markerD.info.id,
    text: "도착지: ${detail.projectDName}",
  );

  final polyline = NPolylineOverlay(
    id: "route",
    coords: [
      NLatLng(detail.projectSLat, detail.projectSLng),
      NLatLng(detail.projectVLat, detail.projectVLng),
      NLatLng(detail.projectDLat, detail.projectDLng),
    ],
    color: Colors.blue,
    width: 5,
  );

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
                  height: 10,
                ),
            Container(
              height: 200,  // 지도의 높이 설정
              child: NaverMap(
                onMapReady: (controller) {
                  controller.updateCamera(
                      NCameraUpdate.scrollAndZoomTo(
                          target: NLatLng(detail.projectSLat, detail.projectSLng)
                      )
                  );
                  controller.addOverlayAll({markerS, markerV, markerD, polyline});
                  markerS.openInfoWindow(onMarkerinfoWindowS);
                  markerV.openInfoWindow(onMarkerinfoWindowV);
                  markerD.openInfoWindow(onMarkerinfoWindowD);
                },
              ),
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
