import 'package:driveu_mobile_app/services/api/user_api.dart';
import 'package:driveu_mobile_app/services/auth_service.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:driveu_mobile_app/widgets/image_frame.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Display an edit dialog to enable users to change their information
  void _displayEditDialog(BuildContext context, String title,
      String initialValue, Function(String, String) onSave) {
    final TextEditingController controller =
        TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $title"),
          content: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: title,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final newValue = controller.text.trim();
                if (newValue.isNotEmpty) {
                  onSave(newValue, title); // Save the new value
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Value represents the value we want to save to and label is the type
  void editUserInfo(String value, String label) async {
    // Parse through the label and determine what is being edited
    // Rename the label to fit with the query parameters set by the API
    switch (label) {
      case "Name":
        label = "name";
        SingleUser().getUser()!.name = value;
        break;
      case "Phone":
        label = "phoneNumber";
        SingleUser().getUser()!.phoneNumber = value;
      case "Make":
        label = "carMake";
        SingleUser().getUser()!.carMake = value;
        break;
      case "Model":
        label = "carModel";
        SingleUser().getUser()!.carModel = value;
        break;
      case "Plate":
        label = "carPlate";
        SingleUser().getUser()!.carPlate = value;
      case "Color":
        label = "carColor";
        SingleUser().getUser()!.carColor = value;
        break;
      default:
        label = "";
        break;
    }

    final Map<String, String> newUserParams = {
      "userId": SingleUser().getUser()!.id.toString(),
      "name": SingleUser().getUser()!.name,
      "phoneNumber": SingleUser().getUser()!.phoneNumber,
      "school": SingleUser().getUser()!.school,
      "driver": SingleUser().getUser()!.driver.toString(),
      "carColor": SingleUser().getUser()!.carColor ?? "",
      "carPlate": SingleUser().getUser()!.carPlate ?? "",
      "carMake": SingleUser().getUser()!.carMake ?? "",
      "carModel": SingleUser().getUser()!.carModel ?? "",
    };
    setState(() {});
    // Update the user info
    await UserApi().editUserInfo(newUserParams);
  }

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
          child: Container(
            margin: const EdgeInsets.all(20),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                            child: ImageFrame(firebaseUid: currentUser.uid),
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
                  ).animate().fade(duration: 500.ms).slideY(),
                  const SizedBox(height: 25),
                ] else
                  const CircularProgressIndicator(),
                if (user != null)
                  ...[
                    _buildSectionTitle("User Information"),
                    _buildInfoRow(context, "Name", user.name ?? 'Not provided'),
                    _buildInfoRow(
                        context, "Email", user.email ?? 'Not provided'),
                    _buildInfoRow(
                        context, "Phone", user.phoneNumber ?? 'Not provided'),
                    const SizedBox(height: 25),
                  ].animate().fade(duration: 600.ms),
                if (user != null && user.driver == true)
                  ...[
                    _buildSectionTitle("Vehicle Details"),
                    if (user.carMake != null)
                      _buildInfoRow(context, "Make", user.carMake!),
                    if (user.carModel != null)
                      _buildInfoRow(context, "Model", user.carModel!),
                    if (user.carPlate != null)
                      _buildInfoRow(context, "Plate", user.carPlate!),
                    if (user.carColor != null)
                      _buildInfoRow(context, "Color", user.carColor!),
                    const SizedBox(height: 25),
                  ].animate().fade(duration: 700.ms),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => AuthService().signOut(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
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
                ).animate().fade(duration: 800.ms).slideY(),
                const SizedBox(height: 30),
              ],
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
    ).animate().fade(duration: 500.ms);
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () => label != "Email"
            ? _displayEditDialog(context, label, value,
                (newValue, title) => editUserInfo(newValue, title))
            : null,
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
      ),
    ).animate().fade(duration: 500.ms);
  }
}
