import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:clean_way/token_manager.dart' as myToken;

class MyInfo extends StatefulWidget {
  @override
  _MyInfoState createState() => _MyInfoState();
}

class _MyInfoState extends State<MyInfo> {
  Map<String, dynamic> userInfo = {};

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    String? token = await myToken.TokenManager.instance.getToken();
    String? baseUrl = dotenv.env['NGROK_URL'];

    // 환경 변수가 올바르게 로드되었는지 확인
    if (baseUrl == null || baseUrl.isEmpty) {
      print('NGROK_URL이 설정되지 않았습니다.');
      return;
    }

    var url = Uri.parse('$baseUrl/mypage/info');
    print('사용할 토큰: $token');
    try {
      var response = await http.get(
      url,
      headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      },
      );

      if (response.statusCode == 200) {
        setState(() {
          userInfo = jsonDecode(utf8.decode(response.bodyBytes));
        });
      } else {
        print('Failed to load user info: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 정보'),
      ),
      body: userInfo.isNotEmpty ? SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              title: Text('이메일'),
              subtitle: Text(userInfo['userEmail'] ?? 'Not available'),
            ),
            ListTile(
              title: Text('닉네임'),
              subtitle: Text(userInfo['userNickname'] ?? 'Not available'),
            ),
            ListTile(
              title: Text('참여 횟수'),
              subtitle: Text('${userInfo['myPlogging']} times'),
            ),
          ],
        ),
      ) : Center(child: CircularProgressIndicator()),
    );
  }
}
