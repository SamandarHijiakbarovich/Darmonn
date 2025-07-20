import 'package:dorihona_app/api_service.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  final String phoneNumber;
  final String password;

  const ProfileScreen({
    Key? key,
    required this.userId,
    required this.phoneNumber,
    required this.password,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  void _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _apiService.getMyProfile(
        phoneNumber: widget.phoneNumber,
        password: widget.password,
      );
      setState(() {
        _userProfile = profile;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: IconThemeData(color: Color(0xFF1B4F72)),
        titleTextStyle: TextStyle(
          color: Color(0xFF1B4F72),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              )
            : _userProfile == null
            ? Center(child: Text('Ma\'lumotlar topilmadi'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFF85929E),
                      child: Icon(Icons.person, color: Colors.white, size: 50),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Foydalanuvchi ma\'lumotlari',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4F72),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildProfileInfo('ID', _userProfile!['id'].toString()),
                  _buildProfileInfo('Ism', _userProfile!['first_name']),
                  _buildProfileInfo('Familiya', _userProfile!['last_name']),
                  _buildProfileInfo(
                    'Telefon raqam',
                    _userProfile!['phone_number'],
                  ),
                  _buildProfileInfo('Rol', _userProfile!['role']),
                  SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Chiqish funksiyasi (masalan, login sahifasiga qaytish)
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE74C3C),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Chiqish',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1B4F72),
            ),
          ),
          Text(value, style: TextStyle(fontSize: 16, color: Color(0xFF85929E))),
        ],
      ),
    );
  }
}
