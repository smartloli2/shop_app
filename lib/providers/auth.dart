import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;

  String _userId;
  Timer _authTimer;

  String get userId {
    return _userId;
  }

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> _authentication(
      String email, String password, String segmentUrl) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$segmentUrl?key=AIzaSyDhi4aQaICpXwIJA1NGJK0Mb_1HHGHx9M4';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );

      //print(response.body);
      final responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      // Set the auto-logout timer
      _autoLogout();
      notifyListeners();
      // Save token on the device
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      prefs.setString('userData', userData);
      //print('userData was saved!');
    } catch (error) {
      throw error;
    }

    // print(json.decode(response.body));
  }

  Future<void> signup(String email, String password) async {
    return _authentication(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authentication(email, password, 'signInWithPassword');
  }

  // Try to login user
  Future<bool> tryAutoLogin() async {
    // print('Try logout');
    // Check if user data exists
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }

    // Extract user data from the device
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    // If token is expiry
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    // Extract the rest of the saved info from the device
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    // print(true);
    return true;
  }

  void logout() async {
    _token = null;
    _expiryDate = null;
    _userId = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    Timer(Duration(seconds: timeToExpiry), logout);
  }
}
