import 'dart:async';

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
  late double _previousZoom = 12;
  late bool _isMessageVisible = false;
  late int _countdownTime = 5;
  LatLng _currentPosition = LatLng(13.7563, 100.5018);
  final Location _location = Location();
  List<Map<String, dynamic>> _stations = [];

  @override
  void initState() {
    super.initState();
    _getUserLocation(false);
    _fetchAQIStations();
  }

  Future<void> _getUserLocation(bool status) async {
    //status = false คือ มาจากเริ่มต้นหน้า
    //status = true คือ มาจากกดปุ่ม "แสดงตำแหน่งปัจจุบัน"
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
      if (userLocation.latitude != null && userLocation.longitude != null) {
        if (status == true) {
          setState(() {
            _currentPosition = LatLng(
              userLocation.latitude!,
              userLocation.longitude!,
            );
            _mapController.move(_currentPosition, 12);
          });
        } else {
          _mapController.move(_currentPosition, 5.5);
        }
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _fetchAQIStations() async {
    final url = Uri.parse(
      'http://air4thai.pcd.go.th/services/getNewAQI_JSON.php',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _stations = (data['stations'] as List).map((station) {
            return {
              "name": station["nameTH"],
              "position": LatLng(
                double.parse(station["lat"]),
                double.parse(station["long"]),
              ),
              "aqi": _parseValue(station["AQILast"]?["AQI"]?["aqi"]),
              "PM25": _parseValue(station["AQILast"]?["PM25"]?["value"]),
              "PM10": _parseValue(station["AQILast"]?["PM10"]?["value"]),
            };
          }).toList();
        });
      }
    } catch (e) {
      print('Error fetching AQI data: $e');
    }
  }

  String _parseValue(dynamic value) {
    if (value == null || value == "-1") {
      return "\"N/A\"";
    }
    return value.toString();
  }


  void _zoomToStation(LatLng stationPosition) {
    _previousZoom = _mapController.zoom;
    _mapController.move(stationPosition, 12);
    setState(() {
      _isMessageVisible = true;
    });
    int countdown = 5;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() {
          _countdownTime = countdown;
        });
        countdown--;
      } else {
        _countdownTime = 5;
        timer.cancel();
      }
    });
    Future.delayed(const Duration(seconds: 5), () {
      _mapController.move(_currentPosition, _previousZoom);
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isMessageVisible = false;
        });
      });
    });
  }

  void _showSnackbar(
      String message, {
        Color backgroundColor = Colors.black,
        Color textColor = Colors.white,
        Duration duration = const Duration(seconds: 4),
        String actionLabel = '',
        VoidCallback? onAction,
        double fontSize = 14.0,
        String fontFamily = 'NotoSansThai',
      }) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontFamily: fontFamily,
        ),
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      elevation: 6,
      action: actionLabel.isNotEmpty
          ? SnackBarAction(
        label: actionLabel,
        onPressed: onAction ?? () {},
        textColor: textColor,
      )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('แผนที่คุณภาพอากาศ')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _currentPosition,
              zoom: 12,
              minZoom: 3,
              maxZoom: 18,
              interactiveFlags: InteractiveFlag.all,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 50.0,
                    height: 50.0,
                    point: _currentPosition,
                    anchorPos: AnchorPos.align(AnchorAlign.center),
                    builder: (ctx) => const MyLocationMarker(),
                  ),
                  ..._stations.map((station) {
                    return Marker(
                      width: 50.0,
                      height: 50.0,
                      point: station["position"],
                      anchorPos: AnchorPos.align(AnchorAlign.center),
                      builder:
                          (ctx) => GestureDetector(
                            onTap: () {
                              _showSnackbar(
                                "Station : ${station["name"]}\n\n"
                                    "🌫️ AQI : ${station["aqi"]}\n"
                                    "💨 PM2.5 : ${station["PM25"]}\n"
                                    "💨 PM10 : ${station["PM10"]}",
                                // backgroundColor: Color(0xFF4A4949),
                                backgroundColor: Color(0xFFF3F3F3),
                                textColor: Colors.black,
                                actionLabel: 'More Info',
                                fontSize: 16.0,
                                fontFamily: 'NotoSansThai',
                                onAction: () {
                                  print('Action button pressed');
                                },
                              );

                              _zoomToStation(station["position"]);
                            },
                            child: const MyMapMarker(),
                          ),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
          if (_isMessageVisible)
            Positioned(
              top: 50,
              left: 20,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'กำลังกลับสู่ตำแหน่งเดิม',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        'ในอีก $_countdownTime วินาที',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                  onPressed:
                      () => _mapController.move(
                        _mapController.center,
                        _mapController.zoom + 1,
                      ),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'zoomOut',
                  child: const Icon(Icons.remove),
                  onPressed:
                      () => _mapController.move(
                        _mapController.center,
                        _mapController.zoom - 1,
                      ),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'location',
                  onPressed: () => _getUserLocation(true),
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

class MyLocationMarker extends StatelessWidget {
  const MyLocationMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
