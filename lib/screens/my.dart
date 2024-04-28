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
        child: Text('MY 화면'),
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