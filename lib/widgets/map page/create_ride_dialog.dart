import 'package:driveu_mobile_app/model/map_state.dart';
import 'package:driveu_mobile_app/services/api/trip_api.dart';
import 'package:driveu_mobile_app/services/google_maps_utils.dart';
import 'package:driveu_mobile_app/services/single_user.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class CreateRideDialog extends StatefulWidget {
  const CreateRideDialog({super.key});

  @override
  State<CreateRideDialog> createState() => _CreateRideDialogState();
}

class _CreateRideDialogState extends State<CreateRideDialog> {
  bool avoidTolls = false, avoidHighways = false, roundTrip = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Duration _duration = Duration(hours: 0, minutes: 0);
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now,
        lastDate: DateTime(now.year + 1));
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay now = TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: now,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please select a time that is not before the current time.')),
      );
    }
  }

  int? _secondsSinceEpoch() {
    if (_selectedDate != null && _selectedTime != null) {
      final DateTime tse = DateTime(_selectedDate!.year, _selectedDate!.month,
          _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute);
      return (tse.millisecondsSinceEpoch ~/ 1000);
    }
    return null;
  }

  Widget _buildTypeAheadField(
      String hintText, TextEditingController controller, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Spacing between inputs
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Inner padding
        child: TypeAheadField(
          controller: controller,
          builder: (context, textController, focusNode) => TextField(
            controller: textController,
            focusNode: focusNode,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
            ),
          ),
          suggestionsCallback: (pattern) async {
            return await GoogleMapsUtils().getLocations(pattern);
          },
          onSelected: (suggestion) async {
            final finalLoc = await GoogleMapsUtils()
                .getLocationDetails(suggestion['place_id']);

            controller.text = suggestion['description'].toString();
            FocusScope.of(context).requestFocus(FocusNode());
          },
          itemBuilder: (context, suggest) {
            return ListTile(
              title: Text(suggest['description']),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Post a Ride"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTypeAheadField("Start Location", _startController, context),
            _buildTypeAheadField("End Location", _endController, context),
            SizedBox(height: 10), // Extra spacing
            ListTile(
              title: const Text("Select Date"),
              trailing: _selectedDate == null
                  ? const Text("Select Date")
                  : Text(
                      "${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}"),
              onTap: () => _selectDate(context),
            ),
            ListTile(
              title: const Text("Select Time"),
              trailing: _selectedTime == null
                  ? const Text("Select Time")
                  : Text("${_selectedTime!.hour}:${_selectedTime!.minute}"),
              onTap: () => _selectTime(context),
            ),
            SizedBox(height: 10),
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
            if (roundTrip)
              Column(
                children: [
                  const Text("How Long do You Plan to Stay?"),
                  DurationPicker(
                    onChange: (val) => setState(() {
                      _duration = val;
                    }),
                    duration: _duration,
                  )
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (_startController.text == "" || _endController.text == "") {
              return;
            }
            if (_selectedDate == null || _selectedTime == null) {
              return;
            }
            final int? epochSeconds = _secondsSinceEpoch();

            try {
              final response = await TripApi().createTrip({
                'driverId': SingleUser().getUser()!.id.toString(),
                'startTime': epochSeconds.toString(),
                'avoidHighways': avoidHighways.toString(),
                'avoidTolls': avoidTolls.toString(),
                'roundTrip': roundTrip.toString(),
                'startLocationLat':
                    Provider.of<MapState>(context, listen: false)
                        .startLocation
                        .latitude
                        .toString(),
                'startLocationLng':
                    Provider.of<MapState>(context, listen: false)
                        .startLocation
                        .longitude
                        .toString(),
                'destinationLat': Provider.of<MapState>(context, listen: false)
                    .endLocation
                    .latitude
                    .toString(),
                'destinationLng': Provider.of<MapState>(context, listen: false)
                    .endLocation
                    .longitude
                    .toString(),
                'timeAtDestination': _duration.inSeconds.toString()
              });

              Navigator.of(context).pop();
            } on Exception catch (e) {
              print("DEBUG: There was an error creating the trip $e");
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
