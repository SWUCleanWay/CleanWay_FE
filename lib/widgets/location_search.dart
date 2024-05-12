import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class LocationSearch extends StatefulWidget {
  @override
  _LocationSearchState createState() => _LocationSearchState();
}

class _LocationSearchState extends State<LocationSearch> {
  late NaverMapController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('위치 검색')),
      body: NaverMap(
        onMapReady: (controller) {
          _controller = controller;
          print("네이버 맵 로딩됨!");
        },
        onMapTapped: (point, latLng) {
          print("맵 탭 위치: $latLng");
        },
      ),
    );
  }
}