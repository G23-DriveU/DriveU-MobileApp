import 'dart:convert';
import 'dart:io';
import 'package:driveu_mobile_app/services/api/user_api.dart';
import 'package:driveu_mobile_app/services/auth_service.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../model/app_user.dart';

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
  File? _profileImage;
  // To enable users to select their car from a known list
  Map<String, List<String>> _carData = {};
  Set<String> _uniData = {};

  // Enable user to select a photo from their gallery
  Future<void> _pickPhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Encode the image as base64
  String? _encodeToBase64(File? image) {
    if (image == null) return null;
    return base64Encode(image.readAsBytesSync());
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

  void _loadCarData() async {
    final carData = await loadCarData();
    setState(() {
      _carData = carData;
    });
  }

  Future<Set<String>> loadSchoolData() async {
    final String response =
        await rootBundle.loadString('assets/us_institutions.json');
    final List<dynamic> data = json.decode(response);
    final Set<String> uniData = {};
    // Loop through and add all of the colleges
    for (var item in data) {
      uniData.add(item['institution']);
    }
    return uniData;
  }

  void _loadSchoolData() async {
    final uniData = await loadSchoolData();
    setState(() {
      _uniData = uniData;
    });
  }

  @override
  void initState() {
    super.initState();
    // Load all of the car data from assets
    _loadSchoolData();
    _loadCarData();
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
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                if (_error == 'email-already-in-use') {
                  return 'Email already in use';
                }
                return null;
              },
              onChanged: (value) => setState(() {
                _error = null;
              }),
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
                setState(() {
                  _error = null;
                });
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
                if (_error != null && _error! == 'weak-password') {
                  return 'Your password is too weak';
                }
                if (!_passwordsMatch) {
                  return 'Ensure that both passwords match';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _error = null;
                });
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
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return _uniData.where((String option) {
                  return option
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                setState(() {
                  _school = selection;
                });
              },
              fieldViewBuilder: (BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted) {
                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Your School',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Your School';
                    }
                    return null;
                  },
                );
              },
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
                : SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.file(_profileImage!),
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
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return _carData.keys.where((String option) {
                        return option
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      setState(() {
                        _carMake = selection;
                      });
                    },
                    fieldViewBuilder: (BuildContext context,
                        TextEditingController textEditingController,
                        FocusNode focusNode,
                        VoidCallback onFieldSubmitted) {
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Car Make',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter your Car Make';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty || _carMake == null) {
                        return const Iterable<String>.empty();
                      }
                      return _carData[_carMake]!.where((String option) {
                        return option
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      setState(() {
                        _carModel = selection;
                      });
                    },
                    fieldViewBuilder: (BuildContext context,
                        TextEditingController textEditingController,
                        FocusNode focusNode,
                        VoidCallback onFieldSubmitted) {
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Car Model',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter your Car Model';
                          }
                          return null;
                        },
                      );
                    },
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
                  // TODO: Need to fix this since I need to send the user info to the DriveU database
                  if (response == null) {
                    SingleUser().setUser(AppUser(
                      firebaseUid: FirebaseAuth.instance.currentUser!.uid,
                      email: _email!,
                      // TODO: Might remove this since to send base64 need to use JSON
                      // profileImage: _encodeToBase64(_profileImage),
                      name: _name!,
                      school: _school!,
                      phoneNumber: _phoneNumber!,
                      driver: _isDriver,
                      carMake: _carMake,
                      carModel: _carModel,
                      carPlate: _carPlate,
                      carColor: _carColor,
                    ));
                    // Register the user with our database
                    await UserApi()
                        .createUser(SingleUser().getUser()!.toQueryParams());
                    await UserApi().sendProfileImage(
                        FirebaseAuth.instance.currentUser!.uid,
                        _encodeToBase64(_profileImage)!);

                    _error = null;
                    Navigator.pop(context);
                  } else if (response == 'weak-password') {
                    setState(() {
                      _error = 'weak-password';
                    });
                    _formKey.currentState!.validate();
                  } else if (response == 'email-already-in-use') {
                    setState(() {
                      _error = 'email-already-in-use';
                    });
                    _formKey.currentState!.validate();
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
