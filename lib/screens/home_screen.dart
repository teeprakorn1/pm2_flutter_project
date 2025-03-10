import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  final Color backgroundColor;
  const HomeScreen({super.key, required this.backgroundColor});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _stations = [];
  String _closestStationName = "กรุงเทพมหานคร";
  LatLng _currentLatLng = LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchAQIStations();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentLatLng = LatLng(
        position.latitude,
        position.longitude,
      );
    });
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
          _stations =
              (data['stations'] as List).map((station) {
                var lat = double.parse(station["lat"]);
                var long = double.parse(station["long"]);
                return {
                  "nameTH": station["nameTH"],
                  "nameEN": station["nameEN"],
                  "areaTH": station["areaTH"],
                  "areaEN": station["areaEN"],
                  "position": LatLng(lat, long),
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
        _findClosestStation();
      }
    } catch (e) {
      print('Error fetching AQI data: $e');
    }
  }

  // Haversine formula to calculate distance between two lat/lon points
  double _calculateDistance(LatLng position1, LatLng position2) {
    const R = 6371; // Radius of Earth in km
    double dLat =
        (position2.latitude - position1.latitude) *
            (pi / 180); // Convert to radians
    double dLon =
        (position2.longitude - position1.longitude) *
            (pi / 180); // Convert to radians

    double a =
        (0.5 - (cos(dLat) / 2)) +
            cos(position1.latitude * (pi / 180)) *
                cos(position2.latitude * (pi / 180)) *
                (1 - cos(dLon)) /
                2;

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Distance in km
  }

  void _findClosestStation() {
    double closestDistance = double.infinity;
    Map<String, dynamic>? closestStation;

    for (var station in _stations) {
      LatLng stationLatLng = station["position"];
      double distance = _calculateDistance(_currentLatLng, stationLatLng);

      if (distance < closestDistance) {
        closestDistance = distance;
        closestStation = station;
      }
    }

    if (closestStation != null) {
      setState(() {
        _closestStationName = _getLastWord(closestStation?['areaTH']);
      });
    }
  }

  String _getLastWord(String area) {
    List<String> words = area.split(" ");
    return words.isNotEmpty ? words.last : "";
  }

  String _parseValue(dynamic value) {
    if (value == null || value == "-1") {
      return "\"N/A\"";
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth > 600 ? 1.5 : 1.0;

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Stack(
                children: [
                  Container(
                    height: (screenHeight + 280) / 3 * scaleFactor,
                    width: screenWidth * 0.9,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/images/building-wallpaper.png',
                      width: screenWidth * 0.9,
                      height: (screenHeight + 320) / 3 * scaleFactor,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    left: 25,
                    top: (screenHeight + 280) / 16 * scaleFactor - 40,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120 * scaleFactor,
                          height: 120 * scaleFactor,
                          decoration: BoxDecoration(
                            color: Color(0x99E0E0E0),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 90 * scaleFactor,
                              height: 90 * scaleFactor,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/icons/cloud-haze-icon.svg',
                                  width: 60 * scaleFactor,
                                  height: 60 * scaleFactor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 60,
                    top: (screenHeight + 180) / 10 * scaleFactor + 55,
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '29.6',
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 24 * scaleFactor,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  offset: Offset(2.0, 2.0),
                                  blurRadius: 5.0,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 0),
                          Text(
                            'AQI',
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 24 * scaleFactor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  offset: Offset(2.0, 2.0),
                                  blurRadius: 5.0,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    left: 0,
                    top: (screenHeight + 280) / 6 * scaleFactor + 55,
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '75.1 ขึ้นไป',
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 44 * scaleFactor,
                              fontWeight: FontWeight.bold,
                              fontFamily: "NotoSansThai",
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  offset: Offset(2.0, 2.0),
                                  blurRadius: 5.0,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 0),
                          Text(
                            'PM2.5',
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 16 * scaleFactor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  offset: Offset(2.0, 2.0),
                                  blurRadius: 5.0,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'ช่วงค่าพยากรณ์ในอีก 1 วันข้างหน้า',
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 14 * scaleFactor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NotoSansThai',
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  offset: Offset(2.0, 2.0),
                                  blurRadius: 5.0,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.42,
                    top: (screenHeight + 140) / 5 * scaleFactor / 2 - 30 + 10,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                    SearchPage(stations: _stations),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 24 * scaleFactor,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  _closestStationName,
                                  style: TextStyle(
                                    fontSize: 20 * scaleFactor,
                                    fontFamily: 'NotoSansThai',
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          width: screenWidth * 0.42,
                          padding: EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            color: Color(0x80EBE6D9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 40.0,
                                  top: 2.0,
                                  bottom: 2,
                                ),
                                child: Text(
                                  '36.8',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 38 * scaleFactor,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.5),
                                        offset: Offset(2.0, 2.0),
                                        blurRadius: 5.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 20.0,
                                  bottom: 2.0,
                                ),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    'PM2.5',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14 * scaleFactor,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.5),
                                          offset: Offset(2.0, 2.0),
                                          blurRadius: 5.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 20,
                    top: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "FORECAST PM2.5",
                          style: TextStyle(
                            fontSize: 16 * scaleFactor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(2.0, 2.0),
                                blurRadius: 5.0,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBox("RAIN", "35%", Icons.cloud, scaleFactor),
                  SizedBox(width: 10),
                  _buildBox(
                    "TEMPERATURE",
                    "39 °C",
                    Icons.thermostat,
                    scaleFactor,
                  ),
                  SizedBox(width: 10),
                  _buildBox("Humidity", "29.6", Icons.air, scaleFactor),
                ],
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                width: screenWidth * 0.55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "การพยากรณ์ 7วัน ล่วงหน้า",
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      fontSize: 16 * scaleFactor,
                      fontFamily: "NotoSansThai",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: (screenHeight - 150) / 4 * scaleFactor,
                width: screenWidth * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                        "12 December 2025",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14 * scaleFactor,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Inter",
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(7, (index) {
                          List<String> daysOfWeek = [
                            'SUN',
                            'MON',
                            'TUE',
                            'WED',
                            'THU',
                            'FRI',
                            'SAT',
                          ];
                          List<double> pmValues = [
                            10.2,
                            21.6,
                            35.8,
                            64.1,
                            77.8,
                            79.3,
                            80.9,
                          ];
                          String day = daysOfWeek[index];
                          double pm = pmValues[index];
                          String iconPath;
                          if (pm >= 75) {
                            iconPath = 'assets/icons/pm-5-icon.png';
                          } else if (pm >= 37.5) {
                            iconPath = 'assets/icons/pm-3-icon.png';
                          } else if (pm >= 25) {
                            iconPath = 'assets/icons/pm-2-icon.png';
                          } else if (pm >= 15) {
                            iconPath = 'assets/icons/pm-2-icon.png';
                          } else if (pm >= 0) {
                            iconPath = 'assets/icons/pm-1-icon.png';
                          } else {
                            iconPath = 'assets/icons/pm-1-icon.png';
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Container(
                              width: 50 * scaleFactor,
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    day,
                                    style: TextStyle(
                                      color: Color(0xFF4A4949),
                                      fontSize: 16 * scaleFactor,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Inter",
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Image.asset(
                                    iconPath,
                                    width: 40 * scaleFactor,
                                    height: 40 * scaleFactor,
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    pm.toStringAsFixed(1),
                                    style: TextStyle(
                                      color: Color(0xFF4A4949),
                                      fontSize: 16 * scaleFactor,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Inter",
                                    ),
                                  ),
                                  SizedBox(height: 1),
                                  Text(
                                    "PM2.5",
                                    style: TextStyle(
                                      color: Color(0xFF4A4949),
                                      fontSize: 10 * scaleFactor,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Inter",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBox(
      String title,
      String subtitle,
      IconData icon,
      double scaleFactor,
      ) {
    return Expanded(
      child: Container(
        height: 90 * scaleFactor,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 10),
                Icon(icon, size: 30 * scaleFactor, color: Color(0x66292928)),
                SizedBox(width: 5),
                Text(
                  title,
                  style: TextStyle(
                    color: Color(0xFF303030),
                    fontSize: 8 * scaleFactor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 30 * scaleFactor,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
                color: Color(0xFF303030),
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: Offset(0.2, 0.5),
                    blurRadius: 5.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  final List<Map<String, dynamic>>
  stations;

  const SearchPage({
    super.key,
    required this.stations,
  });

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredStations = [];

  @override
  void initState() {
    super.initState();
    _filteredStations =
        widget
            .stations;
  }

  void _filterStations(String query) {
    setState(() {
      _filteredStations =
          widget.stations
              .where(
                (station) =>
            station["nameTH"].contains(query) ||
                station["nameEN"].contains(query),
          )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final scaleFactor = screenWidth > 600 ? 1.5 : 1.0;

    return Scaffold(
      appBar: AppBar(title: const Text("เลือกสถานี"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "ค่าความเข้มของ PM 2.5",
                style: TextStyle(
                  fontSize: 24 * scaleFactor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansThai',
                  color: Colors.black,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.6),
                      offset: Offset(0, 1.0),
                      blurRadius: 5.0,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            FractionallySizedBox(
              widthFactor: 1.0,
              child: TextField(
                controller: _searchController,
                onChanged: _filterStations,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: "ค้นหาสถานี...",
                  hintStyle: TextStyle(fontFamily: "NotoSansThai"),
                  suffixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child:
              _filteredStations.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "ไม่พบสถานี",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _filteredStations.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.location_on,
                        color: Color(0xFFD85E5E),
                      ),
                      title: Text(
                        _filteredStations[index]["areaTH"],
                        style: TextStyle(fontSize: 18),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        print(
                          "เลือกสถานี: ${_filteredStations[index]["areaTH"]}",
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
