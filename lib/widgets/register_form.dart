import 'package:driveu_mobile_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
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
                // Implement the register the user with firebase
                final response =
                    await AuthService().register(_email!, _password!);
                // Everything went fine
                if (response == null) {
                  _error = null;
                }
                // The password was too weak (by default Firebase requires a password of length 6)
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
            child: const Text('Submit'),
          ),
        ],
      ),
    ));
  }
}
