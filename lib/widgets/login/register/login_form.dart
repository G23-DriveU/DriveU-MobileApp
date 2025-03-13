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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email',
                filled: true, // Fill the background
                fillColor: Colors.white, // Set background color to white
                prefixIcon: Icon(Icons.email, color: Colors.teal),
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                if (_error != null) return 'Invalid email or password';
                return null;
              },
              onChanged: (value) => setState(() {
                _error = null;
              }),
              onSaved: (value) => _email = value,
            ),
            const SizedBox(height: 20),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                filled: true, // Fill the background
                fillColor: Colors.white, // Set background color to white
                prefixIcon: Icon(Icons.lock, color: Colors.teal),
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (_error != null) return 'Invalid email or password';
                return null;
              },
              onChanged: (value) => setState(() {
                _error = null;
              }),
              onSaved: (value) => _password = value,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  try {
                    final response = await AuthService().login(_email!.trim(), _password!.trim());
                    if (response != null) {
                      throw Exception('Invalid email or password');
                    }
                  } catch (e) {
                    setState(() {
                      _error = 'Invalid email or password';
                    });
                    _formKey.currentState!.validate();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                "Submit",
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
