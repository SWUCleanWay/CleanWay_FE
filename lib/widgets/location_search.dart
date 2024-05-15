import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LocationSearch extends StatefulWidget {
  @override
  _LocationSearchState createState() => _LocationSearchState();
}

class _LocationSearchState extends State<LocationSearch> {
  late NaverMapController _controller;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadEnv();
    requestLocationPermission();
  }

  Future<void> loadEnv() async {
    await dotenv.load();
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('위치 검색'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => searchLocation(_searchController.text),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '검색할 장소 입력',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                ),
              ),
              onSubmitted: (value) => searchLocation(value),
            ),
          ),
          Expanded(
            child: NaverMap(
              onMapReady: (controller) {
                _controller = controller;
                print("네이버 맵 로딩됨!");
              },
              onMapTapped: (point, latLng) {
                print("맵 탭 위치: $latLng");
              },
            ),
          ),
        ],
      ),
    );
  }

  void searchLocation(String query) async {
    var clientId = dotenv.env['X_NAVER_CLIENT_ID']!;
    var clientSecret = dotenv.env['X_NAVER_CLIENT_SECRET']!;
    String encodedQuery = Uri.encodeComponent(query);
    var url = Uri.parse(
        'https://openapi.naver.com/v1/search/local.json?query=$encodedQuery');
    var response = await http.get(url, headers: {
      'X-Naver-Client-Id': clientId,
      'X-Naver-Client-Secret': clientSecret,
    });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var items = data['items'];
      if (items.isNotEmpty) {
        var item = items[0];
        // 정수형 좌표를 실제 위도와 경도로 변환
        double lat = double.parse(item['mapy']) * 1e-7;
        double lng = double.parse(item['mapx']) * 1e-7;
        print("위도, 경도 : $lat $lng"); // 수정된 위도와 경도 출력
        setState(() {
          _controller.updateCamera(
              NCameraUpdate.scrollAndZoomTo(target: NLatLng(lat, lng))
          );
          var marker = NMarker(
            id: "resultMarker",
            position: NLatLng(lat, lng),
          );
          _controller.addOverlay(marker);
        });
      }
    } else {
      print('Failed to fetch data with status code: ${response.statusCode}');
    }
  }
}