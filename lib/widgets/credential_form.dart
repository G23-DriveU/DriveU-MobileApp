import 'package:driveu_mobile_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class CredentialForm extends StatefulWidget {
  const CredentialForm({super.key});

  @override
  State<CredentialForm> createState() => _CredentialFormState();
}

class _CredentialFormState extends State<CredentialForm> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;

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
                await AuthService().login(_email!, _password!);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
