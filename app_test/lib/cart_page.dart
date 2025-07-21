import 'dart:async';

class Cart {
  static final Cart _instance = Cart._internal();
  factory Cart() => _instance;
  Cart._internal();

  List<Map<String, dynamic>> _items = [];
  final StreamController<List<Map<String, dynamic>>> _itemsController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  /// Savat elementlari
  List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  /// Savat elementlari stream
  Stream<List<Map<String, dynamic>>> get itemsStream => _itemsController.stream;

  /// Savat elementlari soni
  int get itemCount => _items.length;

  /// Savat elementlari soni stream
  Stream<int> get itemCountStream =>
      _itemsController.stream.map((items) => items.length);

  /// Umumiy narx
  double get totalPrice {
    return _items.fold(0.0, (sum, item) {
      final price = item['price'];
      if (price is num) {
        return sum + price.toDouble();
      }
      return sum;
    });
  }

  /// Umumiy narx stream
  Stream<double> get totalPriceStream => _itemsController.stream.map((items) {
    return items.fold(0.0, (sum, item) {
      final price = item['price'];
      if (price is num) {
        return sum + price.toDouble();
      }
      return sum;
    });
  });

  /// Mahsulot qo'shish
  void addItem(Map<String, dynamic> medicine) {
    // Dublikat tekshirish
    final existingIndex = _items.indexWhere(
      (item) =>
          item['id'] == medicine['id'] || item['name'] == medicine['name'],
    );

    if (existingIndex != -1) {
      // Agar mahsulot allaqachon mavjud bo'lsa, miqdorini oshirish
      final existingItem = Map<String, dynamic>.from(_items[existingIndex]);
      final currentQuantity = existingItem['quantity'] ?? 1;
      existingItem['quantity'] = currentQuantity + 1;
      _items[existingIndex] = existingItem;
    } else {
      // Yangi mahsulot qo'shish
      final newItem = Map<String, dynamic>.from(medicine);
      newItem['quantity'] = 1;
      newItem['added_at'] = DateTime.now().toIso8601String();
      _items.add(newItem);
    }

    _notifyListeners();
  }

  /// Mahsulot o'chirish (index bo'yicha)
  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      _notifyListeners();
    }
  }

  /// Mahsulot o'chirish (ID bo'yicha)
  void removeItemById(dynamic id) {
    _items.removeWhere((item) => item['id'] == id);
    _notifyListeners();
  }

  /// Mahsulot miqdorini yangilash
  void updateQuantity(int index, int quantity) {
    if (index >= 0 && index < _items.length) {
      if (quantity <= 0) {
        removeItem(index);
      } else {
        _items[index]['quantity'] = quantity;
        _notifyListeners();
      }
    }
  }

  /// Mahsulot mavjudligini tekshirish
  bool containsItem(dynamic id) {
    return _items.any((item) => item['id'] == id);
  }

  /// Mahsulot miqdorini olish
  int getItemQuantity(dynamic id) {
    final item = _items.firstWhere(
      (item) => item['id'] == id,
      orElse: () => <String, dynamic>{},
    );
    return item['quantity'] ?? 0;
  }

  /// Savatni tozalash
  void clearCart() {
    _items.clear();
    _notifyListeners();
  }

  /// Ma'lum kategoriya mahsulotlarini o'chirish
  void clearCategory(String category) {
    _items.removeWhere((item) => item['category'] == category);
    _notifyListeners();
  }

  /// Savat ma'lumotlarini JSON formatda olish
  Map<String, dynamic> toJson() {
    return {
      'items': _items,
      'total_price': totalPrice,
      'item_count': itemCount,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// JSON dan savat ma'lumotlarini yuklash
  void fromJson(Map<String, dynamic> json) {
    if (json['items'] is List) {
      _items = List<Map<String, dynamic>>.from(json['items']);
      _notifyListeners();
    }
  }

  /// Savatni seriallashtirish (local storage uchun)
  String serialize() {
    return _items.map((item) => '${item['id']}:${item['quantity']}').join(',');
  }

  /// Savatni deseriallashtirish
  void deserialize(String data, List<Map<String, dynamic>> allMedicines) {
    if (data.isEmpty) return;

    final pairs = data.split(',');
    _items.clear();

    for (final pair in pairs) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        final id = parts[0];
        final quantity = int.tryParse(parts[1]) ?? 1;

        final medicine = allMedicines.firstWhere(
          (item) => item['id'].toString() == id,
          orElse: () => <String, dynamic>{},
        );

        if (medicine.isNotEmpty) {
          final cartItem = Map<String, dynamic>.from(medicine);
          cartItem['quantity'] = quantity;
          _items.add(cartItem);
        }
      }
    }

    _notifyListeners();
  }

  /// Listenerlarga xabar berish
  void _notifyListeners() {
    _itemsController.add(List.unmodifiable(_items));
  }

  /// Stream controllerni yopish
  void dispose() {
    _itemsController.close();
  }
}
