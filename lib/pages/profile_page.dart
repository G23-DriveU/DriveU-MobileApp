import 'package:driveu_mobile_app/services/auth_service.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:driveu_mobile_app/widgets/image_frame.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class ProfilePage extends StatelessWidget {
 const ProfilePage({super.key});


 @override
 Widget build(BuildContext context) {
   final currentUser = FirebaseAuth.instance.currentUser;
   final user = SingleUser().getUser();


   return Scaffold(
     body: Container(
       decoration: const BoxDecoration(
         gradient: LinearGradient(
           colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5)],
           begin: Alignment.topCenter,
           end: Alignment.bottomCenter,
         ),
       ),
       child: Center(
         child: Expanded( // Ensures it fills vertical space
           child: Container(
             margin: const EdgeInsets.all(20),
             height: double.infinity, // Makes it stretch fully
             constraints: const BoxConstraints(minHeight: 500),
             decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(20),
               gradient: const LinearGradient(
                 colors: [
                   Color.fromARGB(255, 199, 255, 255),
                   Color.fromARGB(255, 200, 236, 255),
                   Color.fromARGB(255, 200, 222, 255),
                 ],
                 begin: Alignment.topLeft,
                 end: Alignment.bottomRight,
               ),
               boxShadow: [
                 BoxShadow(
                   color: Colors.black.withOpacity(0.2),
                   blurRadius: 10,
                   spreadRadius: 3,
                 )
               ],
             ),
             padding: const EdgeInsets.all(25),
             child: SingleChildScrollView(
               child: Column(
                 mainAxisSize: MainAxisSize.max, // Allows stretching
                 crossAxisAlignment: CrossAxisAlignment.stretch,
                 children: [
                   if (currentUser != null) ...[
                     Column(
                       children: [
                         Container(
                           decoration: BoxDecoration(
                             shape: BoxShape.circle,
                             border: Border.all(color: Colors.black, width: 2),
                           ),
                           child: ClipOval(
                             child: SizedBox(
                               width: 120,
                               height: 120,
                               child: ImageFrame(
                                 firebaseUid: currentUser.uid,
                               ),
                             ),
                           ),
                         ),
                         const SizedBox(height: 10),
                         const Text(
                           "Profile Picture",
                           style: TextStyle(
                             fontSize: 20,
                             fontWeight: FontWeight.bold,
                             color: Colors.black87,
                           ),
                         ),
                       ],
                     ),
                     const SizedBox(height: 25),
                   ] else
                     const CircularProgressIndicator(),


                   if (user != null) ...[
                     _buildSectionTitle("User Information"),
                     _buildInfoRow("Name", user.name ?? 'Not provided'),
                     _buildInfoRow("Email", user.email ?? 'Not provided'),
                     _buildInfoRow("Phone", user.phoneNumber ?? 'Not provided'),
                     const SizedBox(height: 25),
                   ],


                   if (user != null && user.driver == true) ...[
                     _buildSectionTitle("Vehicle Details"),
                     if (user.carMake != null) _buildInfoRow("Make", user.carMake!),
                     if (user.carModel != null) _buildInfoRow("Model", user.carModel!),
                     if (user.carPlate != null) _buildInfoRow("Plate", user.carPlate!),
                     if (user.carColor != null) _buildInfoRow("Color", user.carColor!),
                     const SizedBox(height: 25),
                   ] else if (user != null)
                     const Padding(
                       padding: EdgeInsets.symmetric(vertical: 10),
                       child: Text(
                         "No Vehicle Information",
                         style: TextStyle(
                           fontSize: 16,
                           color: Colors.black54,
                           fontStyle: FontStyle.italic,
                         ),
                       ),
                     ),


                   ElevatedButton(
                     onPressed: () => AuthService().signOut(),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: const Color.fromARGB(255, 0, 127, 123),
                       foregroundColor: Colors.white,
                       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(15),
                         side: const BorderSide(color: Colors.white),
                       ),
                     ),
                     child: const Text(
                       "Sign Out",
                       style: TextStyle(
                         fontSize: 16,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                   ),
                   const SizedBox(height: 30),
                 ],
               ),
             ),
           ),
         ),
       ),
     ),
   );
 }


Widget _buildSectionTitle(String title) {
   return Padding(
     padding: const EdgeInsets.only(bottom: 15),
     child: Center(
       child: Text(
         title,
         style: const TextStyle(
           fontSize: 20,
           fontWeight: FontWeight.bold,
           color: Colors.black87,
           decoration: TextDecoration.underline,
         ),
       ),
     ),
   );
 }




 Widget _buildInfoRow(String label, String value) {
   return Padding(
     padding: const EdgeInsets.symmetric(vertical: 8),
     child: Row(
       mainAxisAlignment: MainAxisAlignment.spaceBetween,
       children: [
         Text(
           "$label:",
           style: const TextStyle(
             fontSize: 16,
             fontWeight: FontWeight.w600,
             color: Colors.black87,
           ),
         ),
         Text(
           value,
           style: const TextStyle(
             fontSize: 16,
             color: Colors.black54,
           ),
         ),
       ],
     ),
   );
 }
}
