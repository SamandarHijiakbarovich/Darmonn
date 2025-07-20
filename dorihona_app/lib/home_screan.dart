import 'package:dorihona_app/api_service.dart';
import 'package:dorihona_app/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class HomeScreen extends StatefulWidget {
  final int userId;
  final String phoneNumber;
  final String password;

  const HomeScreen({
    Key? key,
    required this.userId,
    required this.phoneNumber,
    required this.password,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ApiService _apiService = ApiService();
  List<dynamic> _orders = [];
  List<dynamic> _medicines = [];
  bool _isLoading = false;
  bool _isLoadingMedicines = false;
  String? _errorMessage;
  String? _errorMessageMedicines;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _fetchMedicines();
  }

  void _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final orders = await _apiService.getMyOrders();
      setState(() {
        _orders = orders;
        debugPrint('Buyurtmalar: $orders');
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        debugPrint('Buyurtma xatosi: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _fetchMedicines() async {
    setState(() {
      _isLoadingMedicines = true;
      _errorMessageMedicines = null;
    });

    try {
      final medicines = await _apiService.getMedicines();
      setState(() {
        _medicines = medicines;
        debugPrint('Dorilar: $medicines');
      });
    } catch (e) {
      setState(() {
        _errorMessageMedicines = e.toString();
        debugPrint('Dorilar xatosi: $e');
      });
    } finally {
      setState(() {
        _isLoadingMedicines = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(
            userId: widget.userId,
            phoneNumber: widget.phoneNumber,
            password: widget.password,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFF2E86C1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '💊 Dorihona',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF85929E),
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Qidiruv
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Color(0xFF85929E)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Dori, vitamin yoki tibbiy asbob qidiring...',
                        style: TextStyle(
                          color: Color(0xFF85929E),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Icon(Icons.mic, color: Color(0xFF85929E)),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Ishonch belgilari
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTrustBadge('✅', 'Litsenziyali'),
                    _buildTrustBadge('🚚', 'Tez yetkazish'),
                    _buildTrustBadge('💳', 'Xavfsiz to\'lov'),
                    _buildTrustBadge('📞', '24/7 yordam'),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Kategoriyalar
              Text(
                'Kategoriyalar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4F72),
                ),
              ),
              SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildCategoryCard('💊', 'Dorilar', Color(0xFF2E86C1)),
                  _buildCategoryCard(
                    '🩹',
                    'Tibbiy asboblar',
                    Color(0xFF28B463),
                  ),
                  _buildCategoryCard('💉', 'Vitaminlar', Color(0xFFF39C12)),
                  _buildCategoryCard('🔬', 'Tahlil', Color(0xFFE74C3C)),
                ],
              ),
              SizedBox(height: 24),

              // Mashhur mahsulotlar
              Text(
                'Mashhur mahsulotlar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4F72),
                ),
              ),
              SizedBox(height: 16),
              _isLoadingMedicines
                  ? Center(child: CircularProgressIndicator())
                  : _errorMessageMedicines != null
                  ? Text(
                      _errorMessageMedicines!,
                      style: TextStyle(color: Colors.red),
                    )
                  : _medicines.isEmpty
                  ? Text('Hozircha dorilar yo‘q')
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _medicines.length,
                      itemBuilder: (context, index) {
                        final medicine = _medicines[index];
                        return _buildProductCard(medicine);
                      },
                    ),

              SizedBox(height: 24),

              // Buyurtmalar
              Text(
                'Mening buyurtmalarim',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4F72),
                ),
              ),
              SizedBox(height: 16),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Text(_errorMessage!, style: TextStyle(color: Colors.red))
                  : _orders.isEmpty
                  ? Text('Hozircha buyurtmalar yo‘q')
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        return _buildOrderCard(order);
                      },
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF2E86C1),
        unselectedItemColor: Color(0xFF85929E),
        backgroundColor: Colors.white,
        elevation: 8,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Bosh sahifa'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Qidiruv'),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Color(0xFFE74C3C),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            label: 'Savat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Buyurtmalar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(String emoji, String text) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: 24)),
        SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 10,
            color: Color(0xFF1B4F72),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String emoji, String title, Color color) {
    return GestureDetector(
      onTap: () {
        // Kategoriya sahifasiga o‘tish
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(emoji, style: TextStyle(fontSize: 24))),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B4F72),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(dynamic medicine) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Mahsulot rasmi
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFFE5E5E5)),
            ),
            child: Center(
              child: medicine['image1'] != null
                  ? Image.network(
                      medicine['image1'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Text('💊', style: TextStyle(fontSize: 32)),
                    )
                  : Text('💊', style: TextStyle(fontSize: 32)),
            ),
          ),
          SizedBox(width: 12),
          // Mahsulot ma'lumotlari
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine['name']?.toString() ?? 'Noma\'lum dori',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B4F72),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  medicine['description']?.toString() ?? 'Tavsif yo‘q',
                  style: TextStyle(fontSize: 12, color: Color(0xFF85929E)),
                ),
                SizedBox(height: 8),
                Text(
                  medicine['price'] != null
                      ? '${medicine['price'].toStringAsFixed(0)} so\'m'
                      : 'Narx topilmadi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E86C1),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Savatga qo‘shish logikasi
                        debugPrint('Savatga qo‘shildi: ${medicine['name']}');
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF2E86C1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.add_shopping_cart,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        // Sevimlilarga qo‘shish logikasi
                        debugPrint(
                          'Sevimlilarga qo‘shildi: ${medicine['name']}',
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Color(0xFFE5E5E5)),
                        ),
                        child: Icon(
                          Icons.favorite_border,
                          color: Color(0xFFE74C3C),
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buyurtma ID: ${order['id']}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4F72),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Dori ID: ${order['medicine_id']}',
            style: TextStyle(fontSize: 14, color: Color(0xFF85929E)),
          ),
          Text(
            'Dorixona ID: ${order['pharmacy_id']}',
            style: TextStyle(fontSize: 14, color: Color(0xFF85929E)),
          ),
          Text(
            'Holati: ${order['status']}',
            style: TextStyle(fontSize: 14, color: Color(0xFF85929E)),
          ),
          Text(
            'Yetkazish manzili: ${order['delivery_address']}',
            style: TextStyle(fontSize: 14, color: Color(0xFF85929E)),
          ),
          Text(
            'Yaratilgan vaqt: ${order['created_at']}',
            style: TextStyle(fontSize: 14, color: Color(0xFF85929E)),
          ),
        ],
      ),
    );
  }
}
