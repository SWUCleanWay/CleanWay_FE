import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class LocationSearch extends StatefulWidget {
  @override
  _LocationSearchState createState() => _LocationSearchState();
}

class _LocationSearchState extends State<LocationSearch> {
  late NaverMapController _controller;

  @override
  void initState() {
    super.initState();
    _initializeNaverMapSdk();
  }

  Future<void> _initializeNaverMapSdk() async {
    await dotenv.load();  // 환경변수 파일 로드

    NaverMapSdk.instance.initialize(
        clientId: dotenv.env['NAVER_MAP_CLIENT_ID']!,  // .env에서 클라이언트 ID 사용
        onAuthFailed: (e) {
          print("네이버 맵 인증오류: $e");
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('위치 검색')),
      body: NaverMap(
        options: const NaverMapViewOptions(),
        onMapReady: (controller) {
          print("네이버 맵 로딩됨!");
        },
        onMapTapped: (point, latLng) {},
      ),
    );
  }
}
