import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'register.dart';
import 'reset_password.dart';
import '../screens/home.dart';
import '../screens/admin_panel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final AuthService _auth = AuthService();
  final UserService _userService = UserService();
  bool loading = false;

void _login() async {
  setState(() => loading = true);
  try {
    final user = await _auth.login(emailCtrl.text.trim(), passCtrl.text.trim());

    if (user != null) {
      await user.reload(); // 🔹 Refresh user data
      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser == null) return;

      // 🔹 Get user document from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(refreshedUser.uid)
          .get();

      final bool isAdmin = userDoc.exists && userDoc['isAdmin'] == true;

      // ✅ Email verification check
      if (!refreshedUser.emailVerified) {
        // 🔹 Send verification email if not verified
        await refreshedUser.sendEmailVerification();

        await FirebaseAuth.instance.signOut();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAdmin
                  ? 'Admin account not verified. Verification email sent to admin email.'
                  : 'Please verify your email before logging in. Check your inbox.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // ✅ Email verified — go to respective screen
        await _userService.ensureUserDocument(refreshedUser);
        if (!mounted) return;

        if (isAdmin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminPanel()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    }
  } on FirebaseAuthException catch (e) {
    String msg = 'Login failed: ${e.message}';
    if (e.code == 'user-not-found') {
      msg = 'No account found for that email.';
    } else if (e.code == 'wrong-password') {
      msg = 'Incorrect password.';
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')));
  } finally {
    if (mounted) setState(() => loading = false);
  }
}


  Future<void> _googleLogin() async {
    setState(() => loading = true);
    try {
      final user = await _auth.signInWithGoogle();
      if (user != null) {
        await _userService.ensureUserDocument(user);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in failed: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
// Future<void> _facebookLogin() async {
//   setState(() => loading = true);
//   try {
//     // Login via Facebook plugin
//     final LoginResult result = await FacebookAuth.instance.login(
//       loginBehavior: LoginBehavior.webOnly, // ensures web works
//       permissions: ['email', 'public_profile'],
//     );

//     if (result.status == LoginStatus.success) {
//       // ✅ Use FirebaseAuth to sign in with Facebook credential
//       final OAuthCredential facebookCredential =
//           FacebookAuthProvider.credential(result.accessToken!.tokenString);

//       final userCred =
//           await FirebaseAuth.instance.signInWithCredential(facebookCredential);

//       await _userService.ensureUserDocument(userCred.user!);

//       if (!mounted) return;
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const HomeScreen()),
//       );
//     } else if (result.status == LoginStatus.cancelled) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Facebook login cancelled')),
//       );
//     } else {
//       throw Exception(result.message ?? 'Facebook login failed');
//     }
//   } catch (e) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text('Facebook sign-in failed: $e')));
//   } finally {
//     if (mounted) setState(() => loading = false);
//   }
// }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A1B9A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Login to your Book Hive account",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 28),

                  TextField(
                    controller: emailCtrl,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon:
                          const Icon(Icons.email_outlined, color: Colors.deepPurple),
                      filled: true,
                      fillColor: Colors.deepPurple.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon:
                          const Icon(Icons.lock_outline, color: Colors.deepPurple),
                      filled: true,
                      fillColor: Colors.deepPurple.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),


Align(
  alignment: Alignment.centerRight,
  child: TextButton(
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
    ),
    child: const Text(
      "Forgot Password?",
      style: TextStyle(
        color: Colors.deepPurple,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),


const SizedBox(height: 18),


                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: loading
                          ? const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2)
                          : const Text(
                              "Login",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 26),

                  // 🌐 Social Logins
                  const Text(
                    "Or continue with",
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),

                Column(
  children: [
    OutlinedButton.icon(
      icon: Image.asset('assets/images/google_logo.png', height: 24),
      label: const Text(
        "Continue with Google",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.deepPurple,
        ),
      ),
      onPressed: loading ? null : _googleLogin,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.deepPurple),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    ),

  ],
),


                  const SizedBox(height: 16),
 const Divider(height: 32, thickness: 1, color: Colors.black12),

                 

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?",
                          style: TextStyle(color: Colors.black54)),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        ),
                        child: const Text("Sign Up",
                            style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: FaIcon(icon, color: color, size: 24),
        ),
      ),
    );
  }
}
