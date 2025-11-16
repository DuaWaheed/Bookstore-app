// import 'package:flutter/material.dart';
// import 'onboarding.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {

//   @override
//   // Navigate to Onboarding after 3 seconds
//   void _navigateToOnboarding() async {
//     await Future.delayed(const Duration(seconds: 3));
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const OnboardingScreen()),
//     );
//   }
//   void initState() {
//     super.initState();
//     _navigateToOnboarding();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.shopping_cart,
//               color: Colors.black,
//               size: 100,
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               "E-Commerce App",
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 30),
           
//             const CircularProgressIndicator(
//               color: Colors.black,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
