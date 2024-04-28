import 'package:flutter/material.dart';
import 'screens/create_project_screen.dart';
import 'widgets/bottom_navigation.dart';
import 'screens/crew.dart';
import 'screens/route.dart';
import 'screens/my.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CleanWay',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF588100)),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

// 글 데이터 클래스
class Post {
  final String title;
  final String date;
  final String location;
  final String issue;
  final String imageUrl;

  Post({
    required this.title,
    required this.date,
    required this.location,
    required this.issue,
    required this.imageUrl,
  });
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State {
  int _selectedIndex = 0;
  bool _isCrewPostSelected = true;

  // mock data list
  final List<Map<String, dynamic>>  mockCrewData = [
    {'title': '크루 1', 'user':'user1', 'date': '2024-XX-XX', 'capacity':'0/5'},
    {'title': '크루 2', 'user':'user1', 'date': '2024-XX-XX', 'capacity':'3/5'},
    {'title': '크루 3', 'user':'user1', 'date': '2024-XX-XX', 'capacity':'1/5'},
    // ... 더 많은 데이터를 추가할 수 있습니다.
  ];
  final List<Map<String, dynamic>> mockReportData = [
    {'location': '장소 1', 'date': '2024-XX-XX', 'issue': '문제점 1'},
    {'location': '장소 2', 'date': '2024-XX-XX', 'issue': '문제점 2'},
    {'location': '장소 3', 'date': '2024-XX-XX', 'issue': '문제점 3'},
    // ... 더 많은 데이터를 추가할 수 있습니다.
  ];

  List<Map<String, dynamic>> get _currentList => _isCrewPostSelected ? mockCrewData : mockReportData;

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
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              itemCount: _currentList.length,
              itemBuilder: (context, index) {
                var post = _currentList[index];
                if (_isCrewPostSelected) {
                  // 크루 모집 글 카드
                  return GestureDetector(
                    onTap: () {
                      // TODO: 여기에 상세 페이지로의 경로를 설정하면 됩니다.
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('상세 페이지로 이동: ${post['title']}'),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post['title'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('작성자: ${post['user']}', style: TextStyle(fontSize: 16)),
                                Text(' | ', style: TextStyle(fontSize: 16)),
                                Text('작성 시간: ${post['date']}', style: TextStyle(fontSize: 16)),
                              ],
                            ),

                            SizedBox(height: 8),
                            Text('모집 인원: ${post['capacity']}', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200], // 임시 배경색
                        ),
                        child: Stack(
                          children: [
                            // 포스트 내용
                            Positioned(
                              left: 16,
                              top: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(post['date'],
                                      style: TextStyle(fontSize: 16)),
                                  SizedBox(height: 8),
                                  Text(post['location'],
                                      style: TextStyle(fontSize: 16)),
                                  SizedBox(height: 8),
                                  Text(post['issue'],
                                      style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                            // 즐겨찾기 버튼
                            Positioned(
                              right: 16,
                              bottom: 16,
                              child: IconButton(
                                icon: const Icon(Icons.favorite_border),
                                onPressed: () {
                                  // 즐겨찾기 기능 구현
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                };
              },
            ),
          ),
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
                final RelativeRect position = RelativeRect.fromRect(
                  Rect.fromPoints(
                    button.localToGlobal(button.size.bottomLeft(Offset.zero), ancestor: overlay),
                    button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                  ),
                  Offset.zero & overlay.size,
                );
                showMenu(
                  context: context,
                  position: position,
                  items: [
                    PopupMenuItem(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => CreateProjectScreen()),
                          );
                        },
                        child: Text('크루원 모집하기'),
                      ),
                    ),
                    PopupMenuItem(
                      child: Text('제보하기'),
                      // '제보하기'를 선택하면 해당 기능을 구현해 주어야 합니다.
                    ),
                  ],
                );
              },
              child: Icon(Icons.add),
              tooltip: 'Create Project',
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



