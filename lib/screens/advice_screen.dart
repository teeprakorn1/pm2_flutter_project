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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth > 600 ? 1.5 : 1.0;

    return Scaffold(
      appBar: AppBar(title: const Text("AQI Information")),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: screenHeight * 0.03,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildInfoCard(screenWidth, scaleFactor),
            const SizedBox(height: 20),
            _buildReferenceText(scaleFactor),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(double screenWidth, double scaleFactor) {
    final List<Map<String, dynamic>> aqiLevels = [
      {
        "range": "0 - 25",
        "description": "ระดับคุณภาพอากาศดีเยี่ยม",
        "color": const Color(0xFF00CCFF),
      },
      {
        "range": "26 - 50",
        "description": "ระดับคุณภาพอากาศดี",
        "color": const Color(0xFF43E736),
      },
      {
        "range": "51 - 100",
        "description": "ระดับคุณภาพอากาศปานกลาง",
        "color": const Color(0xFFEAEB5D),
      },
      {
        "range": "101 - 200",
        "description": "ระดับคุณภาพอากาศเริ่มมีผลกระทบต่อสุขภาพ",
        "color": const Color(0xFFFAA604),
      },
      {
        "range": "200 ขึ้นไป",
        "description": "ระดับคุณภาพอากาศมีผลกระทบต่อสุขภาพ",
        "color": const Color(0xFFFC0F03),
      },
    ];

    return Container(
      width: screenWidth,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children:
            aqiLevels
                .map(
                  (level) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _buildBox(
                      level["range"],
                      level["description"],
                      level["color"],
                      screenWidth,
                      scaleFactor,
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildBox(
    String value,
    String detail,
    Color color,
    double screenWidth,
    double scaleFactor,
  ) {
    return Container(
      width: screenWidth * (screenWidth > 600 ? 0.4 : 0.75),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 20 * scaleFactor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: (screenWidth > 600 ? 40 : 30) * scaleFactor,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(2, 2),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            detail,
            style: TextStyle(
              color: Colors.black,
              fontSize: (screenWidth > 600 ? 18 : 15) * scaleFactor,
              fontWeight: FontWeight.normal,
              fontFamily: 'NotoSansThai',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceText(double scaleFactor) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Text(
          "อ้างอิงข้อมูลจาก กองจัดการคุณภาพอากาศและเสียง กรมควบคุมมลพิษ",
          style: TextStyle(
            fontFamily: "NotoSansThai",
            fontSize: 12 * scaleFactor,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
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
