import 'package:clean_way/screens/my_info.dart';
import 'package:flutter/material.dart';
import '/widgets/bottom_navigation.dart';
import 'crew.dart';
import 'my_place.dart';
import 'my_project.dart';
import 'package:clean_way/token_manager.dart' as myToken;

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
      OAuthToken tokenResult = await UserApi.instance.loginWithKakaoTalk();
      if (tokenResult != null) {
        var user = await UserApi.instance.me();
        isLoggedIn = true;

        // 서버에 로그인 데이터를 전송하고 JWT 토큰을 받아 저장합니다.
        await sendLoginDataToServer(user);

        // 상태를 업데이트합니다.
        setState(() {});
      }
    } catch (error) {
      print('KakaoTalk 로그인 실패: $error');
      isLoggedIn = false;
      setState(() {});
    }
  }

  Future<void> sendLoginDataToServer(User user) async {
    String? baseUrl = dotenv.env['NGROK_URL'];
    String? token = await myToken.TokenManager.instance.getToken();

    var url = Uri.parse('$baseUrl/kakao/login');

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',},
        body: jsonEncode({
          'id': user.id,
          'nickname': user.kakaoAccount?.profile?.nickname,
          'email': user.kakaoAccount?.email,
        }),
      );

      print("서버 응답 상태 코드: ${response.statusCode}");
      print("서버 응답 본문: ${response.body}");

      if (response.statusCode == 200) {
        // 서버 응답이 문자열일 경우 직접 저장
        String token = response.body;
        await myToken.TokenManager.instance.setToken(token);
        print("JWT 토큰 저장: $token");
        String? savedToken = await myToken.TokenManager.instance.getToken();
        print("저장된 토큰: $savedToken");
      } else {
        print("서버 로그인 실패: ${response.body}");
      }
    } catch (e) {
      print("서버 로그인 중 에러 발생: $e");
    }
  }

  void logoutFromKakao() async {
    try {
      await UserApi.instance.logout();
      print("로그아웃 성공");
      setState(() {
        isLoggedIn = false;
        user = null;
      });
    } catch (error) {
      print("로그아웃 실패: $error");
    }
  }

  void unregisterFromKakao() async {
    try {
      final result = await UserApi.instance.unlink();
      print("회원 탈퇴 성공");
      setState(() {
        isLoggedIn = false;
        user = null;
      });
    } catch (error) {
      print("회원 탈퇴 실패: $error");
    }
  }

  void showEditNicknameDialog() {
    TextEditingController nicknameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('닉네임 수정'),
          content: TextField(
            controller: nicknameController,
            decoration: InputDecoration(hintText: "새로운 닉네임 입력"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('저장'),
              onPressed: () {
                updateNickname(nicknameController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateNickname(String newNickname) async {
    String? token = await myToken.TokenManager.instance.getToken();
    String? baseUrl = dotenv.env['NGROK_URL'];
    var url = Uri.parse('$baseUrl/mypage/info');

    print('사용할 토큰: $token');  // 토큰이 올바르게 전달되는지 확인

    var requestBody = jsonEncode({'newNickname': newNickname});

    try {
      var response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      print("닉네임 변경 응답 상태 코드: ${response.statusCode}");
      print("닉네임 변경 응답 본문: ${response.body}");

      if (response.statusCode == 200) {
        print("닉네임이 성공적으로 변경되었습니다.");
      } else {
        print("닉네임 변경 실패: ${response.body}");
      }
    } catch (e) {
      print("닉네임 변경 중 에러 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MY'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (!isLoggedIn) ...[
              ElevatedButton(
                onPressed: loginWithKakao,
                child: Text('카카오톡으로 로그인하기'),
              ),

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
                user?.kakaoAccount?.profile?.nickname ?? '이승은',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: showEditNicknameDialog,
                child: Text('닉네임 수정'),
              ),
            ],
            SizedBox(height: 30),
            Divider(),
            ListTile(
              title: Text('내 정보'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyInfo()));
              },
            ),
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
            TextButton(
              onPressed: logoutFromKakao,
              child: Text('로그아웃'),
            ),
            TextButton(
              onPressed: unregisterFromKakao,
              child: Text('회원 탈퇴'),
            ),
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
