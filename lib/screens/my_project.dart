import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyProject extends StatefulWidget {
  @override
  _MyProjectState createState() => _MyProjectState();
}

class _MyProjectState extends State<MyProject> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("내 프로젝트"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "진행 예정"),
            Tab(text: "진행 완료"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ProjectList(isUpcoming: true),
          ProjectList(isUpcoming: false),
        ],
      ),
    );
  }
}

class ProjectList extends StatelessWidget {
  final bool isUpcoming;

  ProjectList({required this.isUpcoming});

  // 임시 데이터를 위한 리스트 생성
  final List<Map<String, dynamic>> mockProjects = [
    {
      'title': '리사이클링 프로젝트',
      'description': '재활용 가능한 자원을 수집하는 프로젝트입니다.',
      'status': '진행 예정'
    },
    {
      'title': '공원 청소 프로젝트',
      'description': '지역 공원을 청소하는 커뮤니티 활동입니다.',
      'status': '진행 완료'
    }
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredProjects = mockProjects.where((project) {
      return (isUpcoming && project['status'] == '진행 예정') || (!isUpcoming && project['status'] == '진행 완료');
    }).toList();

    return ListView.builder(
      itemCount: filteredProjects.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(filteredProjects[index]['title'], style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(filteredProjects[index]['description']),
        );
      },
    );
  }
}
