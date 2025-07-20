import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://khanbook.uz';

  // Umumiy headerlar
  Map<String, String> get _headers => {
        'Content-Type': 'application/x-www-form-urlencoded',
        'accept': 'application/json',
      };

  // Umumiy HTTP POST so‘rov funksiyasi
  Future<Map<String, dynamic>> _postRequest(String endpoint, Map<String, String> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          jsonDecode(response.body)['detail'] ?? 'So‘rovda xatolik yuz berdi',
        );
      }
    } catch (e) {
      throw Exception('Xatolik: ${e.toString()}');
    }
  }

  // Umumiy HTTP GET so‘rov funksiyasi
  Future<List<dynamic>> _getRequest(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          jsonDecode(response.body)['detail'] ?? 'So‘rovda xatolik yuz berdi',
        );
      }
    } catch (e) {
      throw Exception('Xatolik: ${e.toString()}');
    }
  }

  // Umumiy HTTP DELETE so‘rov funksiyasi
  Future<Map<String, dynamic>> _deleteRequest(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json', 'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          jsonDecode(response.body)['detail'] ?? 'So‘rovda xatolik yuz berdi',
        );
      }
    } catch (e) {
      throw Exception('Xatolik: ${e.toString()}');
    }
  }

  // Telefon raqami va parolni shared_preferences dan olish
  Future<Map<String, String>> _getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'phone_number': prefs.getString('phone_number') ?? '',
      'password': prefs.getString('password') ?? '',
    };
  }

  // Telefon raqami va parolni shared_preferences ga saqlash
  Future<void> _saveCredentials(String phoneNumber, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone_number', phoneNumber);
    await prefs.setString('password', password);
  }

  // Ro‘yxatdan o‘tish
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
  }) async {
    final response = await _postRequest('register', {
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'password': password,
    });
    await _saveCredentials(phoneNumber, password);
    return response;
  }

  // Kirish
  Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String password,
  }) async {
    final response = await _postRequest('login', {
      'phone_number': phoneNumber,
      'password': password,
    });
    await _saveCredentials(phoneNumber, password);
    return response;
  }

  // Foydalanuvchi profilini olish
  Future<Map<String, dynamic>> getMyProfile({required String phoneNumber, required String password}) async {
    final credentials = await _getCredentials();
    if (credentials['phone_number']!.isEmpty || credentials['password']!.isEmpty) {
      throw Exception('Foydalanuvchi ma\'lumotlari topilmadi. Iltimos, qayta kiring.');
    }
    return await _postRequest('users/me', {
      'phone_number': credentials['phone_number']!,
      'password': credentials['password']!,
    });
  }

  // Foydalanuvchi buyurtmalarini olish
  Future<List<dynamic>> getMyOrders() async {
    final credentials = await _getCredentials();
    if (credentials['phone_number']!.isEmpty || credentials['password']!.isEmpty) {
      throw Exception('Foydalanuvchi ma\'lumotlari topilmadi. Iltimos, qayta kiring.');
    }
    final response = await _postRequest('users/me/orders', {
      'phone_number': credentials['phone_number']!,
      'password': credentials['password']!,
    });
    return response as List<dynamic>;
  }

  // Foydalanuvchini o‘chirish
  Future<Map<String, dynamic>> deleteUser({required int userId}) async {
    return await _deleteRequest('users/$userId');
  }

  // Dorilar ro‘yxatini olish
  Future<List<dynamic>> getMedicines() async {
    return await _getRequest('medicines');
  }
}