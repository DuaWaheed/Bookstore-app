// import 'package:ecommerceapp/pages/login.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});
//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }
// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;
//   final List<Map<String, String>> onboardingData = [
//     {
//       "title": "Shop the Latest",
//       "body": "Discover trendy fashion, electronics, and essentials at your fingertips.",
//       "image": "https://img.icons8.com/color/400/shopping-bag.png"
//     },
//     {
//       "title": "Fast Delivery",
//       "body": "Get your orders delivered quickly and reliably, straight to your door.",
//       "image": "https://img.icons8.com/color/400/delivery.png"
//     },
//     {
//       "title": "Easy & Secure",
//       "body": "Enjoy a seamless shopping experience with safe payments and easy returns.",
//       "image": "assets/images/payment.png"
//     },
//   ];
//   void _skipToEnd() {
//     _pageController.animateToPage(
//       onboardingData.length - 1,
//       duration: const Duration(milliseconds: 400),
//       curve: Curves.easeInOut,
//     );
//   }
//   void _nextPage() {
//     if (_currentPage == onboardingData.length - 1) {
//       _finishOnboarding();
//     } else {
//       _pageController.nextPage(
//         duration: const Duration(milliseconds: 400),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   Future<void> _finishOnboarding() async{
//      final prefs= await SharedPreferences.getInstance();
// await prefs.setBool("onboardingDone", true);
//     Navigator.pushReplacement(
//       context, 
//     MaterialPageRoute(builder: (_) => const SignInScreen()),
    
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 240, 239, 239),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             PageView.builder(
//               controller: _pageController,
//               itemCount: onboardingData.length,
//               onPageChanged: (index) {
//                 setState(() => _currentPage = index);
//               },
//               itemBuilder: (context, index) {
//                 final data = onboardingData[index];
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Expanded(
//                         child: Image.network(
//                           data["image"]!,
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//                       const SizedBox(height: 40),
//                       Text(
//                         data["title"]!,
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         data["body"]!,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: Colors.black,
//                         ),
//                       ),
//                       const SizedBox(height: 80),
//                     ],
//                   ),
//                 );
//               },
//             ),

//             // Skip button
//             Positioned(
//               top: 16,
//               right: 16,
//               child: TextButton(
//                 onPressed: _skipToEnd,
//                 child: const Text(
//                   "Skip",
//                   style: TextStyle(color: Colors.black, fontSize: 16),
//                 ),
//               ),
//             ),

//             // Indicators + Next button
//             Positioned(
//               bottom: 5,
//               left: 24,
//               right: 24,
              
//               child: Column(
//                 children: [
//                  Row(
//   mainAxisAlignment: MainAxisAlignment.center,
//   children: List.generate(
//     onboardingData.length,
//     (index) => GestureDetector(
//       onTap: () {
//         _pageController.animateToPage(
//           index,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//         );
//       },
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         margin: const EdgeInsets.symmetric(horizontal: 4),
//         height: 10,
//         width: _currentPage == index ? 24 : 10,
//         decoration: BoxDecoration(
//           color: _currentPage == index
//               ? Colors.black
//               : Colors.grey,
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     ),
//   ),
// ),

//                   const SizedBox(height: 24),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _nextPage,
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         backgroundColor: const Color.fromARGB(255, 0, 0, 0),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: Text(
//                         _currentPage == onboardingData.length - 1
//                             ? "Start Shopping"
//                             : "Next",
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white

//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
