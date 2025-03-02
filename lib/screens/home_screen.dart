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
                  Positioned.fill(
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.blue.withOpacity(0.2),
                        BlendMode.color,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/building-wallpaper.png'),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 25,
                    top: (screenHeight + 280) / 16 * scaleFactor - 40,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 150 * scaleFactor,
                          height: 150 * scaleFactor,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
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
                        Container(
                          width: 120 * scaleFactor,
                          height: 120 * scaleFactor,
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
                            child: SvgPicture.asset('assets/icons/cloud-haze-icon.svg', width: 60 * scaleFactor, height: 60 * scaleFactor,),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 20,
                    top: 10,
                    child: Text(
                      "FORECAST PM2.5",
                      style: TextStyle(
                        fontSize: 16 * scaleFactor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBox("Box 1", scaleFactor),
                  SizedBox(width: 10),
                  _buildBox("Box 2", scaleFactor),
                  SizedBox(width: 10),
                  _buildBox("Box 3", scaleFactor),
                ],
              ),
              SizedBox(height: 30),
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
                      fontSize: 18 * scaleFactor,
                      fontFamily: "NotoSansThai",
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: (screenHeight - 150) / 5 * scaleFactor,
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
                child: Center(
                  child: Text(
                    "Bottom Box",
                    style: TextStyle(color: Colors.black, fontSize: 18 * scaleFactor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBox(String text, double scaleFactor) {
    return Expanded(
      child: Container(
        height: 80 * scaleFactor,
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
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: Colors.black, fontSize: 16 * scaleFactor),
          ),
        ),
      ),
    );
  }
}
