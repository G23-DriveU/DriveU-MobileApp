import 'package:driveu_mobile_app/model/map_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectRadiusDialog extends StatefulWidget {
  final Function(double, bool) onRadiusSelected;
  const SelectRadiusDialog({super.key, required this.onRadiusSelected});

  @override
  State<SelectRadiusDialog> createState() => _SelectRadiusDialogState();
}

class _SelectRadiusDialogState extends State<SelectRadiusDialog> {
  late double _radius;
  late bool _wantRoundTrip;

  @override
  void initState() {
    super.initState();
    // Set the values to what is stored in the MapState
    final mapState = Provider.of<MapState>(context, listen: false);
    _radius = mapState.radius;
    _wantRoundTrip = mapState.wantRoundTrip;
  }

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
            value: _wantRoundTrip,
            onChanged: (value) {
              setState(() {
                _wantRoundTrip = value!;
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
            widget.onRadiusSelected(_radius, _wantRoundTrip);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
