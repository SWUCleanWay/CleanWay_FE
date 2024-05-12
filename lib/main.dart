import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'screens/create_project_screen.dart';
import 'screens/create_report_screen.dart';
import 'screens/create_report_copy_screen.dart';
import 'screens/project_detail_screen.dart';
import 'widgets/bottom_navigation.dart';
import 'screens/crew.dart';
import 'screens/route.dart';
import 'screens/my.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env"); // .env 파일 로드
    print("clientId: ${dotenv.env['NAVER_MAP_CLIENT_ID']}");
    await NaverMapSdk.instance.initialize(
        clientId: dotenv.env['NAVER_MAP_CLIENT_ID']!, // .env에서 클라이언트 ID 사용
        onAuthFailed: (e) {
          print("네이버 맵 인증오류: $e");
        }
    );
    runApp(const MyApp());
  } catch (e) {
    print('환경변수 로드 실패: $e');
    runApp(ErrorApp()); // 오류 발생 시 보여줄 대체 앱
  }
}

Future<void> requestLocationPermission() async {
  var status = await Permission.location.status;
  if (!status.isGranted) {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
    ].request();
    print(statuses[Permission.location]);
  }
}

class ErrorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('환경변수 로드 실패'),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: dotenv.load(fileName: ".env"),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Return a loading indicator if environment variables are being loaded
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else {
          // Once environment variables are loaded, return the MaterialApp
          return MaterialApp(
            title: 'CleanWay',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF588100)),
              useMaterial3: true,
            ),
            home: const MainScreen(),
          );
        }
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool initialCrewSelected;

  const MainScreen({Key? key, this.initialCrewSelected = true}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late bool _isCrewPostSelected;
  int _selectedIndex = 0;
  List<Map<String, dynamic>> mockCrewData = [
    {'title': '크루 1', 'user':'user1', 'date': '2024-XX-XX', 'capacity':'0/5'},
    {'title': '크루 2', 'user':'user1', 'date': '2024-XX-XX', 'capacity':'3/5'},
    {'title': '크루 3', 'user':'user1', 'date': '2024-XX-XX', 'capacity':'1/5'},
  ];
  List<Map<String, dynamic>> _reportData = [];

  @override
  void initState() {
    super.initState();
    _isCrewPostSelected = widget.initialCrewSelected;
    fetchReports();
  }

  Future<void> fetchReports() async {
    //String apiUrl = dotenv.env['NGROK_URL'] ?? 'http://10.0.2.2';  // .env 파일에서 URL 읽기
    var url = Uri.parse('${dotenv.env['NGROK_URL']}/report/list');  // URL 구성
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        print('success');
        var data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
        setState(() {
          _reportData = data.map((item) => {
            'location': item['spotName'],
            'date': item['reportDate'],
            'issue': item['keywordName']
          }).toList();
        });
      } else {
        throw Exception('Failed to load report data');
      }
    } catch (e) {
      print('API 호출 중 에러 발생: $e');
    }
  }


  List<Map<String, dynamic>> get _currentList => _isCrewPostSelected ? mockCrewData : _reportData;

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CrewScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RouteScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyScreen()),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CleanWay',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF588100),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isCrewPostSelected = true;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      color: _isCrewPostSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                      alignment: Alignment.center,
                      child: Text(
                        '크루 모집 글',
                        style: TextStyle(
                          color: _isCrewPostSelected ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isCrewPostSelected = false;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      color: !_isCrewPostSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                      alignment: Alignment.center,
                      child: Text(
                        '제보 글',
                        style: TextStyle(
                          color: !_isCrewPostSelected ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _currentList.length,
              itemBuilder: (context, index) {
                var post = _currentList[index];
                // 조건에 따라 다른 ListTile 구조를 반환
                if (_isCrewPostSelected) {
                  // 크루 모집 글
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      onTap: () {
                        // Navigator.push를 사용하여 project_detail_screen.dart 페이지로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProjectDetailScreen()),
                        );
                      },
                      title: Text(post['title']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('작성자: ${post['user']}'),
                          Text('작성일: ${post['date']}'),
                          Text('모집인원: ${post['capacity']}'),
                        ],
                      ),
                    ),
                  );
                } else {
                  // 제보 글
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: Text(post['location']),  // spotName을 타이틀로 사용
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('${post['date']}'),  // 날짜 정보를 먼저 표시
                          SizedBox(height: 5),
                          Container(  // Container로 감싸고 BoxDecoration 설정
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),  // 둥근 테두리 설정
                              border: Border.all(color: Colors.grey),  // 경계선 설정
                              // 다른 필요한 스타일들도 추가할 수 있습니다.
                            ),
                            padding: EdgeInsets.all(8),  // 내부 여백 설정
                            child: Text(post['issue']),  // 문제상황 정보를 둥근 테두리로 감싸서 표시
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          )

        ],
      ),
      floatingActionButton: Builder(
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 64.0), // 네비게이션 바와 플로팅 버튼 사이에 여백 추가
            child: FloatingActionButton(
              onPressed: () {
                final RenderBox button = context.findRenderObject() as RenderBox;
                final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
                final Offset buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);
                final RelativeRect position = RelativeRect.fromLTRB(
                  buttonPosition.dx - 180, // 버튼의 시작점으로부터 왼쪽으로 팝업 메뉴 너비만큼 오프셋
                  buttonPosition.dy - button.size.height/2, // 버튼 위로 오프셋
                  buttonPosition.dx, // 버튼의 시작점
                  overlay.size.height - buttonPosition.dy, // 버튼 아래로 오프셋
                );
                showMenu(
                  context: context,
                  position: position,
                  items: [
                    PopupMenuItem(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => CreateProjectScreen()),
                          );
                        },
                        child: Text('크루원 모집하기'),
                      ),
                    ),
                    PopupMenuItem(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => CreateReportCopyScreen()),
                          );
                        },
                        child: Text('제보하기'),
                      ),
                    ),
                  ],
                );
              },
              child: Icon(Icons.add),
              tooltip: 'Create Project',
              shape: CircleBorder(),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked, // 플로팅 버튼 위치 조정
      bottomNavigationBar: BottomNavigation(
        selectedIndex: _selectedIndex, // Pass selectedIndex
        onItemSelected: _onItemSelected, // Pass onItemSelected
      ),
    );
  }
}
