import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _message = '';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  Future<void> _register() async {
    if (!_acceptTerms) {
      _showErrorSnackBar('Iltimos, foydalanish shartlarini qabul qiling');
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _message = '';
      });

      try {
        final response = await http.post(
          Uri.parse('https://khanbook.uz/register'),
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'first_name': _firstNameController.text,
            'last_name': _lastNameController.text,
            'phone_number': _phoneNumberController.text,
            'password': _passwordController.text,
          },
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          _showSuccessSnackBar('Muvaffaqiyatli ro\'yxatdan o\'tdingiz!');
          await Future.delayed(Duration(seconds: 1));
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          setState(() {
            _message = data['message'] ?? 'Ro\'yxatdan o\'tishda xatolik';
          });
          _showErrorSnackBar(_message);
        }
      } catch (e) {
        setState(() {
          _message = 'Internet bilan bog\'lanishda xatolik';
        });
        _showErrorSnackBar(_message);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Color(0xFF28B463),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Color(0xFFE74C3C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF2E86C1)),
        title: Text(
          'Ro\'yxatdan o\'tish',
          style: TextStyle(color: Color(0xFF1B4F72)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Opacity(
                  opacity: 1 - (_slideAnimation.value / 50),
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),

                        // Logo va Sarlavha
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Color(0xFF2E86C1),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF2E86C1).withOpacity(0.3),
                                blurRadius: 15,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.person_add,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),

                        SizedBox(height: 24),

                        Text(
                          'Yangi hisob yarating',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B4F72),
                          ),
                        ),

                        SizedBox(height: 8),

                        Text(
                          'Ma\'lumotlarni to\'ldiring va bizga qo\'shiling',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF85929E),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 30),

                        // Forma
                        Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Ism
                                TextFormField(
                                  controller: _firstNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Ism',
                                    hintText: 'Ismingizni kiriting',
                                    prefixIcon: Icon(
                                      Icons.person_outline,
                                      color: Color(0xFF2E86C1),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ismni kiriting';
                                    }
                                    if (value.length < 2) {
                                      return 'Ism kamida 2 ta harfdan iborat bo\'lishi kerak';
                                    }
                                    return null;
                                  },
                                ),

                                SizedBox(height: 16),

                                // Familiya
                                TextFormField(
                                  controller: _lastNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Familiya',
                                    hintText: 'Familiyangizni kiriting',
                                    prefixIcon: Icon(
                                      Icons.person_outline,
                                      color: Color(0xFF2E86C1),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Familiyani kiriting';
                                    }
                                    if (value.length < 2) {
                                      return 'Familiya kamida 2 ta harfdan iborat bo\'lishi kerak';
                                    }
                                    return null;
                                  },
                                ),

                                SizedBox(height: 16),

                                // Telefon raqami
                                TextFormField(
                                  controller: _phoneNumberController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: 'Telefon raqami',
                                    hintText: '+998 XX XXX XX XX',
                                    prefixIcon: Icon(
                                      Icons.phone,
                                      color: Color(0xFF2E86C1),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Telefon raqamini kiriting';
                                    }
                                    return null;
                                  },
                                ),

                                SizedBox(height: 16),

                                // Parol
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Parol',
                                    hintText: 'Kuchli parol yarating',
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: Color(0xFF2E86C1),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Color(0xFF85929E),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Parolni kiriting';
                                    }
                                    if (value.length < 6) {
                                      return 'Parol kamida 6 ta belgidan iborat bo\'lishi kerak';
                                    }
                                    return null;
                                  },
                                ),

                                SizedBox(height: 16),

                                // Parolni tasdiqlash
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  decoration: InputDecoration(
                                    labelText: 'Parolni tasdiqlang',
                                    hintText: 'Parolni qayta kiriting',
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: Color(0xFF2E86C1),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Color(0xFF85929E),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Parolni tasdiqlang';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Parollar mos kelmaydi';
                                    }
                                    return null;
                                  },
                                ),

                                SizedBox(height: 20),

                                // Shartlarni qabul qilish
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _acceptTerms,
                                      activeColor: Color(0xFF2E86C1),
                                      onChanged: (value) {
                                        setState(() {
                                          _acceptTerms = value ?? false;
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _acceptTerms = !_acceptTerms;
                                          });
                                        },
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              color: Color(0xFF85929E),
                                              fontSize: 14,
                                            ),
                                            children: [
                                              TextSpan(text: 'Men '),
                                              TextSpan(
                                                text: 'foydalanish shartlari',
                                                style: TextStyle(
                                                  color: Color(0xFF2E86C1),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              TextSpan(text: ' va '),
                                              TextSpan(
                                                text: 'maxfiylik siyosati',
                                                style: TextStyle(
                                                  color: Color(0xFF2E86C1),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              TextSpan(text: ' bilan roziman'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 24),

                                // Ro'yxatdan o'tish tugmasi
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF2E86C1),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 3,
                                    ),
                                    child: _isLoading
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : Text(
                                            'Ro\'yxatdan o\'tish',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 24),

                        // Allaqachon hisobingiz bormi?
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Hisobingiz bormi? ',
                              style: TextStyle(
                                color: Color(0xFF85929E),
                                fontSize: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/login',
                                );
                              },
                              child: Text(
                                'Kirish',
                                style: TextStyle(
                                  color: Color(0xFF2E86C1),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // Afzalliklar
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
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF28B463),
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Litsenziyali dorilar',
                                    style: TextStyle(
                                      color: Color(0xFF1B4F72),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF28B463),
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Tez yetkazib berish',
                                    style: TextStyle(
                                      color: Color(0xFF1B4F72),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF28B463),
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    '24/7 qo\'llab-quvvatlash',
                                    style: TextStyle(
                                      color: Color(0xFF1B4F72),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
