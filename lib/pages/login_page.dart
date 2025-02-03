import 'package:driveu_mobile_app/widgets/register_form_firebase.dart';
import 'package:flutter/material.dart';


class LoginPage extends StatelessWidget {
 const LoginPage({super.key});


 @override
 Widget build(BuildContext context) {
   return Scaffold(
     body: Container(
       width: double.infinity,
       height: double.infinity,
       decoration: const BoxDecoration(
         gradient: LinearGradient(
           begin: Alignment.topCenter,
           end: Alignment.bottomCenter,
           colors: [
             Color(0xFFB2DFDB), // Light teal
             Colors.white, // White
             Color(0xFFBBDEFB), // Light blue
           ],
         ),
       ),
       child: Stack(
         children: [
           // Top-left decorative image
           Positioned(
             top: 0,
             left: 0,
             child: Image.asset(
               'assets/images/car1.png',
               height: 100,
             ),
           ),
           // Bottom-right decorative image with rotation
           Positioned(
             bottom: 0,
             right: 0,
             child: Transform.rotate(
               angle: 3.14159, // 180 degrees in radians
               child: Image.asset(
                 'assets/images/car1.png',
                 height: 100,
               ),
             ),
           ),
           SingleChildScrollView(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 const SizedBox(height: 100),
                 Image.asset(
                   'assets/images/drive.png',
                   height: 170,
                 ),
                 const SizedBox(height: 20),
                 const Text(
                   "Where carpooling is pleasure 😊🚗",
                   style: TextStyle(
                     fontFamily: 'Fredoka',
                     fontSize: 18,
                     fontWeight: FontWeight.bold,
                     color: Colors.black87,
                   ),
                 ),
                 const SizedBox(height: 20),
                 const Text(
                   "Welcome to DriveU!",
                   style: TextStyle(
                     fontFamily: 'Fredoka',
                     fontSize: 18,
                     color: Colors.black54,
                   ),
                 ),
                 const SizedBox(height: 5),
                 const Text(
                   "Please log in or sign up to get started!",
                   style: TextStyle(
                     fontFamily: 'Fredoka',
                     fontSize: 18,
                     color: Colors.black54,
                   ),
                 ),
                 const SizedBox(height: 80),
                 const LoginForm(),
                 const SizedBox(height: 0),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     const Text(
                       "Don't have an Account? ",
                       style: TextStyle(
                         fontFamily: 'Fredoka',
                       ),
                     ),
                     GestureDetector(
                       onTap: () {
                         Navigator.push(context,
                             MaterialPageRoute(builder: (context) {
                           return const RegisterFormFirebase();
                         }));
                       },
                       child: const Text(
                         "Join",
                         style: TextStyle(
                           fontFamily: 'Fredoka',
                           color: Colors.teal,
                           fontWeight: FontWeight.bold,
                         ),
                       ),
                     ),
                     const Text(
                       " DriveU-nation for FREE!",
                       style: TextStyle(
                         fontFamily: 'Fredoka',
                       ),
                     )
                   ],
                 ),
                 const SizedBox(height: 40),
               ],
             ),
           ),
         ],
       ),
     ),
   );
 }
}


class LoginForm extends StatelessWidget {
 const LoginForm({super.key});


 @override
 Widget build(BuildContext context) {
   return Padding(
     padding: const EdgeInsets.symmetric(horizontal: 30.0),
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.stretch,
       children: [
         TextFormField(
           decoration: const InputDecoration(
             labelText: 'Email',
             border: OutlineInputBorder(),
           ),
         ),
         const SizedBox(height: 20),
         TextFormField(
           obscureText: true,
           decoration: const InputDecoration(
             labelText: 'Password',
             border: OutlineInputBorder(),
           ),
         ),
         const SizedBox(height: 40),
         Center(
           child: ElevatedButton(
             onPressed: () {
               // Handle login action
             },
             style: ElevatedButton.styleFrom(
               backgroundColor: Colors.teal,
               padding: const EdgeInsets.symmetric(
                 horizontal: 30,
                 vertical: 15,
               ),
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(25),
               ),
             ),
             child: const Text(
               "Submit",
               style: TextStyle(
                 fontFamily: 'Fredoka',
                 fontSize: 18,
                 fontWeight: FontWeight.bold,
                 color: Colors.white,
               ),
             ),
           ),
         ),
       ],
     ),
   );
 }
}



