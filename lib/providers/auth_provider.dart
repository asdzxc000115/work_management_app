import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId != null) {
      // 저장된 사용자 정보로 자동 로그인
      _currentUser = await AuthService.getUserById(userId);
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await AuthService.login(email, password);
      if (user != null) {
        _currentUser = user;

        // 로그인 정보 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', user.id!);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = '이메일 또는 비밀번호가 올바르지 않습니다';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '로그인 중 오류가 발생했습니다';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 이메일 중복 체크
      final existingUser = await AuthService.getUserByEmail(email);
      if (existingUser != null) {
        _errorMessage = '이미 사용중인 이메일입니다';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final success = await AuthService.signup(name, email, password);
      _isLoading = false;
      if (!success) {
        _errorMessage = '회원가입 중 오류가 발생했습니다';
      }
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = '회원가입 중 오류가 발생했습니다';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;

    // 저장된 로그인 정보 삭제
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');

    notifyListeners();
  }
}