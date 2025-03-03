import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  final Location _location = Location();

  final List<Map<String, dynamic>> _locations = [
    {"name": "กรุงเทพฯ", "position": LatLng(13.7563, 100.5018)},
    {"name": "เชียงใหม่", "position": LatLng(18.7883, 98.9853)},
    {"name": "ภูเก็ต", "position": LatLng(7.8804, 98.3923)},
  ];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission != PermissionStatus.granted) return;
      }

      var userLocation = await _location.getLocation();
      setState(() {
        _currentPosition = LatLng(userLocation.latitude!, userLocation.longitude!);
        _mapController.move(_currentPosition!, 15);
      });
      _getAddressFromLatLng(_currentPosition!);
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
        });
      }
    } catch (e) {
      print('Error fetching address: $e');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('แผนที่ (OpenStreetMap)')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _currentPosition ?? LatLng(13.7563, 100.5018),
              zoom: 15,
              minZoom: 3,
              maxZoom: 18,
              interactiveFlags: InteractiveFlag.all,
              onTap: (tapPosition, latLng) {
                _showSnackbar('📍 พิกัดที่กด: ${latLng.latitude}, ${latLng.longitude}');
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              if (_currentPosition != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _currentPosition!,
                      color: Colors.blue.withOpacity(0.3),
                      borderStrokeWidth: 2,
                      borderColor: Colors.blue,
                      radius: 20,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: _locations.map((place) {
                  LatLng position = place["position"];
                  String name = place["name"];
                  return Marker(
                    width: 50.0,
                    height: 50.0,
                    point: position,
                    anchorPos: AnchorPos.align(AnchorAlign.center),
                    builder: (ctx) => GestureDetector(
                      onTap: () => _showSnackbar("📍 สถานที่: $name\n🗺 พิกัด: ${position.latitude}, ${position.longitude}"),
                      child: const MyMapMarker(),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'zoomIn',
                  child: const Icon(Icons.add),
                  onPressed: () => _mapController.move(_mapController.center, _mapController.zoom + 1),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'zoomOut',
                  child: const Icon(Icons.remove),
                  onPressed: () => _mapController.move(_mapController.center, _mapController.zoom - 1),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'location',
                  onPressed: _getUserLocation,
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class MyMapMarker extends StatelessWidget {
  const MyMapMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 15,
          height: 15,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
