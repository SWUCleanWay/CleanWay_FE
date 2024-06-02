import 'package:flutter/material.dart';
import '/widgets/bottom_navigation.dart';
import 'crew.dart';
import 'route.dart';
import  'login_screen.dart';
import 'my_place.dart';
import 'my_project.dart';
import 'package:clean_way/main.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:kakao_flutter_sdk_auth/kakao_flutter_sdk_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  bool isLoggedIn = false;
  User? user;

  @override
  void initState() {
    super.initState();
    checkIfLoggedIn();
  }

  void checkIfLoggedIn() async {
    isLoggedIn = await AuthApi.instance.hasToken();
    if (isLoggedIn) {
      try {
        user = await UserApi.instance.me();
      } catch (error) {
        print('사용자 정보 가져오기 실패: $error');
        isLoggedIn = false;
      }
    }
    setState(() {});
  }

  void loginWithKakao() async {
    try {
      var tokenResult = await UserApi.instance.loginWithKakaoTalk();
      if (tokenResult != null) {
        user = await UserApi.instance.me();
        isLoggedIn = true;
      }
    } catch (error) {
      print('KakaoTalk login failed: $error');
      isLoggedIn = false;
    }
    setState(() {});
  }

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
            if (!isLoggedIn) ...[
              ElevatedButton(
                onPressed: loginWithKakao,
                child: Text('카카오톡으로 로그인하기'),
              ),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => LoginScreen()),
              //     );
              //   },
              //   child: Text('Login Screen으로 이동'),
              // ),

            ] else ...[
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(user?.kakaoAccount?.profile?.profileImageUrl ?? ''),
                backgroundColor: Colors.grey[200],
                child: user?.kakaoAccount?.profile?.profileImageUrl == null
                    ? Icon(Icons.person, size: 60, color: Colors.grey)
                    : null,
              ),
              SizedBox(height: 20),
              Text(
                user?.kakaoAccount?.profile?.nickname ?? '닉네임 없음',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // Implement nickname edit functionality
                },
                child: Text('닉네임 수정'),
              ),
            ],
            SizedBox(height: 30),
            Divider(),
            ListTile(
              title: Text('내 장소'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyPlace()));
              },
            ),
            Divider(),
            ListTile(
              title: Text('내 루트'),
              onTap: () {
                // Implement navigation to '내 루트' page if necessary
              },
            ),
            Divider(),
            ListTile(
              title: Text('참여한 플로깅'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyProject()));
              },
            ),
            Divider(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        selectedIndex: 2,
        onItemSelected: (index) {
          if (index == 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
          } else if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CrewScreen()));
          }
        },
      ),
    );
  }
}
