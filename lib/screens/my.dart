import 'package:flutter/material.dart';
import '/widgets/bottom_navigation.dart';
import 'crew.dart';
import 'route.dart';
import 'package:clean_way/main.dart';

class MyScreen extends StatelessWidget {
  const MyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MY'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.person, size: 60, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Text(
              '@ @ @',  //닉네임
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // 버튼이 눌렸을 때 실행할 기능
              },
              child:
              Text('닉네임 수정'),
              style: TextButton.styleFrom(
              ),
            ),
            SizedBox(height: 30),
            Divider(),
            ListTile(title: Text('내 장소')),
            Divider(),
            ListTile(title: Text('내 루트')),
            Divider(),
            ListTile(title: Text('참여한 플로깅')),
            Divider(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        selectedIndex: 3, // MY 화면이므로 인덱스는 3
        onItemSelected: (index) {
          // 네비게이션 메뉴 클릭 시
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()), // 홈 화면으로 이동
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CrewScreen()), // 크루 화면으로 이동
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => RouteScreen()), // 루트 화면으로 이동
            );
          } else if (index == 3) {
            // 이미 MY
          }
        },
      ),
    );
  }
}