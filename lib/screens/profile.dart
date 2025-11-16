import 'package:ecommerceapp/auth/login.dart';
import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Purple theme constants
const Color kPrimaryPurple = Color(0xFF6A1B9A);
const Color kSecondaryPurple = Color(0xFF8E24AA);
const Color kLightPurple = Color.fromARGB(255, 255, 255, 255);
const Color kAccentPurple = Color(0xFF7B1FA2);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final userService = UserService();
  final auth = AuthService();
  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final paymentCtrl = TextEditingController();

  bool loading = true;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    addressCtrl.dispose();
    paymentCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final doc = await userService.getUserDoc();
    final data = doc.exists ? (doc.data() as Map<String, dynamic>) : {};

    nameCtrl.text =
        data['name'] ?? FirebaseAuth.instance.currentUser?.displayName ?? '';
    addressCtrl.text = data['address'] ?? '';
    paymentCtrl.text = data['payment'] ?? '';
    isAdmin = data['isAdmin'] == true;

    if (mounted) setState(() => loading = false);
  }

  Future<void> _save() async {
    await userService.updateUser({
      'name': nameCtrl.text.trim(),
      'address': addressCtrl.text.trim(),
      'payment': paymentCtrl.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Color.fromARGB(255, 103, 58, 183),
      ),
    );
  }

Future<void> _logout() async {
  await auth.logout();
  if (!mounted) return;

  // Clear navigation stack and go to Login
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()), 
    (route) => false,
  );
}


  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: kPrimaryPurple),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kPrimaryPurple),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kSecondaryPurple, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text(
          'My Profile ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryPurple, kSecondaryPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryPurple),
              ),
            )
          : Container(
              color: kLightPurple.withOpacity(0.3),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Admin Badge ---
                    if (isAdmin)
                      Card(
                        color: kAccentPurple,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 20),
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Icon(Icons.security, color: Colors.white, size: 24),
                              SizedBox(width: 10),
                              Text(
                                'Administrator Access',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // --- Profile Info Card ---
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const Divider(
                                color: Colors.deepPurple, thickness: 1),
                            _buildTextField(
                              controller: nameCtrl,
                              labelText: 'Full Name',
                              icon: Icons.person,
                            ),
                            _buildTextField(
                              controller: addressCtrl,
                              labelText: 'Shipping Address',
                              icon: Icons.location_on,
                            ),
                            _buildTextField(
                              controller: paymentCtrl,
                              labelText: 'Payment Method',
                              icon: Icons.credit_card,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- Save Button ---
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _save,
                        icon:
                            const Icon(Icons.save, color: Colors.white, size: 22),
                        label: const Text(
                          'Save Profile',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- Logout Button ---
                    SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _logout,
                        icon:
                            const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                              fontSize: 16, color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Colors.red, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
