import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final emailCtrl = TextEditingController();
  bool loading = false;
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }


  void showSnackBar(String message, {Color backgroundColor = Colors.deepPurple}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 3),
    ),
  );
}

bool isValidEmail(String email) {
  final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return regex.hasMatch(email);
}

Future<void> _send() async {
  final email = emailCtrl.text.trim();

  if (email.isEmpty) {
    showSnackBar('Please enter your email', backgroundColor: Colors.orangeAccent);
    return;
  }

  if (!isValidEmail(email)) {
    showSnackBar('Invalid email address', backgroundColor: Colors.redAccent);
    return;
  }

  setState(() => loading = true);
  try {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (userSnapshot.docs.isEmpty) {
      showSnackBar('No account found for this email', backgroundColor: Colors.orangeAccent);
      return;
    }

    final userData = userSnapshot.docs.first.data();
    final isAdmin = userData['isAdmin'] == true;

    if (isAdmin) {
      showSnackBar(
        'Admins cannot reset their password here.Please contact the system administrator.',
        backgroundColor: Colors.orangeAccent,
      );
      return;
    }

    // ✅ Normal user — send reset email
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    if (!mounted) return;

    showSnackBar('Password reset link sent!', backgroundColor: Colors.green);
    Navigator.pop(context);
  } on FirebaseAuthException catch (e) {
    String message = 'An error occurred. Please try again.';
    if (e.code == 'invalid-email') message = 'Invalid email address';
    showSnackBar(message, backgroundColor: Colors.redAccent);
  } catch (e) {
    showSnackBar('Unexpected error: $e', backgroundColor: Colors.redAccent);
  } finally {
    if (mounted) setState(() => loading = false);
  }
}


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: Stack(
        children: [
          // 🌈 Gradient Header
          Container(
            height: 260,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
          ),

          // ✨ Main Card with Fade-in Animation
          FadeTransition(
            opacity: _fadeIn,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_reset_rounded,
                          color: Colors.deepPurple, size: 75),
                      const SizedBox(height: 18),
                      const Text(
                        'Reset Your Password',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter your registered email address to receive a password reset link.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                            height: 1.4),
                      ),
                      const SizedBox(height: 28),

                      // 📨 Email Field with Shadow
                      TextField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email address',
                          prefixIcon: const Icon(Icons.email_outlined,
                              color: Colors.deepPurple),
                          filled: true,
                          fillColor: Colors.deepPurple.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: Colors.deepPurple, width: 2),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 🔘 Modern Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: loading ? null : _send,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 5,
                            shadowColor:
                                Colors.deepPurple.withOpacity(0.4),
                          ),
                          child: loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Send Reset Link',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🔙 Back to login
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          '← Back to Login',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
