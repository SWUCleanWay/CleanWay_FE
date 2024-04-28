import 'package:flutter/material.dart';
import '/widgets/bottom_navigation.dart';
import 'package:clean_way/main.dart';
import 'crew.dart';
import 'my.dart';

class RouteScreen extends StatelessWidget {
  const RouteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('루트'),
      ),
      body: Center(
        child: Text('루트 화면'),
      ),
      bottomNavigationBar: BottomNavigation(
        selectedIndex: 2, // 크루 화면이므로 인덱스는 2
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
            //이미 route
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
