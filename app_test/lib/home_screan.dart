import 'package:app_test/kerzinka_page.dart';
import 'package:app_test/search_page.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  List<Widget> _pages = [];
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _pages = [
      HomePage(
        userId: args['user_id'],
        fullName: args['full_name'],
        role: args['role'],
      ),
      SearchPage(),
      KorzinkaPage(),
      ProfilePage(
        userId: args['user_id'],
        fullName: args['full_name'],
        role: args['role'],
        phoneNumber: args['phone_number'],
        password: args['password'],
      ),
    ];
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      _animationController.forward().then((_) {
        setState(() {
          _selectedIndex = index;
        });
        _animationController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: _pages[_selectedIndex],
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Color(0xFF2E86C1),
            unselectedItemColor: Color(0xFF85929E),
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            elevation: 0,
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            items: [
              BottomNavigationBarItem(
                icon: _buildNavIcon(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  index: 0,
                ),
                label: 'Bosh sahifa',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(
                  icon: Icons.search_outlined,
                  selectedIcon: Icons.search,
                  index: 1,
                ),
                label: 'Qidiruv',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(
                  icon: Icons.shopping_cart_outlined,
                  selectedIcon: Icons.shopping_cart,
                  index: 2,
                  showBadge: true,
                ),
                label: 'Savat',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  index: 3,
                ),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon({
    required IconData icon,
    required IconData selectedIcon,
    required int index,
    bool showBadge = false,
  }) {
    final isSelected = _selectedIndex == index;

    return Container(
      padding: EdgeInsets.all(8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.all(isSelected ? 8 : 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? Color(0xFF2E86C1).withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isSelected ? selectedIcon : icon,
              size: 24,
              color: isSelected ? Color(0xFF2E86C1) : Color(0xFF85929E),
            ),
          ),

          // Badge for cart
          if (showBadge && index == 2)
            Positioned(
              right: 0,
              top: 0,
              child: StreamBuilder<int>(
                stream: _getCartItemCount(),
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  if (count == 0) return SizedBox.shrink();

                  return Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Color(0xFFE74C3C),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                    child: Text(
                      count > 99 ? '99+' : count.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // Savat elementlari sonini kuzatuvchi stream
  Stream<int> _getCartItemCount() async* {
    // Bu yerda Cart() ni kuzatish uchun stream yaratilishi kerak
    // Hozircha oddiy implementation
    yield 0; // Cart().items.length ni qaytarish kerak
  }
}
