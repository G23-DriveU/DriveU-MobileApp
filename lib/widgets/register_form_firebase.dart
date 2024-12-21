import 'dart:io';
import 'package:driveu_mobile_app/services/auth_service.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../model/user.dart';

// This portion of the register page consists of adding information which will be stored on Firebase
class RegisterFormFirebase extends StatefulWidget {
  const RegisterFormFirebase({super.key});

  @override
  State<RegisterFormFirebase> createState() => _RegisterFormFirebaseState();
}

class _RegisterFormFirebaseState extends State<RegisterFormFirebase> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  String? _email,
      _password,
      _confirmPassword,
      _name,
      _school,
      _phoneNumber,
      _carMake,
      _carModel,
      _carPlate,
      _carColor,
      _error;
  bool _passwordsMatch = true, _isDriver = false;
  FileImage? _profileImage;
  int? _carMpg;

  // Enable user to select a photo from their gallery
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
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email Address',
              ),
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    // TODO: ensure a .edu domain name in future
                    !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                if (_error != null &&
                    _error!.contains('email-already-in-use')) {
                  return 'Email is already in use';
                }
                return null;
              },
              onSaved: (value) => _email = value,
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              validator: (value) {
                if (_error != null && _error!.contains('weak-password')) {
                  return 'Your password is too weak';
                }
                if (!_passwordsMatch) {
                  return 'Ensure that both passwords match';
                }
                return null;
              },
              onChanged: (value) {
                _password = value;
                _passwordsMatch = _password == _confirmPassword;
              },
              onSaved: (value) => _password = value,
            ),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
              ),
              validator: (value) {
                if (_error != null && _error!.contains('too weak')) {
                  return 'Ensure your password is strong enough';
                }
                if (!_passwordsMatch) {
                  return 'Ensure that both passwords match';
                }
                return null;
              },
              onChanged: (value) {
                _confirmPassword = value;
                _passwordsMatch = _password == _confirmPassword;
              },
              onSaved: (value) => _confirmPassword = value,
            ),
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
                labelText: 'Your School',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please Enter your School\' Name';
                }
                return null;
              },
              onSaved: (value) => _school = value,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Your Phone Number',
              ),
              // TODO: We are only matching US based phone numbers, maybe we consider international numbers in the future
              validator: (value) {
                if (!RegExp(
                        r'^(1\s?)?(\d{3}|\(\d{3}\))[\s\-]?\d{3}[\s\-]?\d{4}$')
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
            _profileImage == null
                // TODO: Put a default image here
                ? Image.network(
                    width: 125,
                    height: 125,
                    'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.ucf.edu%2Ffiles%2F2017%2F10%2Fknightro_two_hands_point.png&f=1&nofb=1&ipt=f3fcec4cda343ad6b15a1016a743684a41a977acedf9681488c0b9a807534670&ipo=images')
                : Image(
                    image: _profileImage!,
                    height: 100,
                    width: 100,
                  ),
            ElevatedButton(
                onPressed: _pickPhoto,
                child: const Text("Upload Profile Picture")),
            // User should enter some additional information about their car if they wish to drive
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
                      await AuthService().register(_email!, _password!);
                  // Decode the response
                  if (response == null) {
                    _error = null;
                    // Save the user, once we get confirmation that the user is registered within
                    // firebase, we can then get the firebase uid and fcm token and then save the user to our db
                    SingleUser().setUser(User(
                        email: _email!,
                        name: _name!,
                        school: _school!,
                        phoneNumber: _phoneNumber!,
                        driver: _isDriver,
                        carMake: _carMake,
                        carModel: _carModel,
                        carPlate: _carPlate,
                        carColor: _carColor,
                        carMpg: _carMpg,
                        profileImage: _profileImage));
                  } else if (response == 'weak-password') {
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
      ),
    ));
  }
}
