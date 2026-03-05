import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(28.6139, 77.2090),
    zoom: 12,
  );

  static const Marker _delhiMarker = Marker(
    markerId: MarkerId('delhi'),
    position: LatLng(28.6139, 77.2090),
    infoWindow: InfoWindow(title: 'Marker in Delhi'),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Map')),
      body: const GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: {_delhiMarker},
      ),
    );
  }
}
