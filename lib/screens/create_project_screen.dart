import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:clean_way/token_manager.dart' as myToken;
import '/main.dart';
import '/widgets/location_search.dart';

class CreateProjectScreen extends StatefulWidget {
  @override
  _CreateProjectScreenState createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  TextEditingController crewNameController = TextEditingController();
  TextEditingController capacityController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  List<TextEditingController> wayPointsControllers = [TextEditingController()]; // 경유지를 위한 컨트롤러 리스트
  TextEditingController startLocationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String? selectedOption;

  bool showWaypointField = false;

  Map<String, dynamic> registerCrewData = {
    'cleanCrewDto': {
      'crewName': '',
      'crewContent': '',
      'crewRecruitment': 0,
    },
    'projectRequestDto': {
      'cleanCrewProjectDto': {
        'projectTitle': '',
        'projectContent': '',
        'projectRecruitment': 0,
        'projectDate': '',
        'projectTime': '',
        'projectSLng': 0.0,
        'projectSLat': 0.0,
        'projectDLng': 0.0,
        'projectDLat': 0.0,
        "projectVLng": 0.0,
        "projectVLat": 0.0,
        'projectSName': '',
        'projectDName': '',
        'projectVName': ''
      },
      'projectVLng': [0.0],
      'projectVLat': [0.0],
      'projectVName': [''],
      'projectTagList': ['']
    },
    'crewTagList': ['']
  };

  void _addWayPoint() {
    setState(() {
      if (!showWaypointField) {
        showWaypointField = true;
      } else {
        wayPointsControllers.add(TextEditingController());
        registerCrewData['projectRequestDto']['projectVLat'].add(0.0);
        registerCrewData['projectRequestDto']['projectVLng'].add(0.0);
        registerCrewData['projectRequestDto']['projectVName'].add('');
      }
    });
  }

  void _removeWayPoint(int index) {
    setState(() {
      wayPointsControllers.removeAt(index);
      registerCrewData['projectRequestDto']['projectVLat'].removeAt(index);
      registerCrewData['projectRequestDto']['projectVLng'].removeAt(index);
      registerCrewData['projectRequestDto']['projectVName'].removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _navigateAndDisplaySelection(BuildContext context, TextEditingController controller, String type, {int? index}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LocationSearch()),
    );

    if (result != null) {
      setState(() {
        controller.text = result['spotName'];
        var projectData = registerCrewData['projectRequestDto']['cleanCrewProjectDto'];
        if (type == 'S') {
          projectData['projectSLat'] = result['spotLat'];
          projectData['projectSLng'] = result['spotLng'];
          projectData['projectSName'] = result['spotName'];
        } else if (type == 'D') {
          projectData['projectDLat'] = result['spotLat'];
          projectData['projectDLng'] = result['spotLng'];
          projectData['projectDName'] = result['spotName'];
        } else if (type == 'V' && index != null) {
          registerCrewData['projectRequestDto']['projectVLat'][index] = result['spotLat'];
          registerCrewData['projectRequestDto']['projectVLng'][index] = result['spotLng'];
          registerCrewData['projectRequestDto']['projectVName'][index] = result['spotName'];
        }
      });
    }
  }

  Future<void> _registerCrew() async {
    registerCrewData['cleanCrewDto']['crewName'] = crewNameController.text;
    registerCrewData['cleanCrewDto']['crewContent'] = descriptionController.text;
    registerCrewData['cleanCrewDto']['crewRecruitment'] = int.tryParse(capacityController.text) ?? 0;

    registerCrewData['projectRequestDto']['cleanCrewProjectDto']['projectDate'] = DateFormat('yyyy-MM-dd').format(selectedDate);
    registerCrewData['projectRequestDto']['cleanCrewProjectDto']['projectTime'] = selectedTime.format(context);

    String jsonBody = json.encode(registerCrewData);
    String? token = await myToken.TokenManager.instance.getToken();

    print("Sending data: $jsonBody");

    try {
      http.Response response = await http.post(
        Uri.parse('${dotenv.env['NGROK_URL']}/crew/add'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("success");
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen(initialCrewSelected: true)),
        );
      } else {
        print('Failed to register crew: ${response.statusCode} error');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> routeWidgets = [];
    if (selectedOption == '직접 설정하기') {
      routeWidgets = [
        TextField(
          controller: startLocationController,
          decoration: InputDecoration(
            labelText: '출발지',
            border: OutlineInputBorder(),
          ),
          onTap: () => _navigateAndDisplaySelection(context, startLocationController, 'S'),
        ),
        SizedBox(height: 10),
        if (showWaypointField) ...[
          ...List.generate(wayPointsControllers.length, (index) {
            return Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextField(
                      controller: wayPointsControllers[index],
                      decoration: InputDecoration(
                        labelText: '경유지',
                        border: OutlineInputBorder(),
                      ),
                      onTap: () => _navigateAndDisplaySelection(context, wayPointsControllers[index], 'V', index: index),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () => _removeWayPoint(index),
                ),
              ],
            );
          }).toList(),
          SizedBox(height: 10),
        ],
        TextButton.icon(
          icon: Icon(Icons.add),
          label: Text('경유지 추가'),
          onPressed: _addWayPoint,
        ),
        SizedBox(height: 10),
        TextField(
          controller: destinationController,
          decoration: InputDecoration(
            labelText: '목적지',
            border: OutlineInputBorder(),
          ),
          onTap: () => _navigateAndDisplaySelection(context, destinationController, 'D'),
        ),
        SizedBox(height: 20),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('크루원 모집하기'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '크루명',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: crewNameController,
                decoration: InputDecoration(
                  hintText: '크루의 이름을 지어주세요!',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Text(
                '루트',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              ...[
                '직접 설정하기',
                // '내 루트 불러오기',
                // '내 장소 불러오기'
              ].map((String value) {
                return RadioListTile<String>(
                  title: Text(value),
                  value: value,
                  groupValue: selectedOption,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedOption = newValue;
                    });
                  },
                );
              }).toList(),
              SizedBox(height: 16.0),
              ...routeWidgets,
              SizedBox(height: 16.0),
              Text(
                '날짜',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ListTile(
                title: Text('${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
                onTap: () => _selectDate(context),
              ),
              SizedBox(height: 20),
              Text(
                '시간',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ListTile(
                title: Text('${selectedTime.format(context)}'),
                onTap: () => _selectTime(context),
              ),
              SizedBox(height: 20),
              Text(
                '모집인원',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: capacityController,
                decoration: InputDecoration(
                  hintText: '모집 인원',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20.0),
              Text(
                '모집 내용',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: '모집 내용',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: _registerCrew,
          child: Text('등록하기'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
