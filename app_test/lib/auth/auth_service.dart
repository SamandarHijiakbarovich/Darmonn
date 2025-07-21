import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://khanbook.uz';
  static const Duration timeoutDuration = Duration(seconds: 30);

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Foydalanuvchini ro'yxatdan o'tkazish
  Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/register'),
            headers: {
              'accept': 'application/json',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {
              'first_name': firstName,
              'last_name': lastName,
              'phone_number': phone,
              'password': password,
            },
          )
          .timeout(timeoutDuration);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResult.success(
          message: data['message'] ?? 'Muvaffaqiyatli ro\'yxatdan o\'tdingiz',
        );
      } else {
        return AuthResult.error(
          message: data['message'] ?? 'Ro\'yxatdan o\'tishda xatolik',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return AuthResult.error(message: _getErrorMessage(e), error: e);
    }
  }

  /// Foydalanuvchini tizimga kiritish
  Future<AuthResult> login({
    required String phone,
    required String password,
    bool saveCredentials = true,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {
              'accept': 'application/json',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {'phone_number': phone, 'password': password},
          )
          .timeout(timeoutDuration);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Ma'lumotlarni saqlash
        if (saveCredentials) {
          await _saveCredentials(phone, password);
        }

        return AuthResult.success(
          message: 'Muvaffaqiyatli kirdingiz',
          userData: data,
        );
      } else {
        return AuthResult.error(
          message: data['message'] ?? 'Login yoki parol noto\'g\'ri',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return AuthResult.error(message: _getErrorMessage(e), error: e);
    }
  }

  /// Avtomatik login (saqlangan ma'lumotlar bilan)
  Future<AuthResult> autoLogin() async {
    try {
      final credentials = await _getStoredCredentials();
      if (credentials == null) {
        return AuthResult.error(message: 'Saqlangan ma\'lumotlar topilmadi');
      }

      return await login(
        phone: credentials['phone']!,
        password: credentials['password']!,
        saveCredentials: false, // Allaqachon saqlangan
      );
    } catch (e) {
      return AuthResult.error(message: _getErrorMessage(e), error: e);
    }
  }

  /// Foydalanuvchi ma'lumotlarini olish
  Future<AuthResult> getUserData({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/users/me'),
            headers: {
              'accept': 'application/json',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {'phone_number': phone, 'password': password},
          )
          .timeout(timeoutDuration);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResult.success(
          message: 'Ma\'lumotlar muvaffaqiyatli olindi',
          userData: data,
        );
      } else {
        return AuthResult.error(
          message: 'Ma\'lumotlarni olishda xatolik',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return AuthResult.error(message: _getErrorMessage(e), error: e);
    }
  }

  /// Tizimdan chiqish
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('phone_number');
      await prefs.remove('password');
      await prefs.remove('login_time');
    } catch (e) {
      // Xatolikni e'tiborsiz qoldirish mumkin
      print('Logout error: $e');
    }
  }

  /// Login holatini tekshirish
  Future<bool> isLoggedIn() async {
    try {
      final credentials = await _getStoredCredentials();
      return credentials != null;
    } catch (e) {
      return false;
    }
  }

  /// Ma'lumotlarni saqlash
  Future<void> _saveCredentials(String phone, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone_number', phone);
    await prefs.setString('password', password);
    await prefs.setInt('login_time', DateTime.now().millisecondsSinceEpoch);
  }

  /// Saqlangan ma'lumotlarni olish
  Future<Map<String, String>?> _getStoredCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phone = prefs.getString('phone_number');
      final password = prefs.getString('password');
      final loginTime = prefs.getInt('login_time');

      if (phone != null && password != null) {
        // 30 kun ichida login qilingan bo'lsa
        if (loginTime != null) {
          final loginDate = DateTime.fromMillisecondsSinceEpoch(loginTime);
          final now = DateTime.now();
          final difference = now.difference(loginDate).inDays;

          if (difference > 30) {
            // 30 kundan oshgan bo'lsa, ma'lumotlarni o'chirish
            await logout();
            return null;
          }
        }

        return {'phone': phone, 'password': password};
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Xatolik xabarini formatlash
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('TimeoutException')) {
      return 'Vaqt tugadi. Internet aloqasini tekshiring';
    } else if (error.toString().contains('SocketException')) {
      return 'Internet bilan bog\'lanishda xatolik';
    } else if (error.toString().contains('FormatException')) {
      return 'Server javobini o\'qishda xatolik';
    } else {
      return 'Kutilmagan xatolik yuz berdi';
    }
  }
}

/// Auth operatsiyalari natijasi
class AuthResult {
  final bool isSuccess;
  final String message;
  final Map<String, dynamic>? userData;
  final int? statusCode;
  final dynamic error;

  AuthResult._({
    required this.isSuccess,
    required this.message,
    this.userData,
    this.statusCode,
    this.error,
  });

  /// Muvaffaqiyatli natija
  factory AuthResult.success({
    required String message,
    Map<String, dynamic>? userData,
  }) {
    return AuthResult._(isSuccess: true, message: message, userData: userData);
  }

  /// Xatolik natijasi
  factory AuthResult.error({
    required String message,
    int? statusCode,
    dynamic error,
  }) {
    return AuthResult._(
      isSuccess: false,
      message: message,
      statusCode: statusCode,
      error: error,
    );
  }

  @override
  String toString() {
    return 'AuthResult(isSuccess: $isSuccess, message: $message, statusCode: $statusCode)';
  }
}
