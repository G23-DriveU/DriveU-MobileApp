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
    return Row(
      children: [
        Expanded(
          child: TypeAheadField(
            controller: _controller,
            // hideOnEmpty: true,
            builder: (context, controller, focusNode) => TextField(
              controller: _controller,
              focusNode: focusNode,
              decoration: const InputDecoration(
                hintText: 'Search',
              ),
            ),
            suggestionsCallback: (pattern) async {
              // Call the Google Maps API to get the suggestions
              return await GoogleMapsUtils().getLocations(pattern);
            },
            onSelected: (suggestion) async {
              // Once a location is selected, call the Google Maps API to get the location details
              final finalLoc = await GoogleMapsUtils()
                  .getLocationDetails(suggestion['place_id']);

              _controller.text = suggestion['description'].toString();

              // Unfocus the text field
              FocusScope.of(context).requestFocus(FocusNode());
            },
            itemBuilder: (context, suggest) {
              return ListTile(
                title: Text(suggest['description']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Need to add Reverse Geocoding
                    IconButton(
                      icon: const Icon(Icons.location_on),
                      onPressed: () async {
                        final latlngLoc = await GoogleMapsUtils()
                            .getLocationDetails(suggest['place_id']);

                        // Set the start location
                        if (latlngLoc != null) {
                          Provider.of<MapState>(context, listen: false)
                              .setStartLocation(LatLng(
                                  latlngLoc.latitude, latlngLoc.longitude));
                        }

                        // Unfocus the text field
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.flag),
                      onPressed: () async {
                        final latlngLoc = await GoogleMapsUtils()
                            .getLocationDetails(suggest['place_id']);

                        // Set the start location
                        if (latlngLoc != null) {
                          Provider.of<MapState>(context, listen: false)
                              .setEndLocation(LatLng(
                                  latlngLoc.latitude, latlngLoc.longitude));
                        }

                        // Unfocus the text field
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        GestureDetector(
          onTap: () => _controller.clear(),
          child: const Icon(
            Icons.clear,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
