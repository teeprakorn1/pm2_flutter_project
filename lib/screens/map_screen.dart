import 'dart:async';
import 'package:pm2_flutter_project/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:intl/intl.dart';
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
      AppStrings.apiGetAir4thai,
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _stations =
              (data['stations'] as List).map((station) {
                return {
                  "nameTH": station["nameTH"],
                  "nameEN": station["nameEN"],
                  "areaTH": station["areaTH"],
                  "areaEN": station["areaEN"],
                  "position": LatLng(
                    double.parse(station["lat"]),
                    double.parse(station["long"]),
                  ),
                  "date": _parseValue(station["AQILast"]?["date"]),
                  "time": _parseValue(station["AQILast"]?["time"]),
                  "aqi": _parseValue(station["AQILast"]?["AQI"]?["aqi"]),
                  "PM25": _parseValue(station["AQILast"]?["PM25"]?["value"]),
                  "PM10": _parseValue(station["AQILast"]?["PM10"]?["value"]),
                  "O3": _parseValue(station["AQILast"]?["O3"]?["value"]),
                  "CO": _parseValue(station["AQILast"]?["CO"]?["value"]),
                  "NO2": _parseValue(station["AQILast"]?["NO2"]?["value"]),
                  "SO2": _parseValue(station["AQILast"]?["SO2"]?["value"]),
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

  void showCustomDialog(BuildContext context, Map<String, dynamic> station) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: DefaultTextStyle(
              style: TextStyle(fontFamily: 'NotoSansThai', color: Colors.black),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station["nameTH"],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    station["nameEN"],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("📍 ${station["areaTH"]}"),
                  Text("📍 ${station["areaEN"]}"),
                  SizedBox(height: 10),
                  Text(
                    "🌍 พิกัด: ${station['position'].latitude}   ${station['position'].longitude}",
                  ),
                  SizedBox(height: 10),
                  Divider(),
                  Text("📊 ข้อมูลคุณภาพอากาศล่าสุด:"),
                  Text(
                    "🕒 วันที่  ${DateFormat('dd-MM-yyyy').format(DateTime.parse(station["date"]))}  เวลา ${station["time"]}",
                  ),
                  Text("💨 AQI:  ${station["aqi"]}"),
                  Text("💨 PM2.5:  ${station["PM25"]}"),
                  Text("💨 PM10:  ${station["PM10"]}"),
                  Text("💨 O3:  ${station["O3"]}"),
                  Text("💨 CO:  ${station["CO"]}"),
                  Text("💨 NO2:  ${station["NO2"]}"),
                  Text("💨 SO2:  ${station["SO2"]}"),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE85555),
                        foregroundColor: Color(0xFFFFFFFF),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        shadowColor: Colors.black.withOpacity(0.3),
                        elevation: 5,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: Color(0xFFFFFFFF),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "ย้อนกลับ",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: "NotoSansThai",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
      action:
          actionLabel.isNotEmpty
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
                                "Station : ${station["nameTH"]}\n\n"
                                "🌫️ AQI : ${station["aqi"]}\n"
                                "💨 PM2.5 : ${station["PM25"]}\n"
                                "💨 PM10 : ${station["PM10"]}\n",
                                backgroundColor: Color(0xFFF3F3F3),
                                textColor: Colors.black,
                                actionLabel: 'MORE INFO',
                                fontSize: 16.0,
                                fontFamily: 'NotoSansThai',
                                onAction: () {
                                  showCustomDialog(context, station);
                                },
                              );
                              _zoomToStation(station["position"]);
                            },
                            child: MyMapMarker(station: station),
                          ),
                    );
                  }),
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
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'NotoSansThai',
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'ในอีก $_countdownTime วินาที',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'NotoSansThai',
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
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem('🔵 ดีเยี่ยม', Colors.blue),
                  _buildLegendItem('🟢 ดี', Colors.green),
                  _buildLegendItem('🟡 ปานกลาง', Colors.yellow),
                  _buildLegendItem('🟠 แย่', Colors.orange),
                  _buildLegendItem('🔴 อันตราย', Colors.red),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'NotoSansThai',
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(1, 1),
          ),
        ],
      ),
    );
  }
}

class MyMapMarker extends StatefulWidget {
  final Map<String, dynamic> station;

  const MyMapMarker({super.key, required this.station});

  @override
  _MyMapMarkerState createState() => _MyMapMarkerState();
}

class _MyMapMarkerState extends State<MyMapMarker> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color getAqiColor(int aqi) {
    if (aqi > 75) {
      return Color(0xFFFC0F03);
    } else if (aqi > 37.5) {
      return Color(0xFFFAA604);
    } else if (aqi > 25) {
      return Color(0xFFEAEB5D);
    } else if (aqi > 15) {
      return Color(0xFF43E736);
    } else if (aqi > 0) {
      return Color(0xFF00CCFF);
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    int aqi = int.tryParse(widget.station["aqi"].toString()) ?? 0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: getAqiColor(aqi).withOpacity(0.3),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF2E2E2E).withOpacity(0.2),
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: getAqiColor(aqi),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF2E2E2E).withOpacity(0.3),
                      offset: Offset(2, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: Color(0xFF005B78),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
