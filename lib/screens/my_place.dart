import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:clean_way/token_manager.dart' as myToken;
import 'dart:convert';


class Spot {
  final int reportNumber;
  final int userNumber;
  final int spotNumber;
  final double spotLat;
  final double spotLng;
  final String spotName;

  Spot({
    required this.reportNumber,
    required this.userNumber,
    required this.spotNumber,
    required this.spotLat,
    required this.spotLng,
    required this.spotName,
  });

  factory Spot.fromJson(Map<String, dynamic> json) {
    return Spot(
      reportNumber: json['reportNumber'],
      userNumber: json['userNumber'],
      spotNumber: json['spotNumber'],
      spotLat: json['spotLat']??0.0,
      spotLng: json['spotIng']??0.0,
      spotName: json['spotName'],
    );
  }
}

class MyPlace extends StatefulWidget {
  @override
  _MyPlaceState createState() => _MyPlaceState();
}

class _MyPlaceState extends State<MyPlace> {
  late Future<List<Spot>> spots;

  @override
  void initState() {
    super.initState();
    spots = fetchSpots();
  }

  Future<List<Spot>> fetchSpots() async {
    // String url = '${dotenv.env['NGROK_URL']}/mypage/myspot';
    String? token = await myToken.TokenManager.instance.getToken();
    String? baseUrl = dotenv.env['NGROK_URL'];
    var url = Uri.parse('$baseUrl/mypage/myspot');
    // var response = await http.get(Uri.parse(url));
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> spotList = json.decode(utf8.decode(response.bodyBytes));
      return spotList.map((json) => Spot.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load spots');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("내 장소"),
      ),
      body: FutureBuilder<List<Spot>>(
        future: spots,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return ListView.separated(
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      snapshot.data![index].spotName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
