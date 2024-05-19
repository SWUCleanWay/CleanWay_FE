import 'package:flutter/material.dart';
import '/widgets/bottom_navigation.dart';
import 'package:clean_way/main.dart';
import 'route.dart';
import 'my.dart';
import 'crew_detail_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  /*final int crewNumber;
  CrewDetailPage({required this.crewNumber});*/

  Future<List<Crew>> fetchCrews() async {
    String url = '${dotenv.env['NGROK_URL']}/crew-project/mycrew';

    try {
      var response = await http.get(Uri.parse(url));
      print('Response Status: ${response.statusCode}');  // 상태 코드 출력

      if (response.statusCode == 200) {
        List<dynamic> crewsJson = json.decode(utf8.decode(response.bodyBytes));
        return crewsJson.map((json) => Crew.fromJson(json)).toList();
      } else {
        print('Failed to load crews with status code: ${response.statusCode}');
        throw Exception('Failed to load crews');
      }
    } catch (e) {
      print('Error fetching crews: $e');  // 예외 발생시 예외 내용 출력
      throw Exception('Error fetching crews: $e');
    }
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
                        // 기존 CrewScreen 코드 내에 위치하는 ListView.builder 내 itemBuilder 수정 부분:
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CrewDetailPage(crewNumber: crew.crewNumber, crewName: crew.name),
                            ),
                          );
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
