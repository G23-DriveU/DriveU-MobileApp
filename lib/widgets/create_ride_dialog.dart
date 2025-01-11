import 'package:flutter/material.dart';

// TODO: will need to add Google Maps here for textual autofill
class CreateRideDialog extends StatefulWidget {
  const CreateRideDialog({super.key});

  @override
  State<CreateRideDialog> createState() => _CreateRideDialogState();
}

class _CreateRideDialogState extends State<CreateRideDialog> {
  bool avoidTolls = false, avoidHighways = false, roundTrip = false;
  TimeOfDay? selectedTime;

  // Select a time for the ride to start
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay now = TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: now,
    );
    if (picked != null &&
        (picked.hour > now.hour ||
            (picked.hour == now.hour && picked.minute >= now.minute))) {
      setState(() {
        selectedTime = picked;
      });
    } else {
      // Show an error message if the selected time is before the current time
      // TODO: Don't know if I like this, might do something else
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please select a time that is not before the current time.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Post a Ride"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const TextField(
            decoration: InputDecoration(hintText: 'Enter origin'),
          ),
          const TextField(
            decoration: InputDecoration(hintText: 'Enter destination'),
          ),
          ListTile(
            title: const Text("Select Time"),
            trailing: selectedTime == null
                ? const Text("Select Time")
                : Text("${selectedTime!.hour}:${selectedTime!.minute}"),
            onTap: () => _selectTime(context),
          ),
          CheckboxListTile(
            title: const Text("Avoid Tolls"),
            value: avoidTolls,
            onChanged: (bool? value) {
              setState(() {
                avoidTolls = value ?? false;
              });
            },
          ),
          CheckboxListTile(
            title: const Text("Avoid Highways"),
            value: avoidHighways,
            onChanged: (bool? value) {
              setState(() {
                avoidHighways = value ?? false;
              });
            },
          ),
          CheckboxListTile(
            title: const Text("Round Trip"),
            value: roundTrip,
            onChanged: (bool? value) {
              setState(() {
                roundTrip = value ?? false;
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
            // Handle ride creation
            Navigator.of(context).pop();
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
