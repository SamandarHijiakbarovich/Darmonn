import 'package:app_test/cart_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  List<dynamic>? _searchResults;
  String _message = '';
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _popularSearches = [
    'Panadol',
    'Aspirin',
    'Ibuprofen',
    'Citramol',
    'Vitamin C',
    'Analgin',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  Future<void> _searchMedicines(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = null;
        _message = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://khanbook.uz/medicines/search?name=${Uri.encodeComponent(query)}',
        ),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final results = jsonDecode(response.body);
        setState(() {
          _searchResults = results;
          _isLoading = false;
          _message = results.isEmpty ? 'Hech narsa topilmadi' : '';
        });
      } else {
        setState(() {
          _message = 'Qidiruvda xatolik yuz berdi';
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
      ),
    );
  }

  void _selectPopularSearch(String query) {
    _searchController.text = query;
    _searchMedicines(query);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
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
              // Qidiruv bo'limi
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.search, color: Color(0xFF2E86C1), size: 28),
                        SizedBox(width: 12),
                        Text(
                          'Dori qidirish',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B4F72),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Qidiruv maydoni
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Color(0xFFE0E0E0), width: 1),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Dori nomini yozing...',
                          hintStyle: TextStyle(
                            color: Color(0xFF85929E),
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Color(0xFF2E86C1),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Color(0xFF85929E),
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchResults = null;
                                      _message = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1B4F72),
                        ),
                        onSubmitted: _searchMedicines,
                        onChanged: (value) {
                          setState(() {});
                          if (value.isNotEmpty) {
                            Future.delayed(Duration(milliseconds: 500), () {
                              if (_searchController.text == value) {
                                _searchMedicines(value);
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Mashhur qidiruvlar yoki natijalar
              Expanded(
                child: _searchResults == null && !_isLoading
                    ? SingleChildScrollView(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mashhur qidiruvlar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B4F72),
                              ),
                            ),

                            SizedBox(height: 16),

                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _popularSearches.map((search) {
                                return GestureDetector(
                                  onTap: () => _selectPopularSearch(search),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(
                                        color: Color(
                                          0xFF2E86C1,
                                        ).withOpacity(0.3),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.trending_up,
                                          color: Color(0xFF2E86C1),
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          search,
                                          style: TextStyle(
                                            color: Color(0xFF2E86C1),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            SizedBox(height: 40),

                            // Qidiruv bo'yicha maslahatlar
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 15,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.lightbulb_outline,
                                        color: Color(0xFFF39C12),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Qidiruv maslahatlar',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1B4F72),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  _buildTip('• Dori nomini to\'liq yozing'),
                                  _buildTip('• Faol moddaning nomini kiriting'),
                                  _buildTip(
                                    '• Kasallik nomini yozishingiz mumkin',
                                  ),
                                  _buildTip(
                                    '• Ishlab chiqaruvchi kompaniya nomi',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : _isLoading
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
                              'Qidiruvda...',
                              style: TextStyle(
                                color: Color(0xFF85929E),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _searchResults!.isNotEmpty
                    ? GridView.builder(
                        padding: EdgeInsets.all(16),
                        physics: BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _searchResults!.length,
                        itemBuilder: (context, index) {
                          final medicine = _searchResults![index];

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
                                                  ) => _buildPlaceholderImage(),
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
                                                overflow: TextOverflow.ellipsis,
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
                                              onTap: () => _addToCart(medicine),
                                              child: Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF2E86C1),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
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
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Color(0xFF85929E),
                            ),
                            SizedBox(height: 16),
                            Text(
                              _message.isNotEmpty
                                  ? _message
                                  : 'Hech narsa topilmadi',
                              style: TextStyle(
                                color: Color(0xFF85929E),
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Boshqa so\'z bilan qidirib ko\'ring',
                              style: TextStyle(
                                color: Color(0xFF85929E),
                                fontSize: 14,
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

  Widget _buildTip(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(color: Color(0xFF85929E), fontSize: 14),
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
