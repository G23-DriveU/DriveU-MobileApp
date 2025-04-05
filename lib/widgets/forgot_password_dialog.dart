import 'package:driveu_mobile_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _email;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Enter the Email you Signed up With"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email',
                filled: true, // Fill the background
                fillColor: Colors.white, // Set background color to white
                prefixIcon: Icon(Icons.mail, color: Colors.teal),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              onSaved: (value) => _email = value,
            )
          ],
        ),
      ),
      actions: [
        ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel")),
        ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                AuthService().resetPassword(_email!);
                Navigator.of(context).pop();
              }
            },
            child: const Text("Send"))
      ],
    );
  }
}
