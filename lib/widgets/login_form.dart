import 'package:driveu_mobile_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Form(
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
              if (_error != null) return 'Invalid email or password';
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
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (_error != null) return 'Invalid email or password';
              return null;
            },
            onSaved: (value) => _password = value,
          ),
          ElevatedButton(
            onPressed: () async {
              // All form fields are valid, log the user in
              if (_formKey.currentState!.validate()) {
                // Save the form fields into the variables
                _formKey.currentState!.save();
                // Implement the login logic here
                final response = await AuthService().login(_email!, _password!);
                print("Debugging: $response");
                // There was an error that needs to be handled
                if (response != null) {
                  setState(() {
                    _error = "Invalid email or password";
                  });
                } else
                  setState(() {
                    _error = null;
                  });
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
