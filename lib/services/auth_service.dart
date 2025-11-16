import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';



class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? '1234567890-abcxyz123.apps.googleusercontent.com' : null,
    scopes: ['email'],
  );

  User? get currentUser => _auth.currentUser;

Future<User?> register(String email, String password) async {
  final cred = await _auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  final user = cred.user;

  // ✅ Send verification email
  if (user != null && !user.emailVerified) {
    await user.sendEmailVerification();
  }

  return user;
}

  Future<User?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user;
  }


    // 🔹 Google sign-in
Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      // ✅ Web uses GoogleAuthProvider directly
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final userCredential = await _auth.signInWithPopup(authProvider);
        return userCredential.user;
      } catch (e) {
        rethrow;
      }
    } else {
      // ✅ Mobile uses GoogleSignIn
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    }
  }
  // 🔵 Facebook Sign-in
  // Future<User?> signInWithFacebook() async {
  //   final LoginResult result = await FacebookAuth.instance.login();
  //   if (result.status == LoginStatus.success) {
  //     final OAuthCredential facebookAuthCredential =
  //         FacebookAuthProvider.credential(result.accessToken!.tokenString);
  //     final userCred = await _auth.signInWithCredential(facebookAuthCredential);
  //     return userCred.user;
  //   } else if (result.status == LoginStatus.cancelled) {
  //     throw Exception('Facebook login cancelled.');
  //   } else {
  //     throw Exception(result.message ?? 'Facebook login failed.');
  //   }
  // }
  Future<void> logout() async {
    await GoogleSignIn().signOut().catchError((_) {});
    await _auth.signOut();
  }
  Future<void> resetPassword(String email) async {
  await _auth.sendPasswordResetEmail(email: email);
}

}
