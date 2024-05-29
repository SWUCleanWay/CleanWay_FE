import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginScreen extends StatelessWidget {
  Future<void> loginWithKakao() async {
    // 클라이언트에서 서버로 로그인 요청 전송
    String url = '${dotenv.env['NGROK_URL']}/kakao/login';
    var response = await http.post(Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'code': '${dotenv.env['KAKAO_REST_API_KEY']}',  // 카카오 인증 코드를 여기에 추가합니다.
      }),
    );
    if (response.statusCode == 200) {
      final userInfo = jsonDecode(response.body);
      // 사용자 정보를 처리하고, 로그인 상태를 관리합니다.
    } else {
      throw Exception('로그인 실패');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: loginWithKakao,
          child: Text('Login with Kakao'),
        ),
      ),
    );
  }
}
