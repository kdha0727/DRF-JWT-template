import 'dart:convert' show jsonEncode, jsonDecode, utf8;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


const String apiBaseUri = 'http://localhost:8000/api/v1';  // TODO <- change this to your server's address


class UnwantedResponse extends http.ClientException {
  final http.Response response;
  UnwantedResponse(this.response) : super(response.body, response.request?.url);
  int get statusCode => response.statusCode;
  String get body => response.body.isEmpty ? {} : jsonDecode(utf8.decode(response.bodyBytes));
  Map<String, dynamic> get bodyMap => response.body.isEmpty ? {} : jsonDecode(utf8.decode(response.bodyBytes));
  @override
  String toString() => '$runtimeType: $statusCode ${response.reasonPhrase}${bodyMap.containsKey('detail') ? ' - ${bodyMap['detail']}' : ''}';
}


abstract class AuthTokenWrapper {
  Future<int?> getUserPK();
  Future<String?> getUserEmail();
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> setUserPK(int pk);
  Future<void> setUserEmail(String email);
  Future<void> setAccessToken(String token);
  Future<void> setRefreshToken(String token);
  Future<void> deleteUserPK();
  Future<void> deleteUserEmail();
  Future<void> deleteAccessToken();
  Future<void> deleteRefreshToken();
  Future<void> update({
    int? userPK,
    String? userEmail,
    String? accessToken,
    String? refreshToken,
  }) async {
    if (null != userPK) await setUserPK(userPK);
    if (null != userEmail) await setUserEmail(userEmail);
    if (null != accessToken) await setAccessToken(accessToken);
    if (null != refreshToken) await setRefreshToken(refreshToken);
  }
  Future<void> clear() async {
    await deleteUserPK();
    await deleteUserEmail();
    await deleteAccessToken();
    await deleteRefreshToken();
  }
}


class TemporaryAuthTokenWrapper extends AuthTokenWrapper {
  TemporaryAuthTokenWrapper._();
  static final TemporaryAuthTokenWrapper instance = TemporaryAuthTokenWrapper._();
  factory TemporaryAuthTokenWrapper() => instance;  // Make it as singleton
  static int? _userPK;
  static String? _userEmail;
  static String? _accessToken;
  static String? _refreshToken;
  @override
  Future<int?> getUserPK() async => _userPK;
  @override
  Future<String?> getUserEmail() async => _userEmail;
  @override
  Future<String?> getAccessToken() async => _accessToken;
  @override
  Future<String?> getRefreshToken() async => _refreshToken;
  @override
  Future<void> setUserPK(int pk) async => _userPK = pk;
  @override
  Future<void> setUserEmail(String email) async => _userEmail = email;
  @override
  Future<void> setAccessToken(String token) async => _accessToken = token;
  @override
  Future<void> setRefreshToken(String token) async => _refreshToken = token;
  @override
  Future<void> deleteUserPK() async => _userPK = null;
  @override
  Future<void> deleteUserEmail() async => _userEmail = null;
  @override
  Future<void> deleteAccessToken() async => _accessToken = null;
  @override
  Future<void> deleteRefreshToken() async => _refreshToken = null;
}


class FlutterAuthTokenWrapper extends AuthTokenWrapper {
  FlutterAuthTokenWrapper._();
  static final FlutterAuthTokenWrapper instance = FlutterAuthTokenWrapper._();
  factory FlutterAuthTokenWrapper() => instance;  // Make it as singleton
  static const FlutterSecureStorage storage = FlutterSecureStorage();
  static const String userPKKey = 'auth-user-pk';
  static const String userEmailKey = 'auth-user-email';
  static const String jwtAccessTokenKey = 'jwt-auth-access-token';
  static const String jwtRefreshTokenKey = 'jwt-auth-refresh-token';
  @override
  Future<int?> getUserPK() async => int.tryParse(await storage.read(key: userPKKey) ?? '');
  @override
  Future<String?> getUserEmail() async => await storage.read(key: userEmailKey);
  @override
  Future<String?> getAccessToken() async => await storage.read(key: jwtAccessTokenKey);
  @override
  Future<String?> getRefreshToken() async => await storage.read(key: jwtRefreshTokenKey);
  @override
  Future<void> setUserPK(int pk) async => await storage.write(key: userPKKey, value: pk.toString());
  @override
  Future<void> setUserEmail(String email) async => await storage.write(key: userEmailKey, value: email);
  @override
  Future<void> setAccessToken(String token) async => await storage.write(key: jwtAccessTokenKey, value: token);
  @override
  Future<void> setRefreshToken(String token) async => await storage.write(key: jwtRefreshTokenKey, value: token);
  @override
  Future<void> deleteUserPK() async => await storage.delete(key: userPKKey);
  @override
  Future<void> deleteUserEmail() async => await storage.delete(key: userEmailKey);
  @override
  Future<void> deleteAccessToken() async => await storage.delete(key: jwtAccessTokenKey);
  @override
  Future<void> deleteRefreshToken() async => await storage.delete(key: jwtRefreshTokenKey);
}


class AuthAPI {
  static const String uri = '$apiBaseUri/accounts';

  static final AuthTokenWrapper tokenWrapper = FlutterAuthTokenWrapper();  // TemporaryAuthTokenWrapper();

  static Future<void> login(String email, String password) async {
    final url = Uri.parse('$uri/login/');
    final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password})
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      var userPK = data['user']['pk'];
      var userEmail = data['user']['email'];
      var accessToken = data['access'];
      var refreshToken = data['refresh'];
      tokenWrapper.update(
        userPK: userPK,
        userEmail: userEmail,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      await tokenWrapper.getAccessToken();  // dummy call
    } else {
      throw UnwantedResponse(response);
    }
  }

  static Future<void> logout() async {
    final url = Uri.parse('$uri/logout/');
    final response = await http.post(url, headers: await addAuthHeader());
    if (response.statusCode != 204) {
      // throw UnwantedResponse(response);
    }
    tokenWrapper.clear();
  }

  static Future<bool> isLoggedIn() async => (await tokenWrapper.getUserPK()) != 0;

  static Future<Map<String, String>> addAuthHeader([Map<String, String>? original]) async => {
    ...original ?? {},
    if (await isLoggedIn()) "Authorization": "Bearer ${await tokenWrapper.getAccessToken()}"
  };

}
