import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constants/strings.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  final Color backgroundColor;
  const HomeScreen({super.key, required this.backgroundColor});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _stations = [];
  List<double> pmValues = [];
  bool isLoading = true;
  String _closestStationName = "-1";
  String stationID = "-1";
  String aqi = "-1";
  String pm25 = "-1";
  String airTemperature = "-1";
  String relativeHumidity = "-1";
  String rainfall = "-1";
  String dateData = "-1";
  String dayData = "-1";
  int aqiValue = -1;
  String pmString = '-1';
  String imagePath = 'assets/images/building-red-wallpaper.png';
  Color backgroundColors = Colors.red;
  LatLng _currentLatLng = LatLng(0, 0);

  Future<void> loadData() async {
    setState(() => isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? std = prefs.getString('stationID');
      String? pd = prefs.getString('page');

      if (pd == "SearchPage" && std != null) {
        stationID = std;
        Map<String, dynamic> stationData = await getStationId(stationID);

        if (stationData['status'] != false) {
          setState(() {
            aqi = stationData["AQILast"]?["AQI"]?["aqi"] ?? "-1";
            pm25 = stationData["AQILast"]?["PM25"]?["value"] ?? "-1";
          });

          Map<String, dynamic> predictionData = await getTopPredictions(
            stationData['areaTH'],
            stationData['areaEN'],
          );

          if (predictionData['status'] != false) {
            setState(() {
              _closestStationName = predictionData['Province_Name'];
              dateData = predictionData['created_at'];
              pmValues = extractPMValues(predictionData);
              checkValuePM();
            });

            Map<String, dynamic> weatherData = await setDistanceWeatherArea(
              double.tryParse(stationData["long"].toString()) ?? 0.0,
              double.tryParse(stationData["lat"].toString()) ?? 0.0,
            );

            if (weatherData['status'] != false) {
              setState(() {
                airTemperature = extractWeatherValue(
                  weatherData['station']['Observation']['AirTemperature'],
                );
                relativeHumidity = extractWeatherValue(
                  weatherData['station']['Observation']['RelativeHumidity'],
                );
                rainfall = extractWeatherValue(
                  weatherData['station']['Observation']['Rainfall'],
                );
                print(
                  'DataTrue: $rainfall and $airTemperature and $relativeHumidity',
                );
                print('PM2.5 Predictions: $pmValues');
                setBackgroundColor();
              });
            } else {
              setState(() => _closestStationName = "-1");
              print('Error: Weather data error - ${weatherData['message']}');
            }
          } else {
            setState(() => _closestStationName = "-1");
            print(
              'Error: Prediction data error - ${predictionData['message']}',
            );
          }
        } else {
          print('Error: Station data error - ${stationData['message']}');
          setState(() => _closestStationName = "-1");
        }
      } else {
        print('StationID: $_currentLatLng');
        Map<String, dynamic> dataAir4thai = await setDistanceAir4thaiArea(
          _currentLatLng.longitude,
          _currentLatLng.latitude,
        );

        if (dataAir4thai['status'] != false) {
          setState(() {
            aqi = dataAir4thai['station']?["AQILast"]?["AQI"]?["aqi"] ?? "-1";
            pm25 =
                dataAir4thai['station']?["AQILast"]?["PM25"]?["value"] ?? "-1";
            print("x1: $aqi");
          });

          Map<String, dynamic> predictionData = await getTopPredictions(
            dataAir4thai['station']?['areaTH'],
            dataAir4thai['station']?['areaEN'],
          );

          if (predictionData['status'] != false) {
            setState(() {
              _closestStationName = predictionData['Province_Name'];
              dateData = predictionData['created_at'];
              pmValues = extractPMValues(predictionData);
              checkValuePM();
            });

            Map<String, dynamic> weatherData = await setDistanceWeatherArea(
              double.tryParse(dataAir4thai['station']!["long"].toString()) ??
                  0.0,
              double.tryParse(dataAir4thai['station']!["lat"].toString()) ??
                  0.0,
            );

            if (weatherData['status'] != false) {
              setState(() {
                airTemperature = extractWeatherValue(
                  weatherData['station']['Observation']['AirTemperature'],
                );
                relativeHumidity = extractWeatherValue(
                  weatherData['station']['Observation']['RelativeHumidity'],
                );
                rainfall = extractWeatherValue(
                  weatherData['station']['Observation']['Rainfall'],
                );
                print(
                  'DataTrue: $rainfall and $airTemperature and $relativeHumidity',
                );
                print('PM2.5 Predictions: $pmValues');
                setBackgroundColor();
              });
            } else {
              setState(() => _closestStationName = "-1");
              print('Error: Weather data error - ${weatherData['message']}');
            }
          } else {
            setState(() => _closestStationName = "-1");
            print(
              'Error: Prediction data error - ${predictionData['message']}',
            );
          }
        } else {
          setState(() => _closestStationName = "-1");
          print('Error: Station data error - ${dataAir4thai['message']}');
        }
      }
    } catch (e) {
      print("Error loading data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void setBackgroundColor() {
    aqiValue = checkValueAqi(int.parse(aqi));
    if (aqiValue == 5) {
      backgroundColors = Colors.red;
      imagePath = "assets/images/building-red-wallpaper.png";
    } else if (aqiValue == 4) {
      backgroundColors = Colors.orange;
      imagePath = "assets/images/building-orange-wallpaper.png";
    } else if (aqiValue == 3) {
      backgroundColors = Colors.yellow;
      imagePath = "assets/images/building-yellow-wallpaper.png";
    } else if (aqiValue == 2) {
      backgroundColors = Colors.green;
      imagePath = "assets/images/building-green-wallpaper.png";
    } else if (aqiValue == 1) {
      backgroundColors = Colors.blue;
      imagePath = "assets/images/building-blue-wallpaper.png";
    }
  }

  int checkValueAqi(int aqis) {
    print("aqis: " + aqis.toString());
    if (aqis >= 201) {
      return 5;
    } else if (aqis >= 101) {
      return 4;
    } else if (aqis >= 51) {
      return 3;
    } else if (aqis >= 26) {
      return 2;
    } else {
      return 1;
    }
  }

  void checkValuePM() {
    if (pmValues[0] >= 75) {
      pmString = "มากกว่า 75.0";
    } else if (pmValues[0] >= 37.5) {
      pmString = "37.6 - 75.0";
    } else if (pmValues[0] >= 25) {
      pmString = "25.1 - 37.5";
    } else if (pmValues[0] >= 15) {
      pmString = "15.1 - 25.0";
    } else {
      pmString = "ต่ำกว่า 15.0";
    }
  }

  List<double> extractPMValues(Map<String, dynamic> data) {
    return [
      data["predicted1day_pm25"] ?? 0.0,
      data["predicted2day_pm25"] ?? 0.0,
      data["predicted3day_pm25"] ?? 0.0,
      data["predicted4day_pm25"] ?? 0.0,
      data["predicted5day_pm25"] ?? 0.0,
      data["predicted6day_pm25"] ?? 0.0,
      data["predicted7day_pm25"] ?? 0.0,
    ].map((e) => e is num ? e.toDouble() : 0.0).toList();
  }

  String extractWeatherValue(dynamic data) {
    if (data != null && data['_'] != null) {
      return double.tryParse(data['_'].toString())?.toString() ?? "-1";
    }
    return "-1";
  }

  Future<Map<String, dynamic>> getStationId(String stationID) async {
    final url = Uri.parse(AppStrings.apiGetAir4thaiStationId);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'stationID': stationID}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('ข้อมูลที่ได้: $data');
        return data;
      } else {
        final errorData = json.decode(response.body);
        print('Error: ${errorData['message']}');
        return {'status': false, 'message': errorData['message']};
      }
    } catch (error) {
      print('Error: $error');
      return {'status': false, 'message': 'An error occurred.'};
    }
  }

  Future<Map<String, dynamic>> getTopPredictions(
    String areaTH,
    String areaEN,
  ) async {
    final url = Uri.parse(AppStrings.apiGetTopPredictions1);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'areaTH': areaTH, 'areaEN': areaEN}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('ข้อมูลที่ได้: $data');
        return data;
      } else {
        final errorData = json.decode(response.body);
        print('Error: ${errorData['message']}');
        return {'status': false, 'message': errorData['message']};
      }
    } catch (error) {
      print('Error: $error');
      return {'status': false, 'message': 'An error occurred.'};
    }
  }

  Future<Map<String, dynamic>> setDistanceAir4thaiArea(
    double myLong,
    double myLat,
  ) async {
    final url = Uri.parse(AppStrings.apiSetDistanceAir4thaiArea);

    try {
      print('ข้อมูลที่ส่งไป: $myLong and $myLat');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mylong': myLong, 'mylat': myLat}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('ข้อมูลที่ได้: $data');
        return data;
      } else {
        final errorData = json.decode(response.body);
        print('Error: ${errorData['message']}');
        return {'status': false, 'message': errorData['message']};
      }
    } catch (error) {
      print('Error: $error');
      return {'status': false, 'message': 'An error occurred.'};
    }
  }

  Future<Map<String, dynamic>> setDistanceWeatherArea(
    double myLong,
    double myLat,
  ) async {
    final url = Uri.parse(AppStrings.apiSetDistanceWeatherArea);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mylong': myLong, 'mylat': myLat}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('ข้อมูลที่ได้: $data');
        return data;
      } else {
        final errorData = json.decode(response.body);
        print('Error: ${errorData['message']}');
        return {'status': false, 'message': errorData['message']};
      }
    } catch (error) {
      print('Error: $error');
      return {'status': false, 'message': 'An error occurred.'};
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await getCurrentLocation();
    await _fetchAQIStations();
    await loadData();
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Error: Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Error: Location permissions are denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Error: Location permissions are permanently denied.');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _currentLatLng = LatLng(position.latitude, position.longitude);
    print('Current Location: $_currentLatLng');
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
                  "stationID": station["stationID"],
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
      }
    } catch (e) {
      print('Error fetching AQI data: $e');
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
      backgroundColor: backgroundColors,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  Stack(
                    children: [
                      SizedBox(height: 20),
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
                          imagePath,
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
                                aqi,
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
                                pmString,
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
                        top:
                            (screenHeight + 140) / 5 * scaleFactor / 2 -
                            30 +
                            10,
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
                                      pm25,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 38 * scaleFactor,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(
                                              0.5,
                                            ),
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
                                              color: Colors.black.withOpacity(
                                                0.5,
                                              ),
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
                      _buildBox("RAIN", "$rainfall%", Icons.cloud, scaleFactor),
                      SizedBox(width: 10),
                      _buildBox(
                        "TEMPERATURE",
                        "$airTemperature °C",
                        Icons.thermostat,
                        scaleFactor,
                      ),
                      SizedBox(width: 10),
                      _buildBox(
                        "Humidity",
                        relativeHumidity,
                        Icons.air,
                        scaleFactor,
                      ),
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
                            dateData,
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
                              double pm =
                                  (pmValues.isNotEmpty &&
                                          index < pmValues.length)
                                      ? pmValues[index]
                                      : 0.0;
                              String day = daysOfWeek[index];
                              String iconPath;

                              if (pm >= 75) {
                                iconPath = 'assets/icons/pm-5-icon.png';
                              } else if (pm >= 37.5) {
                                iconPath = 'assets/icons/pm-3-icon.png';
                              } else if (pm >= 25) {
                                iconPath = 'assets/icons/pm-2-icon.png';
                              } else if (pm >= 15) {
                                iconPath = 'assets/icons/pm-2-icon.png';
                              } else {
                                iconPath = 'assets/icons/pm-1-icon.png';
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                                child: Container(
                                  width: 50 * scaleFactor,
                                  padding: EdgeInsets.symmetric(vertical: 9),
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
                                          fontSize: 14 * scaleFactor,
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
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFFB8383),
                          ),
                          backgroundColor: Colors.white.withOpacity(0.3),
                          strokeWidth: 4.0,
                        ),
                      ),
                      SizedBox(height: 80),
                      Text(
                        "กำลังโหลด...",
                        style: TextStyle(
                          color: Color(0xFFFB8383),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
  final List<Map<String, dynamic>> stations;

  const SearchPage({super.key, required this.stations});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredStations = [];

  @override
  void initState() {
    super.initState();
    _filteredStations = widget.stations;
  }

  void _filterStations(String query) {
    String normalizedQuery = query.trim().toLowerCase();

    setState(() {
      _filteredStations =
          widget.stations.where((station) {
            String nameTH = station["nameTH"].toLowerCase();
            String nameEN = station["nameEN"].toLowerCase();

            return RegExp(
                  normalizedQuery,
                  caseSensitive: false,
                ).hasMatch(nameTH) ||
                RegExp(normalizedQuery, caseSensitive: false).hasMatch(nameEN);
          }).toList();
    });
  }

  Future<void> saveData(String stationID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('stationID');
    prefs.remove('page');
    await prefs.setString('stationID', stationID);
    await prefs.setString('page', "SearchPage");
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
                              onTap: () async {
                                saveData(
                                  _filteredStations[index]["stationID"]
                                      .toString(),
                                );
                                print(
                                  "StationID: ${_filteredStations[index]["stationID"]}",
                                );
                                await Future.delayed(Duration(seconds: 1));
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MainScreen(),
                                  ),
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
