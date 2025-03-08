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
              _buildBox(
                screenWidth,
                screenHeight,
                "assets/images/advice-aqi-wallpaper.png",
                context,
                1,
              ),
              const SizedBox(height: 20),
              _buildBox(
                screenWidth,
                screenHeight,
                "assets/images/advice-pm-wallpaper.jpg",
                context,
                2,
              ),
              const SizedBox(height: 20),
              _buildBox(
                screenWidth,
                screenHeight,
                "assets/images/advice-people-wallpaper.jpg",
                context,
                3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBox(
    double screenWidth,
    double screenHeight,
    String imagePath,
    BuildContext context,
    int pageIndex,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              switch (pageIndex) {
                case 1:
                  return TopPage();
                case 2:
                  return MidPage();
                case 3:
                  return BottomPage();
                default:
                  return AdviceScreen();
              }
            },
          ),
        );
      },
      child: Align(
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
      ),
    );
  }
}

class TopPage extends StatelessWidget {
  const TopPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth > 600 ? 1.5 : 1.0;

    return Scaffold(
      appBar: AppBar(title: Text("AQI Information")),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.07,
              left: 16.0,
              right: 16.0,
            ),
            child: Container(
              width: screenWidth * 0.9,
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Station Name",
                    style: TextStyle(
                      fontSize: 24 * scaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("AQI Level", style: TextStyle(fontSize: 18)),
                      Text(
                        "75",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFC0F03),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MidPage extends StatelessWidget {
  const MidPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("แจ้งเตือน")),
      body: Center(
        child: Text(
          "กำลังจะมาในเร็วๆนี้!!",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.normal),
        ),
      ),
    );
  }
}

class BottomPage extends StatelessWidget {
  const BottomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("แจ้งเตือน")),
      body: Center(
        child: Text(
          "กำลังจะมาในเร็วๆนี้!!",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.normal),
        ),
      ),
    );
  }
}
