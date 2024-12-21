import 'package:driveu_mobile_app/services/auth_service.dart';
import 'package:driveu_mobile_app/widgets/register_form_driveu.dart';
import 'package:flutter/material.dart';

// This portion of the register page consists of adding information which will be stored on Firebase
class RegisterFormFirebase extends StatefulWidget {
  const RegisterFormFirebase({super.key});

  @override
  State<RegisterFormFirebase> createState() => _RegisterFormFirebaseState();
}

class _RegisterFormFirebaseState extends State<RegisterFormFirebase> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;
  String? _confirmPassword;
  bool _passwordsMatch = true;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
      key: _formKey,
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
              if (_error != null && _error!.contains('email-already-in-use')) {
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
          ElevatedButton(
            onPressed: () async {
              // All form fields are valid, log the user in
              if (_formKey.currentState!.validate()) {
                // Save the form fields into the variables
                _formKey.currentState!.save();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RegisterFormDriveU(
                        email: _email!, password: _password!),
                  ),
                );
              }
            },
            child: const Text('Next'),
          ),
        ],
      ),
    ));
  }
}
