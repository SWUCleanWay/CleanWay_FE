import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

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

    KakaoSdk.init(
      nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY'],
      javaScriptAppKey: dotenv.env['KAKAO_JS_APP_KEY'],
    );

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
  List<Map<String, dynamic>> _crewData = [];
  List<Map<String, dynamic>> _reportData = [];

  @override
  void initState() {
    super.initState();
    _isCrewPostSelected = widget.initialCrewSelected;
    fetchReports();
    fetchCrews();
  }

  Future<void> fetchReports() async {
    String? baseUrl = dotenv.env['NGROK_URL'];
    var url = Uri.parse('${baseUrl}/report/list');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
        setState(() {
          _reportData = data.map<Map<String, dynamic>>((item) {
            var imageUrl = item['imageUrl'] as String?;
            imageUrl = '$baseUrl$imageUrl';
            return {
              'location': item['spotName'],
              'date': item['reportDate'],
              'issue': item['keywordName'],
              'imageUrl': imageUrl,
              'spotNumber': item['spotNumber'],  // 여기에서 spotNumber를 처리
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load report data');
      }
    } catch (e) {
      print('API 호출 중 에러 발생: $e');
    }
  }

  Future<void> saveSpot(int spotNumber) async {
    var url = Uri.parse('${dotenv.env['NGROK_URL']}/report/saveSpot/${spotNumber}');
    try {
      var response = await http.post(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("내 장소에 성공적으로 등록됐습니다."),
          backgroundColor: Colors.grey,
        ));
      } else {
        throw Exception('Failed to save spot');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("내 장소에 저장을 실패했습니다."),
        backgroundColor: Colors.grey,
      ));
      print('Error saving spot: $e');
    }
  }

  Future<void> fetchCrews() async {
    var url = Uri.parse('${dotenv.env['NGROK_URL']}/crew/list');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        print('success');
        var data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
        setState(() {
          _crewData = data.map((item) {
            int crewProjectNumber = 0;  // 기본값을 0으로 설정
            if (item['crewProjectNumber'] != null) {
              crewProjectNumber = item['crewProjectNumber'] is int
                  ? item['crewProjectNumber']
                  : int.parse(item['crewProjectNumber'].toString());
            }
            return {
              'crewName': item['crewName'],
              'crewNumber': item['crewNumber'],
              'crewProjectNumber': crewProjectNumber,
              'title': item['crewName'],
              'date': item['crewWriteTime'],
              'members': item['memberCount'],
              'capacity': item['crewRecruitment'],
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load crew data');
      }
    } catch (e) {
      print('API 호출 중 에러 발생: $e');
    }
  }


  List<Map<String, dynamic>> get _currentList => _isCrewPostSelected ? _crewData : _reportData;

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CrewScreen()),
        );
        break;
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
        break;
      case 2:
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
              padding: const EdgeInsets.all(10.0),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProjectDetailScreen(crewNumber: post['crewNumber'], crewName:post['crewName'], crewProjectNumber: post['crewProjectNumber'])),
                        );
                      },
                      title: Text(post['title']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('작성일: ${post['date']}'),
                          Text('모집인원: ${post['members']}/${post['capacity']} 명'),
                        ],
                      ),
                    ),
                  );
                } else {
                  // 제보 글
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    height: 200,
                    decoration: BoxDecoration(
                      image: post['imageUrl'] != null ? DecorationImage(
                        image: NetworkImage(post['imageUrl']),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.6),
                          BlendMode.darken,
                        ),
                      ) : null,
                      color: post['imageUrl'] == null ? Colors.grey[300] : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        ListTile(
                          title: Text(
                            post['location'],
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 10),
                              Text(
                                post['date'],
                                style: TextStyle(color: Colors.white, fontSize: 20),
                              ),
                              SizedBox(height: 10),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  post['issue'],
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                ),
                              )
                            ],
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: IconButton(
                            icon: Icon(Icons.favorite_border, color: Colors.white),
                            onPressed: () {
                              if (post['spotNumber'] != null && post['spotNumber'] > 0) {
                                saveSpot(post['spotNumber']);
                              } else {
                                print("Invalid or missing spotNumber: ${post['spotNumber']}");
                              }
                            },
                          ),
                        ),
                      ],
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
