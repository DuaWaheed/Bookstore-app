import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import 'package:ecommerceapp/auth/login.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? adminData;
  bool loading = true;
  final AuthService auth = AuthService();


  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    if (user == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (snapshot.exists) {
      setState(() {
        adminData = snapshot.data();
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
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


  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.deepPurple.withOpacity(0.1),
        title: const Text(
          'Admin Profile',
          style: TextStyle(
            color: Color(0xFF5E35B1),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF5E35B1)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Container(
                      width: 480,
                      margin: const EdgeInsets.symmetric(vertical: 40),
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.97),
                            Colors.deepPurple.shade50.withOpacity(0.9),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.1),
                            blurRadius: 25,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 🟣 Profile Avatar
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.deepPurple.shade100,
                              child: const Icon(
                                Icons.admin_panel_settings_rounded,
                                color: Colors.deepPurple,
                                size: 50,
                              ),
                            ),
                            const SizedBox(height: 15),

                            // 🟣 Admin Name
                            Text(
                              adminData?['name'] ?? 'Admin',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5E35B1),
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Administrator Account',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 25),

                            // 🟣 Info Cards Row 1
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildInfoCard(
                                    Icons.email_rounded,
                                    'Email',
                                    adminData?['email'] ?? 'N/A',
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: _buildInfoCard(
                                    Icons.calendar_today_rounded,
                                    'Joined On',
                                    _formatDate(
                                        adminData?['createdAt']?.toDate()),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),

                            // 🟣 Info Cards Row 2
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildInfoCard(
                                    Icons.access_time_rounded,
                                    'Last Login',
                                    _formatDate(user
                                        ?.metadata.lastSignInTime
                                        ?.toLocal()),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: _buildInfoCard(
                                    Icons.verified_user_rounded,
                                    'Role',
                                    'Admin',
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 25),

                            // 🟣 Password Alert Box
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.lock_outline,
                                      color: Colors.deepPurple, size: 20),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'To reset your password, contact the system department.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        color: Colors.black87,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 25),

                            // 🟣 Logout Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: _logout,
                                icon: const Icon(Icons.logout_rounded),
                                label: const Text('Logout'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 4,
                                  shadowColor:
                                      Colors.deepPurple.withOpacity(0.3),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
