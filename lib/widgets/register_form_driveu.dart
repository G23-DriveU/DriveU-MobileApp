import 'dart:io';
import 'package:driveu_mobile_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// This portion of the register page consists of adding information which will be stored on DriveU
class RegisterFormDriveU extends StatefulWidget {
  String email, password;
  RegisterFormDriveU({super.key, required this.email, required this.password});

  @override
  State<RegisterFormDriveU> createState() => _RegisterFormDriveUState();
}

class _RegisterFormDriveUState extends State<RegisterFormDriveU> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  String? _name;
  String? _phoneNumber;
  FileImage? _profileImage;
  bool _isDriver = false;
  String? _carMake;
  String? _carModel;
  String? _carPlate;
  String? _carColor;
  int? _carMpg;
  String? _error;

  Future<void> _pickPhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = FileImage(File(pickedFile.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Your Name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please Enter your Name';
              }
              return null;
            },
            onSaved: (value) => _name = value,
          ),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Your Phone Number',
            ),
            // TODO: We are only matching US based phone numbers, maybe we consider international numbers in the future
            validator: (value) {
              if (!RegExp(r'^(1\s?)?(\d{3}|\(\d{3}\))[\s\-]?\d{3}[\s\-]?\d{4}$')
                  .hasMatch(value!)) {
                return 'Please Enter a Valid Phone Number';
              }
              return null;
            },
            onChanged: (value) {
              _phoneNumber = value;
            },
            onSaved: (value) => _phoneNumber = value,
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Would you Like to be a Driver?"),
              Checkbox(
                  value: _isDriver,
                  onChanged: (bool? value) {
                    setState(() {
                      _isDriver = value!;
                    });
                  }),
            ],
          ),
          _profileImage == null
              // TODO: Put a default image here
              ? const Text('No Image Selected')
              : Image(image: _profileImage!),
          ElevatedButton(
              onPressed: _pickPhoto,
              child: const Text("Upload Profile Picture")),
          // User should enter some additional information about their car if they wish to drive
          if (_isDriver)
            Column(
              children: [
                // TODO: Utilize Liam's endpoints for text auto complete when they are complete
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Car Make',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter your Car Make';
                    }
                    return null;
                  },
                  onSaved: (value) => _carMake = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Car Model',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter your Car Model';
                    }
                    return null;
                  },
                  onSaved: (value) => _carModel = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Car Plate',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter your Car Plate';
                    }
                    return null;
                  },
                  onSaved: (value) => _carPlate = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Car Color',
                  ),
                  onSaved: (value) => _carColor = value,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Car MPG',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter your Car MPG';
                    }
                    return null;
                  },
                  onSaved: (value) => _carMpg = int.parse(value!),
                ),
              ],
            ),
          ElevatedButton(
            onPressed: () async {
              // All form fields are valid, log the user in
              if (_formKey.currentState!.validate()) {
                // Save the form fields into the variables
                _formKey.currentState!.save();
                // Implement the register the user with firebase
                final response =
                    await AuthService().register(widget.email, widget.password);
                // Everything went fine
                if (response == null) {
                  _error = null;
                  // Go to the verify email page, by that time you should have access to the firebase uid
                  // Navigator.of(context).pop();
                }
                // The password was too weak (by default DriveU requires a password of length 6)
                else if (response == 'weak-password') {
                  setState(() {
                    _error = 'weak-password';
                  });
                } else if (response == 'email-already-in-use') {
                  setState(() {
                    _error = 'email-already-in-use';
                  });
                }
              }
            },
            child: const Text('Register'),
          ),
        ],
      ),
    ));
  }
}
