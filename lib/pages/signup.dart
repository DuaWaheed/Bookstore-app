// import 'package:ecommerceapp/pages/home.dart';
// import 'package:ecommerceapp/pages/login.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final TextEditingController _email= TextEditingController();
//   final TextEditingController _password= TextEditingController();
// Future <void> _signup() async{
//   try{
//     await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email.text, password: _password.text );

//     Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> HomeScreen()));
//   }
//   catch(e){
//         print(_email.text);

//     ScaffoldMessenger.of(context)
//     .showSnackBar(SnackBar(content: Text("signup failed: $e")));
//   }
// }
//   @override
//   Widget build(BuildContext context) {
//      return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // Top Illustration
//               SizedBox(
//                 height: 220,
//                 child: Image.asset(
//                   "assets/images/onboarding.png", // replace with your illustration
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Sign In Title
//               const Text(
//                 "Sign Up",
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 8),

//               // Description
//               const Text(
//                 "Please enter the details below to continue.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey,
//                 ),
//               ),
//               const SizedBox(height: 32),

//               // name Label + Field
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "Name",
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey.shade800,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               TextField(
                
//                 decoration: InputDecoration(
//                   hintText: "Name",
//                   filled: true,
//                   fillColor: Colors.grey.shade100,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 14,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               //email
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "Email",
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey.shade800,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               TextField(
//                   controller: _email,
//                 decoration: InputDecoration(
//                   hintText: "Email",
                
//                   filled: true,
//                   fillColor: Colors.grey.shade100,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 14,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Password Label + Field
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "Password",
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey.shade800,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: _password,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   hintText: "Password",
//                   filled: true,
//                   fillColor: Colors.grey.shade100,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 14,
//                   ),
//                 ),
//               ),

           
//               const SizedBox(height: 10),

//               // signup Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _signup,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     "create Account",
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                       letterSpacing: 1,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Sign Up Link
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     "Don't have an account? ",
//                     style: TextStyle(color: Colors.black87, fontSize: 14),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                        Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) =>SignInScreen(),
//                           ),
//                         );
//                     },
//                     child: const Text(
//                       "Sign Up",
//                       style: TextStyle(
//                         color: Colors.green,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
