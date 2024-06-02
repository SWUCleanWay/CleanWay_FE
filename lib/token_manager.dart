import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  SharedPreferences? _prefs;

  factory TokenManager() {
    return _instance;
  }

  TokenManager._internal();

  static TokenManager get instance => _instance;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    print("SharedPreferences 초기화 완료");
  }

  Future<String?> getToken() async {
    String? token = _prefs?.getString('authToken');
    print("불러온 토큰: $token");
    return token;
  }

  Future<void> setToken(String token) async {
    await _prefs?.setString('authToken', token);
    print("저장된 토큰: $token");
  }

  Future<void> clearToken() async {
    await _prefs?.remove('authToken');
    print("토큰 삭제 완료");
  }
}