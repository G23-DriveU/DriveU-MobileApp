import 'package:driveu_mobile_app/model/map_state.dart';
import 'package:driveu_mobile_app/services/google_maps_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class LocationSuggest extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  LocationSuggest({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Thick white rounded rectangular border overlay (non-blocking)
        IgnorePointer(
          ignoring: true, // Prevents blocking interaction with the search bar
          child: Positioned(
            left: 0,
            right: 20,
            child: Container(
              width: double.infinity,
              height: 60, // Adjust height
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), // Rounded rectangular
                border: Border.all(color: Colors.white, width: 6), // Thick white border
              ),
            ),
          ),
        ),

        // Search bar and suggestions (above the border)
        Row(
          children: [
            Expanded(
              child: TypeAheadField(
                controller: _controller,
                builder: (context, controller, focusNode) => TextField(
                  decoration: InputDecoration(
                    hintText: "Input your pickup location",
                    hintStyle: TextStyle(color: Colors.grey[600]),
focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.teal, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 1))
                  ),
                  controller: _controller,
                  focusNode: focusNode,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 16,
                    ),
                ),
                suggestionsCallback: (pattern) async {
                  return await GoogleMapsUtils().getLocations(pattern);
                },
                onSelected: (suggestion) async {
                  final finalLoc = await GoogleMapsUtils()
                      .getLocationDetails(suggestion['place_id']);

                  _controller.text = suggestion['description'].toString();
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                itemBuilder: (context, suggest) {
                  return ListTile(
                    title: GestureDetector(
                      child: Text(suggest['description']),
                      onTap: () async {
                        final latlngLoc = await GoogleMapsUtils()
                            .getLocationDetails(suggest['place_id']);

                        if (latlngLoc != null) {
                          Provider.of<MapState>(context, listen: false)
                              .setStartLocation(LatLng(
                                  latlngLoc.latitude, latlngLoc.longitude));
                        }

                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    ),
                  );
                },
              ),
            ),
            GestureDetector(
              onTap: () => _controller.clear(),
              child: const Icon(
                Icons.clear,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
