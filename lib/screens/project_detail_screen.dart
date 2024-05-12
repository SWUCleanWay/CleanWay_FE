import 'package:flutter/material.dart';

// 모델 클래스 정의
class CrewDetail {
  final String title;
  final String author;
  final String createdAt;
  final String location;
  final String route;
  final String date;
  final String time;
  final int participants;
  final int capacity;
  final String additionalInfo;

  CrewDetail({
    required this.title,
    required this.author,
    required this.createdAt,
    required this.location,
    required this.route,
    required this.date,
    required this.time,
    required this.participants,
    required this.capacity,
    required this.additionalInfo,
  });
}

class ProjectDetailScreen extends StatelessWidget {
  final CrewDetail crewDetail = CrewDetail(
    title: '크루AAA',
    author: 'user1',
    createdAt: '2024년 04월 22일',
    location: '서울시 노원구 공릉동 서울산업대학교',
    route: '출발지',
    date: '2024년 04월 22일',
    time: '10:00',
    participants: 0,
    capacity: 5,
    additionalInfo: '같이 플로깅 하실 분들 모집합니다~',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        actions: [
          Icon(Icons.share),
          SizedBox(width: 16),
          Icon(Icons.star_border),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(20.0, 0, 0, 0),
              child: Text(
                crewDetail.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.fromLTRB(20.0, 0, 0, 0),
              //leading: Icon(Icons.account_circle),
              title: Text(crewDetail.author),
              subtitle: Text(crewDetail.createdAt),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '모임 위치',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('${crewDetail.location}'),
                  Divider(),
                  Text(
                      '루트',
                    style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                  ),
                  SizedBox(height: 10),
                  Text('${crewDetail.route}'),
                  Divider(),
                  Text(
                      '날짜',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('${crewDetail.date}'),
                  Divider(),
                  Text(
                      '시간',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('${crewDetail.time}'),
                  Divider(),
                  Text(
                      '참여 인원',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('${crewDetail.participants} / ${crewDetail.capacity}명'),
                  Divider(),
                  Text(
                      '추가 정보',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('${crewDetail.additionalInfo}'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // 둘러보기 로직
                  },
                  child: Text('둘러보기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // 참여하기 로직
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('참여하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}