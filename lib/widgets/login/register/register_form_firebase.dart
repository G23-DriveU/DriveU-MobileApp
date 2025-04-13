import 'dart:convert';
import 'dart:io';
import 'package:driveu_mobile_app/model/app_user.dart';
import 'package:driveu_mobile_app/services/api/user_api.dart';
import 'package:driveu_mobile_app/services/auth_service.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:driveu_mobile_app/widgets/pay_pal_webview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'safety.dart';

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
      _authCode,
      _error,
      _paypalError;
  bool _passwordsMatch = true, _isDriver = false, _isMounted = true;
  File? _profileImage;
  String? _profileImageEncoded;
  Map<String, List<String>> _carData = {};
  Set<String> _uniData = {};

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
      setState(() {
        _profileImage = File(image.path); // Update the profile image
      });
      _uploadProfilePhoto(image);
    }
  }

  Future<void> _uploadProfilePhoto(XFile image) async {
    // Convert the image to bytes
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);
    // Save this for later
    _profileImageEncoded = base64Image;
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
    if (_isMounted) {
      setState(() {
        _carData = carData;
      });
    }
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
    if (_isMounted) {
      setState(() {
        _uniData = uniData;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSchoolData();
    _loadCarData();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFBBDEFB),
              Colors.teal[100]!,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0), // Add padding for spacing
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
                _buildTextField(
                  label: 'Email Address',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    if (!value.endsWith('.edu')) {
                      return 'Please enter your university assigned email address';
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
                const SizedBox(height: 20),
                _buildTextField(
                  label: 'Password',
                  obscureText: true,
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
                const SizedBox(height: 20),
                _buildTextField(
                  label: 'Confirm Password',
                  obscureText: true,
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
                const SizedBox(height: 20),
                _buildTextField(
                  label: 'Your Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter your Name';
                    }
                    return null;
                  },
                  onSaved: (value) => _name = value,
                ),
                const SizedBox(height: 20),
                _buildAutocompleteField(
                  label: 'Your School',
                  options: _uniData.toList(),
                  onSelected: (String selection) {
                    setState(() {
                      _school = selection;
                    });
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  label: 'Your Phone Number',
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
                const SizedBox(height: 20),
                ClipOval(
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: _profileImage == null
                        ? Image.asset(
                            'assets/images/knightro.bmp',
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            _profileImage!,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () => _showPhotoOptions(context),
                    child: const Text("Upload Profile Picture")),
                const SizedBox(height: 20),
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
                      const SizedBox(height: 20),
                      _buildAutocompleteField(
                        label: 'Car Make',
                        options: _carData.keys.toList(),
                        onSelected: (String selection) {
                          setState(() {
                            _carMake = selection;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildAutocompleteField(
                        label: 'Car Model',
                        options: _carMake != null ? _carData[_carMake]! : [],
                        onSelected: (String selection) {
                          setState(() {
                            _carModel = selection;
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
                        onSaved: (value) => _carPlate = value,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        label: 'Car Color',
                        onSaved: (value) => _carColor = value,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: () async {
                            if (_isMounted) {
                              // Grab the users PayPal ID so they can get paid for rides
                              final authCode = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PayPalWebView(url: null),
                                ),
                              );

                              // We got a valid id
                              if (authCode.runtimeType == String) {
                                _authCode = authCode as String?;
                              } else {
                                _authCode = null;
                              }
                            }
                          },
                          child: const Text("Link PayPal"))
                    ],
                  ),
                if (_paypalError != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _paypalError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // If they want to be a driver and they haven't gotten the auth code, then invalidate the form
                      if (_isDriver && _authCode == null) {
                        setState(() {
                          _paypalError =
                              'Please link your PayPal account to continue.';
                        });
                        return;
                      }
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
                            SingleUser().getUser()!.toQueryParams(_authCode));
                        // Don't send a photo if it wasn't selected.
                        if (_profileImage != null) {
                          await UserApi().sendProfileImage(
                              FirebaseAuth.instance.currentUser!.uid,
                              _profileImageEncoded!);
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
                  child: const Text(
                    'Register',
                    style: TextStyle(fontSize: 18), // Increased font size
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "We are excited for you to join us! Please read our ",
                  style: TextStyle(fontSize: 16), // Paragraph font size
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SafetyFeaturesPage()), // Replace with your SafetyScreen
                    );
                  },
                  child: Text(
                    "safety features",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue, // Makes it look like a link
                      decoration: TextDecoration
                          .underline, // Underline to indicate it's clickable
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
}

// Function to navigate to the RegisterFormFirebase with a transition
void navigateToRegisterForm(BuildContext context) {
  Navigator.of(context).push(PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        const RegisterFormFirebase(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(-1.0, 0.0); // Start from the left
      const end = Offset.zero; // End at the original position
      const curve = Curves.easeInOut; // Transition curve

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  ));
}
