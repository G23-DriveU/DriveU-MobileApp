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
  Map<String, List<String>> _carData = {};
  Set<String> _uniData = {};

  Future<void> _pickPhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

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
    _loadSchoolData();
    _loadCarData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue[100]!,
              Colors.yellow[100]!,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
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
                  style: const TextStyle(fontFamily: 'Fredoka'),
                ),
                const SizedBox(height: 20),
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
                  style: const TextStyle(fontFamily: 'Fredoka'),
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
                  style: const TextStyle(fontFamily: 'Fredoka'),
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
                  style: const TextStyle(fontFamily: 'Fredoka'),
                ),
                const SizedBox(height: 20),
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
                      style: const TextStyle(fontFamily: 'Fredoka'),
                    );
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Your Phone Number',
                    // (),
                  ),
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
                  style: const TextStyle(fontFamily: 'Fredoka'),
                ),
                const SizedBox(height: 20),
                _profileImage == null
                    ? Image.asset(
                        'assets/images/knightro.bmp',
                        height: 150,
                        width: 150,
                      )
                    : SizedBox(
                        width: 150,
                        height: 150,
                        child: Image.file(_profileImage!),
                      ),
                ElevatedButton(
                    onPressed: _pickPhoto,
                    child: const Text("Upload Profile Picture")),
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
                              // (),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter your Car Make';
                              }
                              return null;
                            },
                            style: const TextStyle(fontFamily: 'Fredoka'),
                          );
                        },
                      ),
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty ||
                              _carMake == null) {
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
                            style: const TextStyle(fontFamily: 'Fredoka'),
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
                        style: const TextStyle(fontFamily: 'Fredoka'),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Car Color',
                        ),
                        onSaved: (value) => _carColor = value,
                        style: const TextStyle(fontFamily: 'Fredoka'),
                      ),
                    ],
                  ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final response =
                          await AuthService().register(_email!, _password!);
                      if (response == null) {
                        SingleUser().setUser(AppUser(
                          firebaseUid: FirebaseAuth.instance.currentUser!.uid,
                          email: _email!,
                          name: _name!,
                          school: _school!,
                          phoneNumber: _phoneNumber!,
                          driver: _isDriver,
                          carMake: _carMake,
                          carModel: _carModel,
                          carPlate: _carPlate,
                          carColor: _carColor,
                        ));
                        await UserApi().createUser(
                            SingleUser().getUser()!.toQueryParams());
                        // Don't send a photo if it wasn't selected.
                        if (_profileImage != null) {
                          await UserApi().sendProfileImage(
                              FirebaseAuth.instance.currentUser!.uid,
                              _encodeToBase64(_profileImage)!);
                        }

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
        ),
      ),
    );
  }
}
