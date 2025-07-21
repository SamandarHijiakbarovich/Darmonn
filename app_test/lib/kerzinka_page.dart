import 'package:app_test/cart_page.dart';
import 'package:flutter/material.dart';

class KorzinkaPage extends StatefulWidget {
  @override
  _KorzinkaPageState createState() => _KorzinkaPageState();
}

class _KorzinkaPageState extends State<KorzinkaPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
  }

  void _removeFromCart(int index) {
    final cart = Cart();
    final removedItem = cart.items[index];

    setState(() {
      cart.removeItem(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.delete, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '${removedItem['name']} o\'chirildi',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFFE74C3C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Qaytarish',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              cart.addItem(removedItem);
            });
          },
        ),
      ),
    );
  }

  void _clearCart() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Color(0xFFF39C12)),
              SizedBox(width: 12),
              Text('Tasdiqlash'),
            ],
          ),
          content: Text('Barcha mahsulotlarni o\'chirmoqchimisiz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Bekor qilish',
                style: TextStyle(color: Color(0xFF85929E)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  Cart().clearCart();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Savat tozalandi'),
                    backgroundColor: Color(0xFF28B463),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE74C3C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Ha, o\'chirish'),
            ),
          ],
        );
      },
    );
  }

  void _proceedToCheckout() {
    final cart = Cart();
    if (cart.items.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCheckoutBottomSheet(),
    );
  }

  Widget _buildCheckoutBottomSheet() {
    final cart = Cart();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Color(0xFF85929E),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Sarlavha
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.shopping_bag, color: Color(0xFF2E86C1)),
                    SizedBox(width: 12),
                    Text(
                      'Buyurtmani rasmiylashtirish',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Umumiy ma'lumot
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF2E86C1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Color(0xFF2E86C1)),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Buyurtmangiz 24 soat ichida tayyorlanadi',
                                style: TextStyle(
                                  color: Color(0xFF2E86C1),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // Narx tafsiloti
                      Text(
                        'Narx tafsiloti',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B4F72),
                        ),
                      ),

                      SizedBox(height: 12),

                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Mahsulotlar (${cart.items.length} ta)'),
                                Text(
                                  '${cart.totalPrice.toStringAsFixed(0)} so\'m',
                                ),
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Yetkazib berish'),
                                Text('Bepul'),
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Jami',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B4F72),
                                  ),
                                ),
                                Text(
                                  '${cart.totalPrice.toStringAsFixed(0)} so\'m',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E86C1),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Spacer(),

                      // Buyurtma berish tugmasi
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showOrderConfirmation();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF28B463),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Buyurtma berish',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOrderConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Color(0xFF28B463),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.white, size: 40),
              ),
              SizedBox(height: 20),
              Text(
                'Buyurtma qabul qilindi!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4F72),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'Buyurtmangiz tez orada tayyorlanadi va sizga xabar beramiz',
                style: TextStyle(color: Color(0xFF85929E), fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      Cart().clearCart();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E86C1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Yaxshi'),
                ),
              ),
            ],
          ),
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
    final cart = Cart();

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Yuqori qism - Sarlavha
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFF2E86C1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Savat',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B4F72),
                              ),
                            ),
                            Text(
                              '${cart.items.length} ta mahsulot',
                              style: TextStyle(
                                color: Color(0xFF85929E),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    if (cart.items.isNotEmpty)
                      GestureDetector(
                        onTap: _clearCart,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFFE74C3C).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            color: Color(0xFFE74C3C),
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Savat mazmuni
              Expanded(
                child: cart.items.isEmpty
                    ? SlideTransition(
                        position: _slideAnimation,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Color(0xFF85929E).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 60,
                                  color: Color(0xFF85929E),
                                ),
                              ),

                              SizedBox(height: 24),

                              Text(
                                'Savat bo\'sh',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B4F72),
                                ),
                              ),

                              SizedBox(height: 12),

                              Text(
                                'Hozircha hech qanday mahsulot yo\'q.\nDorilar qo\'shib savatingizni to\'ldiring!',
                                style: TextStyle(
                                  color: Color(0xFF85929E),
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: 32),

                              ElevatedButton.icon(
                                onPressed: () {
                                  // Ana sahifaga o'tish uchun
                                  DefaultTabController.of(
                                    context,
                                  )?.animateTo(0);
                                },
                                icon: Icon(Icons.shopping_bag),
                                label: Text('Xarid qilishni boshlash'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF2E86C1),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          // Mahsulotlar ro'yxati
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.all(16),
                              physics: BouncingScrollPhysics(),
                              itemCount: cart.items.length,
                              itemBuilder: (context, index) {
                                final medicine = cart.items[index];

                                return Container(
                                  margin: EdgeInsets.only(bottom: 16),
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
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Rasm
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Color(0xFFF8F9FA),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
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

                                        SizedBox(width: 16),

                                        // Ma'lumotlar
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                medicine['name'] ?? 'Noma\'lum',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1B4F72),
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),

                                              SizedBox(height: 8),

                                              if (medicine['description'] !=
                                                  null)
                                                Text(
                                                  medicine['description'],
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF85929E),
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),

                                              SizedBox(height: 8),

                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    size: 14,
                                                    color: Color(0xFF85929E),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      medicine['address'] ??
                                                          'Manzil yo\'q',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Color(
                                                          0xFF85929E,
                                                        ),
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              SizedBox(height: 12),

                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    '${medicine['price'] ?? 0} so\'m',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF2E86C1),
                                                    ),
                                                  ),

                                                  GestureDetector(
                                                    onTap: () =>
                                                        _removeFromCart(index),
                                                    child: Container(
                                                      padding: EdgeInsets.all(
                                                        8,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Color(
                                                          0xFFE74C3C,
                                                        ).withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Icon(
                                                        Icons.delete_outline,
                                                        color: Color(
                                                          0xFFE74C3C,
                                                        ),
                                                        size: 20,
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
                                  ),
                                );
                              },
                            ),
                          ),

                          // Pastki qism - Jami summa va Buyurtma tugmasi
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
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
                            child: Column(
                              children: [
                                // Jami summa
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF2E86C1).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Jami summa',
                                            style: TextStyle(
                                              color: Color(0xFF85929E),
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            '${cart.totalPrice.toStringAsFixed(0)} so\'m',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2E86C1),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.receipt_long,
                                        color: Color(0xFF2E86C1),
                                        size: 32,
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 16),

                                // Buyurtma berish tugmasi
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    onPressed: _proceedToCheckout,
                                    icon: Icon(Icons.shopping_bag),
                                    label: Text(
                                      'Buyurtma berish',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF28B463),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
      child: Icon(Icons.medical_services, size: 30, color: Color(0xFF85929E)),
    );
  }
}
