import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrdersService {
  static const String baseUrl = 'https://khanbook.uz';
  static const Duration timeoutDuration = Duration(seconds: 30);

  // Singleton pattern
  static final OrdersService _instance = OrdersService._internal();
  factory OrdersService() => _instance;
  OrdersService._internal();

  /// Foydalanuvchi buyurtmalarini olish
  Future<OrdersResult> getUserOrders({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/users/me/orders'),
            headers: {
              'accept': 'application/json',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
          )
          .timeout(timeoutDuration);

      // POST request sifatida yuborish kerak bo'lsa:
      final postResponse = await http
          .post(
            Uri.parse('$baseUrl/users/me/orders'),
            headers: {
              'accept': 'application/json',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {'phone_number': phoneNumber, 'password': password},
          )
          .timeout(timeoutDuration);

      if (postResponse.statusCode == 200) {
        final List<dynamic> ordersData = jsonDecode(postResponse.body);
        final orders = ordersData
            .map((order) => OrderModel.fromJson(order))
            .toList();

        return OrdersResult.success(
          message: 'Buyurtmalar muvaffaqiyatli yuklandi',
          orders: orders,
        );
      } else {
        return OrdersResult.error(
          message: 'Buyurtmalarni yuklashda xatolik',
          statusCode: postResponse.statusCode,
        );
      }
    } catch (e) {
      return OrdersResult.error(message: _getErrorMessage(e), error: e);
    }
  }

  /// Buyurtma berish
  Future<OrdersResult> createOrder({
    required String phoneNumber,
    required String password,
    required int medicineId,
    required String deliveryAddress,
    int? pharmacyId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/orders'),
            headers: {
              'accept': 'application/json',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {
              'phone_number': phoneNumber,
              'password': password,
              'medicine_id': medicineId.toString(),
              'delivery_address': deliveryAddress,
              if (pharmacyId != null) 'pharmacy_id': pharmacyId.toString(),
            },
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final orderData = jsonDecode(response.body);
        final order = OrderModel.fromJson(orderData);

        return OrdersResult.success(
          message: 'Buyurtma muvaffaqiyatli yaratildi',
          orders: [order],
        );
      } else {
        final errorData = jsonDecode(response.body);
        return OrdersResult.error(
          message: errorData['message'] ?? 'Buyurtma yaratishda xatolik',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return OrdersResult.error(message: _getErrorMessage(e), error: e);
    }
  }

  /// Buyurtma holatini yangilash
  Future<OrdersResult> updateOrderStatus({
    required String phoneNumber,
    required String password,
    required int orderId,
    required String status,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/orders/$orderId'),
            headers: {
              'accept': 'application/json',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {
              'phone_number': phoneNumber,
              'password': password,
              'status': status,
            },
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final orderData = jsonDecode(response.body);
        final order = OrderModel.fromJson(orderData);

        return OrdersResult.success(
          message: 'Buyurtma holati yangilandi',
          orders: [order],
        );
      } else {
        return OrdersResult.error(
          message: 'Buyurtma holatini yangilashda xatolik',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return OrdersResult.error(message: _getErrorMessage(e), error: e);
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

/// Buyurtma modeli
class OrderModel {
  final int id;
  final int userId;
  final int pharmacyId;
  final int medicineId;
  final String status;
  final String createdAt;
  final String deliveryAddress;
  final int? courierId;

  OrderModel({
    required this.id,
    required this.userId,
    required this.pharmacyId,
    required this.medicineId,
    required this.status,
    required this.createdAt,
    required this.deliveryAddress,
    this.courierId,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      pharmacyId: json['pharmacy_id'] ?? 0,
      medicineId: json['medicine_id'] ?? 0,
      status: json['status'] ?? 'yangi',
      createdAt: json['created_at'] ?? '',
      deliveryAddress: json['delivery_address'] ?? '',
      courierId: json['courier_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'pharmacy_id': pharmacyId,
      'medicine_id': medicineId,
      'status': status,
      'created_at': createdAt,
      'delivery_address': deliveryAddress,
      'courier_id': courierId,
    };
  }

  /// Buyurtma holatining rangi
  Color getStatusColor() {
    switch (status.toLowerCase()) {
      case 'yangi':
        return Color(0xFF2E86C1); // Ko'k
      case 'tasdiqlangan':
        return Color(0xFFF39C12); // Sariq
      case 'tayyorlanmoqda':
        return Color(0xFF9B59B6); // Binafsha
      case 'yetkazilmoqda':
        return Color(0xFF28B463); // Yashil
      case 'yetkazilgan':
        return Color(0xFF27AE60); // To'q yashil
      case 'bekor_qilingan':
        return Color(0xFFE74C3C); // Qizil
      default:
        return Color(0xFF85929E); // Kulrang
    }
  }

  /// Buyurtma holatining matni
  String getStatusText() {
    switch (status.toLowerCase()) {
      case 'yangi':
        return 'Yangi';
      case 'tasdiqlangan':
        return 'Tasdiqlangan';
      case 'tayyorlanmoqda':
        return 'Tayyorlanmoqda';
      case 'yetkazilmoqda':
        return 'Yetkazilmoqda';
      case 'yetkazilgan':
        return 'Yetkazilgan';
      case 'bekor_qilingan':
        return 'Bekor qilingan';
      default:
        return 'Noma\'lum';
    }
  }

  /// Buyurtma holatining icon'i
  IconData getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'yangi':
        return Icons.fiber_new;
      case 'tasdiqlangan':
        return Icons.check_circle_outline;
      case 'tayyorlanmoqda':
        return Icons.inventory;
      case 'yetkazilmoqda':
        return Icons.local_shipping;
      case 'yetkazilgan':
        return Icons.done_all;
      case 'bekor_qilingan':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  /// Sana formatini o'zgartirish
  String getFormattedDate() {
    try {
      final dateTime = DateTime.parse(createdAt);
      return '${dateTime.day}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return createdAt;
    }
  }
}

/// Buyurtmalar xizmati natijasi
class OrdersResult {
  final bool isSuccess;
  final String message;
  final List<OrderModel>? orders;
  final int? statusCode;
  final dynamic error;

  OrdersResult._({
    required this.isSuccess,
    required this.message,
    this.orders,
    this.statusCode,
    this.error,
  });

  /// Muvaffaqiyatli natija
  factory OrdersResult.success({
    required String message,
    List<OrderModel>? orders,
  }) {
    return OrdersResult._(isSuccess: true, message: message, orders: orders);
  }

  /// Xatolik natijasi
  factory OrdersResult.error({
    required String message,
    int? statusCode,
    dynamic error,
  }) {
    return OrdersResult._(
      isSuccess: false,
      message: message,
      statusCode: statusCode,
      error: error,
    );
  }

  @override
  String toString() {
    return 'OrdersResult(isSuccess: $isSuccess, message: $message, ordersCount: ${orders?.length ?? 0})';
  }
}
