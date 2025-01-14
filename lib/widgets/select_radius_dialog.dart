import 'package:flutter/material.dart';

class SelectRadiusDialog extends StatefulWidget {
  const SelectRadiusDialog({super.key});

  @override
  State<SelectRadiusDialog> createState() => _SelectRadiusDialogState();
}

class _SelectRadiusDialogState extends State<SelectRadiusDialog> {
  double _radius = 5.0;
  bool wantRoundTrip = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Search Radius'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: _radius,
            min: 1,
            max: 10,
            divisions: 10,
            label: '${_radius.round()} miles',
            onChanged: (value) {
              setState(() {
                _radius = value;
              });
            },
          ),
          Text('Radius: ${_radius.round()} miles'),
          CheckboxListTile(
            title: const Text('Round Trip?'),
            value: wantRoundTrip,
            onChanged: (value) {
              setState(() {
                wantRoundTrip = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Handle radius selection
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
