import 'dart:convert';

import 'package:driveu_mobile_app/services/api/user_api.dart';
import 'package:driveu_mobile_app/services/auth_service.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:driveu_mobile_app/widgets/image_frame.dart';
import 'package:driveu_mobile_app/widgets/pay_pal_webview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';

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

  void _handleRoleSwitch(BuildContext context) {
    final user = SingleUser().getUser()!;

    // Update their role to a rider
    if (user.driver) {
      print("Swapping from original driver to rider");
      _swapRole(false);
    }
    // Somebody currently using the app as a rider wants to swap to a driver
    // AND they want to swap back to being a driver
    else if (user.carColor != null ||
        user.carMake != null ||
        user.carModel != null ||
        user.carPlate != null && !user.driver) {
      print("Swapping original rider, but have proper driver creds");
      _swapRole(true);
    } else {
      print("Swapping becoming a driver");
      _displayDriverForm(context);
    }
  }

  // isDriver == true => swap to a ride
  // isDriver == false => swap to driver
  void _swapRole(bool isDriver) {
    SingleUser().getUser()!.driver = isDriver;

    setState(() {});
  }

  Future<void> _displayDriverForm(BuildContext context) async {
    // Store info about the car and the PayPal payer id
    String? carMake, carModel, carPlate, carColor, authCode0, paypalError;
    Map<String, List<String>> carDataMap = {};
    final formKey = GlobalKey<FormState>();

    // Load car data before showing the dialog
    carDataMap = await loadCarData();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Enter Your Information"),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildAutocompleteField(
                        label: 'Car Make',
                        options: carDataMap.keys.toList(),
                        onSelected: (String selection) {
                          setDialogState(() {
                            carMake = selection;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildAutocompleteField(
                        label: 'Car Model',
                        options:
                            carMake != null && carDataMap.containsKey(carMake)
                                ? carDataMap[carMake]!
                                : [],
                        onSelected: (String selection) {
                          setDialogState(() {
                            carModel = selection;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        label: 'Car Plate',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter your Car Plate';
                          }
                          return null;
                        },
                        onSaved: (value) => carPlate = value,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        label: 'Car Color',
                        onSaved: (value) => carColor = value,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          final authCode = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PayPalWebView(url: null),
                            ),
                          );

                          if (authCode.runtimeType == String) {
                            authCode0 = authCode as String?;
                          } else {
                            authCode0 = null;
                          }
                        },
                        child: const Text("Link PayPal"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save(); // Save the form data

                            if (authCode0 != null) {
                              final Map<String, String> newUserParams = {
                                "userId": SingleUser().getUser()!.id.toString(),
                                "name": SingleUser().getUser()!.name,
                                "phoneNumber":
                                    SingleUser().getUser()!.phoneNumber,
                                "school": SingleUser().getUser()!.school,
                                "driver": true.toString(),
                                "carColor": carColor!,
                                "carPlate": carPlate!,
                                "carMake": carMake!,
                                "carModel": carModel!,
                                "authCode": authCode0!
                              };
                              setState(() {});
                              // Update the user info
                              await UserApi().editUserInfo(newUserParams);
                              SingleUser().getUser()!.driver = true;
                              SingleUser().getUser()!.carColor = carColor;
                              SingleUser().getUser()!.carPlate = carPlate;
                              SingleUser().getUser()!.carMake = carMake;
                              SingleUser().getUser()!.carModel = carModel;
                              Navigator.of(context).pop();
                            } else {
                              paypalError =
                                  "Please link your PayPal account to continue.";
                            }
                          } else {
                            // Show an error message if validation fails
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Please fill in all required fields")),
                            );
                          }
                        },
                        child: const Text("Send Driver Information"),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, List<String>>> loadCarData() async {
    final String response =
        await rootBundle.loadString('assets/vehicle_models_cleaned.json');
    final List<dynamic> data = json.decode(response);
    final Map<String, List<String>> carData = {};
    for (var item in data) {
      final String make = item['Make'];
      final List<String> models = List<String>.from(item['Models']);
      carData[make] = models;
    }
    return carData;
  }

  Widget _buildTextField({
    required String label,
    bool obscureText = false,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
    FormFieldSetter<String>? onSaved,
  }) {
    return TextFormField(
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true, // Fill the background
        fillColor: Colors.white, // Set background color to white
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0), // Curved corners
        ),
      ),
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
      style: const TextStyle(fontFamily: 'Fredoka'),
    );
  }

  Widget _buildAutocompleteField({
    required String label,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return options.where((String option) {
          return option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: onSelected,
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            filled: true, // Fill the background
            fillColor: Colors.white, // Set background color to white
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0), // Curved corners
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please Enter $label';
            }
            return null;
          },
          style: const TextStyle(fontFamily: 'Fredoka'),
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

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      _uploadProfilePhoto(image);
    }
  }

  Future<void> _uploadProfilePhoto(XFile image) async {
    try {
      // Convert the image to bytes
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Call your API to upload the image
      await UserApi().sendProfileImage(
        FirebaseAuth.instance.currentUser!.uid,
        base64Image,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated successfully!')),
      );

      // Update the UI
      setState(() {
        // Optionally refresh the user's profile photo
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile photo: $e')),
      );
    }
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
        child: SingleChildScrollView(
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
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
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
                            child: GestureDetector(
                              onTap: () => _showPhotoOptions(context),
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  ClipOval(
                                    child: SizedBox(
                                      width: 120,
                                      height: 120,
                                      child: ImageFrame(
                                          firebaseUid: currentUser.uid),
                                    ),
                                  ),
                                  CircleAvatar(
                                    backgroundColor: Colors.teal,
                                    radius: 20,
                                    child: const Icon(Icons.camera_alt,
                                        color: Colors.white),
                                  ),
                                ],
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
                        _buildInfoRow(
                            context, "Name", user.name ?? 'Not provided'),
                        _buildInfoRow(
                            context, "Email", user.email ?? 'Not provided'),
                        _buildInfoRow(context, "Phone",
                            user.phoneNumber ?? 'Not provided'),
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
                    ElevatedButton(
                      onPressed: () => _handleRoleSwitch(context),
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
                      child: Text(
                        SingleUser().getUser()!.driver == true
                            ? "Switch to Rider"
                            : "Switch to Driver",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
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
