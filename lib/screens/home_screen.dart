import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatelessWidget {
  final Color backgroundColor;
  const HomeScreen({super.key, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth > 600 ? 1.5 : 1.0;

    return Scaffold(
      backgroundColor: backgroundColor,
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
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 24 * scaleFactor,
                            ),
                            SizedBox(width: 5),
                            Text(
                              "กรุงเทพมหานคร",
                              style: TextStyle(
                                fontSize: 20 * scaleFactor,
                                fontFamily: 'NotoSansThai',
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
                          ],
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
                  _buildBox("TEMPERATURE", "39 °C", Icons.thermostat, scaleFactor,),
                  SizedBox(width: 10),
                  _buildBox("AQI", "29.6", Icons.air, scaleFactor),
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
                          List<String> daysOfWeek = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
                          List<double> pmValues = [10.2, 21.6, 35.8, 64.1, 77.8, 79.3, 80.9];
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
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
