import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

import '/widgets/bottom_navigation.dart';
import '/main.dart';
import 'route.dart';
import 'my.dart';
import 'crew_detail_screen.dart';

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

class CrewScreen extends StatefulWidget {
  const CrewScreen({Key? key}) : super(key: key);

  @override
  _CrewScreenState createState() => _CrewScreenState();
}

class _CrewScreenState extends State<CrewScreen> {
  TextEditingController searchController = TextEditingController();
  Future<List<Crew>>? futureCrews;

  @override
  void initState() {
    super.initState();
    futureCrews = fetchCrews("");  // 초기 데이터 로드
  }

  Future<List<Crew>> fetchCrews(String searchWord) async {
    String baseUrl = '${dotenv.env['NGROK_URL']}/crew-project/mycrew';
    String url = searchWord.isNotEmpty ? '$baseUrl/search?searchWord=${searchWord}' : baseUrl;

    print('Fetching crews with URL: $url');

    var response = await http.get(Uri.parse(url));
    print('Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      var decodedResponse = json.decode(utf8.decode(response.bodyBytes));

      // 검색어가 있을 때와 없을 때 응답 구조 처리
      if (searchWord.isNotEmpty) {
        if (decodedResponse is Map<String, dynamic> && decodedResponse.containsKey('myCrewByWordList')) {
          List<dynamic> crewsJson = decodedResponse['myCrewByWordList'];
          return crewsJson.map((json) => Crew.fromJson(json)).toList();
        } else {
          print('Unexpected JSON structure for search: ${decodedResponse}');
          throw Exception('Unexpected JSON structure for search');
        }
      } else {
        // 검색어 없이 기본 리스트 호출 시 배열로 직접 반환
        if (decodedResponse is List) {
          return decodedResponse.map((json) => Crew.fromJson(json)).toList();
        } else {
          print('Unexpected JSON structure for list: ${decodedResponse}');
          throw Exception('Unexpected JSON structure for list');
        }
      }
    } else {
      print('Failed to load crews with status code: ${response.statusCode}');
      throw Exception('Failed to load crews');
    }
  }



  void clearSearch() {
    searchController.clear();
    setState(() {
      futureCrews = fetchCrews("");  // 검색어 없이 다시 데이터 로드
    });
  }

  void updateSearch() {
    setState(() {
      futureCrews = fetchCrews(searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: "크루 검색",
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.clear),
              onPressed: clearSearch,
            )
                : IconButton(
              icon: Icon(Icons.search),
              onPressed: updateSearch,
            ),
          ),
          onChanged: (value) {
            updateSearch();  // 검색어 변경시 바로 검색
          },
        ),
      ),
      body: FutureBuilder<List<Crew>>(
        future: futureCrews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return ListView.separated(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Crew crew = snapshot.data![index];
                return ListTile(
                  title: Text(crew.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text('멤버 수: ${crew.members}명, 참여 날짜: ${crew.joinDate}'),
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
            );
          } else {
            return Center(child: Text('No data found'));
          }
        },
      ),
      bottomNavigationBar: BottomNavigation(
        selectedIndex: 0,
        onItemSelected: (index) {
          if (index == 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
          } else if (index == 0) {
            // 현재 화면 유지
          } else if (index == 2) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyScreen()));
          }
        },
      ),
    );
  }
}
