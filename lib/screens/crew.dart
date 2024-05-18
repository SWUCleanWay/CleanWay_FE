import 'package:flutter/material.dart';
import '/widgets/bottom_navigation.dart';
import 'package:clean_way/main.dart';
import 'route.dart';
import 'my.dart';
import 'crew_detail_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Crew {
  final int crewNumber;
  final String name;
  final int members;
  final String joinDate;

  Crew({
    required this.crewNumber,
    required this.name,
    required this.members,
    required this.joinDate,
  });

  factory Crew.fromJson(Map<String, dynamic> json) {
    return Crew(
      crewNumber: json['crewNumber'],
      name: json['crewName'],
      members: json['memberCount'],
      joinDate: json['crewJoinDate'],
    );
  }
}

class CrewScreen extends StatelessWidget {
  const CrewScreen({Key? key}) : super(key: key);
  //final int crewNumber;
  //CrewDetailPage({required this.crewNumber});

  Future<List<Crew>> fetchCrews() async {
    // Uncomment below to fetch data from the server
    /*
    final response = await http.get(Uri.parse('https://your-server.com/crew-project/mycrew'));

    if (response.statusCode == 200) {
      List<dynamic> crewsJson = json.decode(response.body);
      return crewsJson.map((json) => Crew.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load crews');
    }
    */
    // Using mock data since the server is not available
    List<Crew> mockCrews = [
      Crew.fromJson({
        "crewNumber": 1,
        "userNumber": 1,
        "crewName": "토끼네 플로깅",
        "crewRecruitment": 10,
        "crewRoleNumber": 2,
        "memberCount": 3,
        "userNickname": "강아지",
        "crewJoinDate": "2024-05-14 00:00:00"
      }),
      Crew.fromJson({
        "crewNumber": 2,
        "userNumber": 1,
        "crewName": "바오패밀리",
        "crewRecruitment": 15,
        "crewRoleNumber": 2,
        "memberCount": 3,
        "userNickname": "강아지",
        "crewJoinDate": "2024-05-14 00:00:00"
      }),
    ];
    return Future.delayed(Duration(seconds: 1), () => mockCrews);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 크루'),
      ),
      body: FutureBuilder<List<Crew>>(
        future: fetchCrews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return Column(
              children: [
                Divider(height: 1),  // 첫 번째 아이템 위에 구분선 추가
                Expanded(
                  child: ListView.separated(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Crew crew = snapshot.data![index];
                      return ListTile(
                        title: Text(crew.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('멤버 수: ${crew.members}명', style: TextStyle(fontSize: 14)),
                            Text('참여 날짜: ${crew.joinDate}', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                        onTap: () {
                          // Navigate to the crew detail page
                          /*Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CrewDetailPage(crewNumber: crew.crewNumber)),
                          );*/
                        },
                      );
                    },
                    separatorBuilder: (context, index) => Divider(),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: Text('No data found'));
          }
        },
      ),
      bottomNavigationBar: BottomNavigation(
        selectedIndex: 1,
        onItemSelected: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
          } else if (index == 1) {
            // 현재 화면 유지
          } else if (index == 2) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RouteScreen()));
          } else if (index == 3) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyScreen()));
          }
        },
      ),
    );
  }
}
