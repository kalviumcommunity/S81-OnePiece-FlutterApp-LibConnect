import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStreamSubscription;
  Marker? _userMarker;
  BitmapDescriptor _markerIcon = BitmapDescriptor.defaultMarker;
  Position? _currentPosition;
  bool _isLoadingLocation = true;

  static const CameraPosition _fallbackCameraPosition = CameraPosition(
    target: LatLng(28.6139, 77.2090),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _initializeLocationTracking();
  }

  Future<void> _initializeLocationTracking() async {
    final hasPermission = await _requestLocationPermission();
    if (!hasPermission) {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
      return;
    }

    await _loadCustomMarkerIcon();
    await _fetchCurrentLocation();
    _startLiveTracking();

    if (mounted) {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<bool> _requestLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services.')),
        );
      }
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission is required.')),
        );
      }
      return false;
    }

    return true;
  }

  Future<void> _loadCustomMarkerIcon() async {
    try {
      final customIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/location_pin.png',
      );

      if (mounted) {
        setState(() => _markerIcon = customIcon);
      }
    } catch (_) {
      _markerIcon = BitmapDescriptor.defaultMarker;
    }
  }

  Future<void> _fetchCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _updateUserLocation(position, animateCamera: true);
  }

  void _startLiveTracking() {
    _positionStreamSubscription =
        Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      _updateUserLocation(position);
    });
  }

  void _updateUserLocation(
    Position position, {
    bool animateCamera = false,
  }) {
    final target = LatLng(position.latitude, position.longitude);

    if (!mounted) return;

    setState(() {
      _currentPosition = position;
      _userMarker = Marker(
        markerId: const MarkerId('live'),
        position: target,
        icon: _markerIcon,
        infoWindow: const InfoWindow(title: 'You are here'),
      );
    });

    if (animateCamera && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: 15),
        ),
      );
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initialTarget = _currentPosition == null
        ? _fallbackCameraPosition.target
        : LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    final markers = <Marker>{
      if (_userMarker != null)
        _userMarker!
      else
        const Marker(
          markerId: MarkerId('delhi'),
          position: LatLng(28.6139, 77.2090),
          infoWindow: InfoWindow(title: 'Marker in Delhi'),
        ),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Google Map Live Tracking')),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
              if (_currentPosition != null) {
                final target =
                    LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
                _mapController!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: target, zoom: 15),
                  ),
                );
              }
            },
            initialCameraPosition: CameraPosition(
              target: initialTarget,
              zoom: _currentPosition == null ? 12 : 15,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: markers,
          ),
          if (_isLoadingLocation)
            const Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text('Fetching your current location...'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
