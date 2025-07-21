import 'package:app_test/cart_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final int userId;
  final String fullName;
  final String role;

  HomePage({required this.userId, required this.fullName, required this.role});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<dynamic>? _medicines;
  String _message = '';
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedCategory = 'Hammasi';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Hammasi', 'icon': Icons.medication, 'color': Color(0xFF2E86C1)},
    {
      'name': 'Og\'riq qoldiruvchi',
      'icon': Icons.healing,
      'color': Color(0xFFE74C3C),
    },
    {
      'name': 'Antibiotiklar',
      'icon': Icons.vaccines,
      'color': Color(0xFF28B463),
    },
    {
      'name': 'Vitaminlar',
      'icon': Icons.medical_services,
      'color': Color(0xFFF39C12),
    },
    {
      'name': 'Yurak dorilar',
      'icon': Icons.favorite,
      'color': Color(0xFF9B59B6),
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _fetchMedicines();
    _animationController.forward();
  }

  Future<void> _fetchMedicines() async {
    try {
      final response = await http.get(
        Uri.parse('https://khanbook.uz/medicines'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _medicines = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _message = 'Ma\'lumotlarni olishda xatolik: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Internet bilan bog\'lanishda xatolik';
        _isLoading = false;
      });
    }
  }

  void _addToCart(Map<String, dynamic> medicine) {
    Cart().addItem(medicine);

    // Animatsiyali SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.shopping_cart, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '${medicine['name']} savatga qo\'shildi',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.check_circle, color: Colors.white),
          ],
        ),
        backgroundColor: Color(0xFF28B463),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 2),
      ),
    );
  }

  List<dynamic> _getFilteredMedicines() {
    if (_medicines == null) return [];
    if (_selectedCategory == 'Hammasi') return _medicines!;

    // Bu yerda kategoriya bo'yicha filtrlash mantigi bo'lishi kerak
    // Hozircha barcha dorilarni qaytaramiz
    return _medicines!;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Yuqori qism - Salom va Profil
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF2E86C1),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF2E86C1).withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Salom!',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              widget.fullName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Xavfsizlik ko'rsatkichlari
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.verified, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Litsenziyali',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          SizedBox(width: 16),
                          Icon(
                            Icons.local_shipping,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Tez yetkazish',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          SizedBox(width: 16),
                          Icon(
                            Icons.support_agent,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '24/7',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Kategoriyalar
              Container(
                height: 130,
                padding: EdgeInsets.symmetric(vertical: 20),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category['name'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category['name'];
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.only(right: 16),
                        padding: EdgeInsets.all(16),
                        width: 80,
                        decoration: BoxDecoration(
                          color: isSelected ? category['color'] : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? category['color'].withOpacity(0.3)
                                  : Colors.black.withOpacity(0.05),
                              blurRadius: isSelected ? 15 : 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              category['icon'],
                              color: isSelected
                                  ? Colors.white
                                  : category['color'],
                              size: 28,
                            ),
                            SizedBox(height: 8),
                            Text(
                              category['name'].split(
                                ' ',
                              )[0], // Faqat birinchi so'z
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Color(0xFF1B4F72),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Mahsulotlar
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF2E86C1),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Dorilar yuklanmoqda...',
                              style: TextStyle(
                                color: Color(0xFF85929E),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _getFilteredMedicines().isNotEmpty
                    ? RefreshIndicator(
                        color: Color(0xFF2E86C1),
                        onRefresh: _fetchMedicines,
                        child: GridView.builder(
                          padding: EdgeInsets.all(16),
                          physics: BouncingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.75,
                              ),
                          itemCount: _getFilteredMedicines().length,
                          itemBuilder: (context, index) {
                            final medicine = _getFilteredMedicines()[index];

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 15,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Rasm
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                        color: Color(0xFFF8F9FA),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                        child: medicine['image1'] != null
                                            ? Image.network(
                                                medicine['image1'],
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) =>
                                                        _buildPlaceholderImage(),
                                              )
                                            : _buildPlaceholderImage(),
                                      ),
                                    ),
                                  ),

                                  // Ma'lumotlar
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            medicine['name'] ?? 'Noma\'lum',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1B4F72),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),

                                          SizedBox(height: 4),

                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                size: 12,
                                                color: Color(0xFF85929E),
                                              ),
                                              SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  medicine['address'] ??
                                                      'Manzil yo\'q',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Color(0xFF85929E),
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),

                                          Spacer(),

                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${medicine['price'] ?? 0} so\'m',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2E86C1),
                                                ),
                                              ),

                                              GestureDetector(
                                                onTap: () =>
                                                    _addToCart(medicine),
                                                child: Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF2E86C1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons.add_shopping_cart,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.medication,
                              size: 80,
                              color: Color(0xFF85929E),
                            ),
                            SizedBox(height: 16),
                            Text(
                              _message.isNotEmpty
                                  ? _message
                                  : 'Hozircha dorilar yo\'q',
                              style: TextStyle(
                                color: Color(0xFF85929E),
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _fetchMedicines,
                              icon: Icon(Icons.refresh),
                              label: Text('Qayta yuklash'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF2E86C1),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Color(0xFFF8F9FA),
      child: Icon(Icons.medical_services, size: 40, color: Color(0xFF85929E)),
    );
  }
}
