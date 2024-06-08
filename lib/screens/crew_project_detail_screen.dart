import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:clean_way/token_manager.dart' as myToken;

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
  final String isPastProject;
  final String projectSName, projectVName, projectDName;
  final double projectSLng, projectSLat, projectVLng, projectVLat, projectDLng, projectDLat;

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
    required this.isPastProject,
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
      title: json['projectTitle'] as String? ?? 'Unknown',
      author: json['userNickname'] as String? ?? 'Unknown',
      createdAt: json['projectWriteTime'] as String? ?? 'Unknown',
      location: json['projectSName'] as String? ?? 'Unknown',
      route: json['projectDName'] as String? ?? 'Unknown',
      date: json['projectDate'] as String? ?? 'Unknown',
      time: json['projectTime'] as String? ?? 'Unknown',
      participants: json['projectMemberCount'] as int? ?? 0,
      capacity: json['projectRecruitment'] as int? ?? 0,
      additionalInfo: json['projectContent'] as String? ?? 'No additional info',
      projectSName: json['projectSName'] as String? ?? 'Unknown',
      projectVName: json['projectVName'] as String? ?? 'Unknown',
      projectDName: json['projectDName'] as String? ?? 'Unknown',
      projectDLat: json['projectDLat']?.toDouble() ?? 0.0,
      projectDLng: json['projectDLng']?.toDouble() ?? 0.0,
      projectVLat: json['projectVLat']?.toDouble() ?? 0.0,
      projectVLng: json['projectVLng']?.toDouble() ?? 0.0,
      projectSLat: json['projectSLat']?.toDouble() ?? 0.0,
      projectSLng: json['projectSLng']?.toDouble() ?? 0.0,
      isPastProject: json['isPastProject'] as String? ?? 'Unknown',
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
  bool isJoined = false;

  @override
  void initState() {
    super.initState();
    crewDetailFuture = fetchCrewDetail();
  }

  Future<CrewDetail> fetchCrewDetail() async {
    String? token = await myToken.TokenManager.instance.getToken();
    String url = '${dotenv.env['NGROK_URL']}/crew-project/detail/${widget
        .crewNumber}/${widget.crewProjectNumber}';
    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept-Charset': 'UTF-8',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("Response status: ${response.statusCode}");
      print("Received data: ${response.body}");

      if (response.statusCode == 200) {
        var responseData = json.decode(utf8.decode(response.bodyBytes));
        if (responseData is List) {
          // 응답이 배열인 경우, 첫 번째 요소를 사용합니다.
          return CrewDetail.fromJson(responseData[0]);
        } else {
          // 응답이 객체인 경우, 바로 파싱합니다.
          return CrewDetail.fromJson(responseData);
        }
      } else {
        print("Error fetching data: ${response.body}");
        throw Exception('Failed to load crew details with status code ${response
            .statusCode}');
      }
    } catch (e) {
      print("Error parsing data: $e");
      throw Exception("Error parsing data: $e");
    }
  }

  Future<void> joinProject() async {
    CrewDetail detail = await crewDetailFuture;
    String? token = await myToken.TokenManager.instance.getToken();
    String? baseUrl = dotenv.env['NGROK_URL'];
    var url = Uri.parse('$baseUrl/crew/join/${widget.crewNumber}/${widget.crewProjectNumber}');

    print("Joining project with URL: $url");
    print("Token: $token");
    print("isJoined: $isJoined");
    print("isPastProject: ${detail.isPastProject}");

    if (!isJoined && detail.isPastProject != "Y") {
      try {
        var response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        print("Join project response status: ${response.statusCode}");
        print("Join project response body: ${response.body}");

        if (response.statusCode == 303 || response.statusCode == 200) {
          setState(() {
            isJoined = true; // Update state to reflect join status
          });
          if (mounted) {
            print("Before showing success dialog");
            showSuccessDialog('참여되었습니다.');
            print("After showing success dialog");
          }
        } else if (response.statusCode == 500) {
          showErrorDialog('참여에 실패했습니다.');
        } else {
          showErrorDialog('참여에 실패했습니다.');
        }
      } catch (e) {
        print("Network error: $e");
        showErrorDialog('Network error: $e');
      }
    } else {
      showErrorDialog('이미 참여했거나 지난 프로젝트입니다.');
    }
  }


  void showSuccessDialog(String message) {
    print("Success Dialog is about to show: $message");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              print("Success dialog OK button pressed");
              Navigator.of(context).pop();
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
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: joinProject,
          child: Text(isJoined ? '참여됨' : '참여하기'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isJoined ? Colors.grey : Theme.of(context).colorScheme.primary,
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
    final markerS = NMarker(
      id: "start",
      position: NLatLng(detail.projectSLat, detail.projectSLng),
    );
    final markerV = NMarker(
      id: "via",
      position: NLatLng(detail.projectVLat, detail.projectVLng),
    );
    final markerD = NMarker(
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

    List<NLatLng> polylineCoords;
    if (detail.projectVLat == 0.0 && detail.projectVLng == 0.0) {
      polylineCoords = [
        NLatLng(detail.projectSLat, detail.projectSLng),
        NLatLng(detail.projectDLat, detail.projectDLng),
      ];
    } else {
      polylineCoords = [
        NLatLng(detail.projectSLat, detail.projectSLng),
        NLatLng(detail.projectVLat, detail.projectVLng),
        NLatLng(detail.projectDLat, detail.projectDLng),
      ];
    }

    final polyline = NPolylineOverlay(
      id: "route",
      coords: polylineCoords,
      color: Colors.blue,
      width: 3,
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
                Text('모임 위치', style: TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(detail.location),
                Divider(),
                Text('루트', style: TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('출발지 : ${detail.projectSName}'),
                if (detail.projectVLat != 0.0 && detail.projectVLng != 0.0)
                  Text('경유지 : ${detail.projectVName}'),
                Text('목적지 : ${detail.projectDName}'),
                SizedBox(height: 10),
                Container(
                  height: 200,
                  child: NaverMap(
                    onMapReady: (controller) {
                      controller.updateCamera(
                        NCameraUpdate.scrollAndZoomTo(
                          target: NLatLng(detail.projectSLat, detail
                              .projectSLng),
                        ),
                      );
                      controller.addOverlayAll(
                          {markerS, markerD, polyline});
                      markerS.openInfoWindow(onMarkerinfoWindowS);
                      if (detail.projectVLat != 0.0 &&
                          detail.projectVLng != 0.0) {
                        controller.addOverlay(markerV);
                        markerV.openInfoWindow(onMarkerinfoWindowV);
                      }
                      markerD.openInfoWindow(onMarkerinfoWindowD);
                    },
                  ),
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