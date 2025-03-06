import 'package:flutter/material.dart';

class AdviceScreen extends StatelessWidget {
  const AdviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth > 600 ? 1.5 : 1.0;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: screenHeight * 0.07,
            left: 16.0,
            right: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                width: screenWidth * 0.5,
                child: Center(
                  child: Text(
                    "Information",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFFFFFFFF),
                      fontSize: 34 * scaleFactor,
                      fontFamily: "Inter",
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.75),
                          offset: const Offset(3.0, 2.0),
                          blurRadius: 20.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildBox(screenWidth, screenHeight, "assets/images/advice-aqi-wallpaper.png"),
              const SizedBox(height: 20),
              _buildBox(screenWidth, screenHeight, "assets/images/advice-aqi-wallpaper.png"),
              const SizedBox(height: 20),
              _buildBox(screenWidth, screenHeight, "assets/images/advice-aqi-wallpaper.png"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBox(double screenWidth, double screenHeight, String imagePath) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: screenWidth * 0.9,
        height: screenHeight * 0.21,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
