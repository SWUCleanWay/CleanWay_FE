import 'package:flutter/material.dart';
import '/widgets/bottom_navigation.dart';
import 'package:clean_way/main.dart';
import 'route.dart';
import 'my.dart';
import 'crew_detail_screen.dart';

class Crew {
  final String name;
  final String members;
  final String joinDate;

  Crew({
    required this.name,
    required this.members,
    required this.joinDate
  });
}

List<Crew> mockCrews = [
  Crew(name: "크루 A", members: "5", joinDate: "2024-04-01"),
  Crew(name: "크루 B", members: "3", joinDate: "2024-04-02"),
  Crew(name: "크루 C", members: "2", joinDate: "2024-04-03"),
];

class CrewScreen extends StatelessWidget {
  const CrewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 크루'),
      ),
      body: Column(
        children: [
          Divider(height: 1),  // 첫 번째 아이템 위에 구분선 추가
          Expanded(
            child: ListView.separated(
              itemCount: mockCrews.length,
              itemBuilder: (context, index) {
                Crew crew = mockCrews[index];
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CrewDetailPage(crew: crew)), // 수정된 부분
                    );
                  },
                );
              },
              separatorBuilder: (context, index) => Divider(),
            ),
          ),
        ],
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
