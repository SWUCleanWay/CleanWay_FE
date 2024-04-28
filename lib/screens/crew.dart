import 'package:flutter/material.dart';
import '/widgets/bottom_navigation.dart';
import 'package:clean_way/main.dart';
import 'route.dart';
import 'my.dart';

class CrewScreen extends StatelessWidget {
  const CrewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('크루'),
      ),
      body: Center(
        child: Text('크루 화면'),
      ),
      bottomNavigationBar: BottomNavigation(
        selectedIndex: 1, // 크루 화면이므로 인덱스는 1
        onItemSelected: (index) {
          // 네비게이션 메뉴 클릭 시
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()), // 홈 화면으로 이동
            );
          } else if (index == 1) {
            // 이미 크루 화면이므로 아무것도 하지 않음
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => RouteScreen()), // 루트 화면으로 이동
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyScreen()), // MY 화면으로 이동
            );
          }
        },
      ),
    );
  }
}
