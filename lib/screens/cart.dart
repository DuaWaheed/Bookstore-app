import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/order_service.dart';

// --- THEME COLORS ---
const Color kPrimaryPurple = Color(0xFF9C27B0);
const Color kAccentPurple = Color(0xFFBA68C8);
const Color kBackgroundColor = Color(0xFFF3E5F5);
const Color kCardColor = Colors.white;
const Color kTextColor = Colors.black87;
const Color kErrorRed = Colors.redAccent;

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final orderService = OrderService();

  String? _userName;
  String? _userEmail;
  String? _shippingAddress;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  /// ✅ Fetch user profile info (name, email, address)
  Future<void> _fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser!;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    setState(() {
      _userName = doc.data()?['name'] ?? user.displayName ?? '';
      _userEmail = doc.data()?['email'] ?? user.email ?? '';
      _shippingAddress = doc.data()?['address'] ?? '';
    });
  }

  Future<void> _updateQuantity(List items, int idx, int delta) async {
    List newItems = List.from(items);
    newItems[idx]['quantity'] = (newItems[idx]['quantity'] ?? 1) + delta;
    if (newItems[idx]['quantity'] <= 0) newItems.removeAt(idx);
    await FirebaseFirestore.instance.collection('carts').doc(uid).set({
      'items': newItems,
    });
  }

  // ✅ Order confirmation popup (auto-filled + reactive)
  Future<void> _showOrderConfirmationDialog(List items) async {
    final nameCtrl = TextEditingController(text: _userName ?? '');
    final emailCtrl = TextEditingController(text: _userEmail ?? '');
    final addressCtrl = TextEditingController(text: _shippingAddress ?? '');
    String paymentMethod = 'cash on delivery';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: kCardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text(
                'Confirm Your Order 💜',
                style: TextStyle(color: kPrimaryPurple, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Name', style: TextStyle(color: kTextColor)),
                    const SizedBox(height: 5),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: kBackgroundColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.person, color: kAccentPurple),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Email Address', style: TextStyle(color: kTextColor)),
                    const SizedBox(height: 5),
                    TextField(
                      enabled: false, // ✅ non-editable email
                      controller: emailCtrl,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: kBackgroundColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.email, color: kAccentPurple),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Shipping Address', style: TextStyle(color: kTextColor)),
                    const SizedBox(height: 5),
                    TextField(
                      controller: addressCtrl,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: kBackgroundColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.location_on, color: kAccentPurple),
                        hintText: 'Enter your delivery address',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 15),
                    const Text('Payment Method', style: TextStyle(color: kTextColor)),
                    RadioListTile<String>(
                      title: const Text('Cash on Delivery'),
                      value: 'cash on delivery',
                      groupValue: paymentMethod,
                      activeColor: kPrimaryPurple,
                      onChanged: (value) {
                        if (value != null) {
                          setStateDialog(() {
                            paymentMethod = value;
                          });
                        }
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text(
                        'Online Payment (Unavailable)',
                        style: TextStyle(color: Colors.grey),
                      ),
                      value: 'online payment',
                      groupValue: paymentMethod,
                      onChanged: null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: kErrorRed)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final email = emailCtrl.text.trim();
                    final address = addressCtrl.text.trim();

                    if (name.isEmpty || email.isEmpty || address.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all fields'),
                          backgroundColor: kErrorRed,
                        ),
                      );
                      return;
                    }

                    // ✅ Save updated user info back to Firestore
                    await FirebaseFirestore.instance.collection('users').doc(uid).set({
                      'name': name,
                      'email': email,
                      'address': address,
                      'payment': paymentMethod,
                      'updatedAt': Timestamp.now(),
                    }, SetOptions(merge: true));

                    // ✅ Update local state for next checkout
                    setState(() {
                      _userName = name;
                      _shippingAddress = address;
                    });

                    Navigator.pop(context);
                    _checkout(items, email, address, paymentMethod);
                  },
                  child: const Text('Confirm Order', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ✅ Place order in Firestore
  Future<void> _checkout(List items, String email, String address, String payment) async {
    if (items.isEmpty) return;

    final updatedItems = items
        .map((item) => {
              ...item,
              'author': item['author'] ?? 'Unknown Author',
            })
        .toList();

    final total = updatedItems.fold(
      0.0,
      (sum, i) => sum + (i['price'] as num).toDouble() * (i['quantity'] as num).toDouble(),
    );

    final order = {
      'userId': uid,
      'email': email,
      'status': 'Pending',
      'totalPrice': total,
      'items': updatedItems,
      'shippingAddress': address,
      'paymentMethod': payment,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await orderService.placeOrder(order);
    await FirebaseFirestore.instance.collection('carts').doc(uid).set({'items': []});

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order placed successfully! 💜'),
        backgroundColor: kPrimaryPurple,
      ),
    );
    Navigator.pop(context);
  }

  // --- CART ITEM UI ---
  Widget _buildCartItem(BuildContext context, List items, int index) {
    final item = items[index];
    final title = item['title'] ?? 'Unknown Item';
    final quantity = item['quantity'] as int? ?? 1;
    final price = (item['price'] as num?)?.toDouble() ?? 0.0;
    final subtotal = (price * quantity).toStringAsFixed(2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        color: kCardColor,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: kAccentPurple, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: const Icon(Icons.shopping_basket_rounded,
                color: kPrimaryPurple, size: 30),
            title: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: kTextColor)),
            subtitle: Text(
                'Price: \$${price.toStringAsFixed(2)} • Subtotal: \$$subtotal',
                style: const TextStyle(color: kTextColor)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => _updateQuantity(items, index, -1),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: kBackgroundColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: kAccentPurple),
                    ),
                    child: Icon(Icons.remove,
                        size: 18,
                        color: quantity > 1 ? kTextColor : kErrorRed),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('$quantity',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: kTextColor)),
                ),
                InkWell(
                  onTap: () => _updateQuantity(items, index, 1),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: kAccentPurple,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child:
                        const Icon(Icons.add, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, double total, List items) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: kCardColor,
        boxShadow: [
          BoxShadow(
            color: kPrimaryPurple.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total:',
                  style: TextStyle(fontSize: 20, color: kTextColor)),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryPurple),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed:
                  items.isNotEmpty ? () => _showOrderConfirmationDialog(items) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryPurple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 5,
                disabledBackgroundColor: kAccentPurple.withOpacity(0.5),
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartRef = FirebaseFirestore.instance.collection('carts').doc(uid);

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
            .copyWith(secondary: kAccentPurple),
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimaryPurple,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(title: const Text('Your Cart 🛒')),
        body: StreamBuilder<DocumentSnapshot>(
          stream: cartRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(kPrimaryPurple)));
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text('Error loading cart: ${snapshot.error}',
                      style: const TextStyle(color: kErrorRed)));
            }

            final data = snapshot.data!;
            List items = (data.exists && data.data() != null)
                ? (data.get('items') as List? ?? [])
                    .map((e) => e as Map<String, dynamic>)
                    .toList()
                : [];

            if (items.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.remove_shopping_cart,
                        size: 80, color: kAccentPurple),
                    SizedBox(height: 10),
                    Text('Your cart is empty!',
                        style: TextStyle(fontSize: 18, color: kTextColor)),
                  ],
                ),
              );
            }

            final total = items.fold(
              0.0,
              (s, i) =>
                  s +
                  (i['price'] as num).toDouble() *
                      (i['quantity'] as num).toDouble(),
            );

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, i) => _buildCartItem(context, items, i),
                  ),
                ),
                _buildCheckoutBar(context, total, items),
              ],
            );
          },
        ),
      ),
    );
  }
}
