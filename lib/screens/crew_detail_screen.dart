import 'package:flutter/material.dart';
import 'crew.dart';

class CrewDetailPage extends StatelessWidget {
  final Crew crew;

  const CrewDetailPage({Key? key, required this.crew}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(crew.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 최근 프로젝트 모집 글 리스트
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('새 프로젝트', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Divider(height: 1),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('플로깅 함께 해요', style: TextStyle(fontSize: 18)),
                  ),
                  Text('2024-05-02', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Divider(height: 1),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        // 프로젝트 생성 페이지로 이동하는 코드 추가
                      },
                      style: TextButton.styleFrom(
                        textStyle: TextStyle(
                          decoration: TextDecoration.underline,  // 밑줄 추가
                        ),
                      ),
                      child: Text('프로젝트 생성하기'),
                    ),
                  )
                ],
              ),
            ),

            // 최다 참여 크루원
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('크루원 TOP3', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 10),
            Container(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 모든 아이템의 간격을 균등하게 설정
                children: List.generate(3, (index) {  // 3개의 아이템 생성
                  return Expanded(  // 각 아이템을 Expanded로 감싸 균등한 공간 분배
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(radius: 30),
                          Text('크루원${index + 1}'),
                          Flexible(
                            child: Text(
                              'n회',
                              overflow: TextOverflow.ellipsis,  // 넘치는 텍스트를 ... 으로 처리
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),


            // 완료된 프로젝트
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('완료된 프로젝트', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 3,  // 예시 데이터
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Divider(), // Only add Divider if it's not the first item
                    ListTile(
                      title: Text('프로젝트 ${index + 1}'),
                      subtitle: Text('2024-05-${index + 2}'),
                      trailing: Text('n 명'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
