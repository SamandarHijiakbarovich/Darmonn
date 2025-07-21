import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final int userId;
  final String fullName;
  final String role;
  final String phoneNumber;
  final String password;

  ProfilePage({
    required this.userId,
    required this.fullName,
    required this.role,
    required this.phoneNumber,
    required this.password,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _userData;
  String _message = '';
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _fetchUserData();
    _animationController.forward();
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await http.post(
        Uri.parse('https://khanbook.uz/users/me'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'phone_number': widget.phoneNumber, 'password': widget.password},
      );

      if (response.statusCode == 200) {
        setState(() {
          _userData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _message = 'Ma\'lumotlarni olishda xatolik';
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

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Color(0xFFE74C3C)),
              SizedBox(width: 12),
              Text('Chiqish'),
            ],
          ),
          content: Text('Hisobdan chiqmoqchimisiz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Bekor qilish',
                style: TextStyle(color: Color(0xFF85929E)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // SharedPreferences dan ma'lumotlarni o'chirish
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('phone_number');
                await prefs.remove('password');

                // Login sahifasiga o'tish
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE74C3C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Ha, chiqish'),
            ),
          ],
        );
      },
    );
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
                        'Ma\'lumotlar yuklanmoqda...',
                        style: TextStyle(
                          color: Color(0xFF85929E),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : _userData != null
              ? SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Yuqori qism - Profil ma'lumotlari
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF2E86C1), Color(0xFF1B4F72)],
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Avatar
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Color(0xFF2E86C1),
                                ),
                              ),

                              SizedBox(height: 16),

                              // Ism
                              Text(
                                '${_userData!['first_name']} ${_userData!['last_name']}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),

                              SizedBox(height: 8),

                              // Telefon raqami
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.phone,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    _userData!['phone_number'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 8),

                              // Rol
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _userData!['role'] ?? 'Foydalanuvchi',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              SizedBox(height: 16),

                              // Foydalanuvchi ID
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.badge,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'ID: ${_userData!['id']}',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24),

                        // Menyu elementlari
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              _buildMenuCard(
                                icon: Icons.person_outline,
                                title: 'Shaxsiy ma\'lumotlar',
                                subtitle: 'Profilingizni tahrirlang',
                                onTap: () => _showEditProfile(),
                                color: Color(0xFF2E86C1),
                              ),

                              SizedBox(height: 16),

                              _buildMenuCard(
                                icon: Icons.shopping_bag_outlined,
                                title: 'Buyurtmalar tarixi',
                                subtitle: 'Oldingi buyurtmalarni ko\'ring',
                                onTap: () => _showOrderHistory(),
                                color: Color(0xFF28B463),
                              ),

                              SizedBox(height: 16),

                              _buildMenuCard(
                                icon: Icons.favorite_outline,
                                title: 'Sevimli dorilar',
                                subtitle: 'Saqlangan mahsulotlar',
                                onTap: () => _showFavorites(),
                                color: Color(0xFFE74C3C),
                              ),

                              SizedBox(height: 16),

                              _buildMenuCard(
                                icon: Icons.settings_outlined,
                                title: 'Sozlamalar',
                                subtitle: 'Ilova sozlamalari',
                                onTap: () => _showSettings(),
                                color: Color(0xFF85929E),
                              ),

                              SizedBox(height: 16),

                              _buildMenuCard(
                                icon: Icons.help_outline,
                                title: 'Yordam va qo\'llab-quvvatlash',
                                subtitle: '24/7 onlayn yordam',
                                onTap: () => _showHelp(),
                                color: Color(0xFFF39C12),
                              ),

                              SizedBox(height: 24),

                              // Chiqish tugmasi
                              Container(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _logout,
                                  icon: Icon(Icons.logout),
                                  label: Text('Hisobdan chiqish'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFE74C3C),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 20),

                              // Ilova haqida ma'lumot
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Darmon',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1B4F72),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Versiya 1.0.0',
                                      style: TextStyle(
                                        color: Color(0xFF85929E),
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Sizning ishonchli dorihanangiz',
                                      style: TextStyle(
                                        color: Color(0xFF85929E),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Color(0xFFE74C3C),
                      ),
                      SizedBox(height: 16),
                      Text(
                        _message,
                        style: TextStyle(
                          color: Color(0xFFE74C3C),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                          });
                          _fetchUserData();
                        },
                        icon: Icon(Icons.refresh),
                        label: Text('Qayta urinish'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2E86C1),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),

            SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B4F72),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Color(0xFF85929E)),
                  ),
                ],
              ),
            ),

            Icon(Icons.arrow_forward_ios, color: Color(0xFF85929E), size: 16),
          ],
        ),
      ),
    );
  }

  void _showEditProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Color(0xFF85929E),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.edit, color: Color(0xFF2E86C1)),
                  SizedBox(width: 12),
                  Text(
                    'Profilni tahrirlash',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4F72),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Bu funksiya hozirda ishlab chiqilmoqda. Tez orada mavjud bo\'ladi.',
                style: TextStyle(color: Color(0xFF85929E), fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Color(0xFF85929E),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.history, color: Color(0xFF28B463)),
                  SizedBox(width: 12),
                  Text(
                    'Buyurtmalar tarixi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4F72),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 80,
                      color: Color(0xFF85929E),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Hozircha buyurtmalar yo\'q',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4F72),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Birinchi buyurtmangizni bering!',
                      style: TextStyle(color: Color(0xFF85929E), fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFavorites() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Color(0xFF85929E),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.favorite, color: Color(0xFFE74C3C)),
                  SizedBox(width: 12),
                  Text(
                    'Sevimli dorilar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4F72),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: Color(0xFF85929E),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Sevimli dorilar yo\'q',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4F72),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Dorilarni sevimli qilib belgilang',
                      style: TextStyle(color: Color(0xFF85929E), fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Color(0xFF85929E),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.settings, color: Color(0xFF85929E)),
                  SizedBox(width: 12),
                  Text(
                    'Sozlamalar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4F72),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildSettingItem(
                      icon: Icons.notifications_outlined,
                      title: 'Xabarnomalar',
                      subtitle: 'Push xabarnomalarni boshqarish',
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {},
                        activeColor: Color(0xFF2E86C1),
                      ),
                    ),
                    Divider(),
                    _buildSettingItem(
                      icon: Icons.language,
                      title: 'Til',
                      subtitle: 'O\'zbek',
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                    Divider(),
                    _buildSettingItem(
                      icon: Icons.security,
                      title: 'Xavfsizlik',
                      subtitle: 'Parol va himoya',
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF2E86C1)),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1B4F72)),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Color(0xFF85929E), fontSize: 14),
      ),
      trailing: trailing,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showHelp() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Color(0xFF85929E),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.help, color: Color(0xFFF39C12)),
                  SizedBox(width: 12),
                  Text(
                    'Yordam va qo\'llab-quvvatlash',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4F72),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildHelpItem(
                      icon: Icons.phone,
                      title: 'Telefon qo\'ng\'iroq',
                      subtitle: '+998 71 123 45 67',
                      color: Color(0xFF28B463),
                    ),
                    SizedBox(height: 16),
                    _buildHelpItem(
                      icon: Icons.message,
                      title: 'SMS xabarnoma',
                      subtitle: '+998 71 123 45 67',
                      color: Color(0xFF2E86C1),
                    ),
                    SizedBox(height: 16),
                    _buildHelpItem(
                      icon: Icons.email,
                      title: 'Email',
                      subtitle: 'support@Darmon.uz',
                      color: Color(0xFFF39C12),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF2E86C1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Color(0xFF2E86C1),
                            size: 32,
                          ),
                          SizedBox(height: 12),
                          Text(
                            '24/7 Xizmat',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B4F72),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Biz har doim sizning xizmatingizdamiz. Har qanday savolingiz bo\'lsa, murojaat qiling.',
                            style: TextStyle(
                              color: Color(0xFF85929E),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B4F72),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Color(0xFF85929E)),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Color(0xFF85929E), size: 16),
        ],
      ),
    );
  }
}
