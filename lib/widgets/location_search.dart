import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:permission_handler/permission_handler.dart';

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
    requestLocationPermission();
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
      appBar: AppBar
        (title: Text('위치 검색'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => searchLocation(_searchController.text),
          ),
        ],),
      body: Column(
          children: [
            Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '검색할 위치 입력',
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
              /*locationButtonEnable: true,
              initLocationTrackingMode: LocationTrackingMode.Follow,*/
              ),
            ),
          ],
        ),
      );
    }
  }

  void searchLocation(String query) {
    // 네이버 검색 API 통합 또는 사용자 정의 검색 로직 구현
    print("검색 진행: $query");
    // 여기에 API 호출 코드 및 결과 처리 로직을 추가하십시오.
  }
