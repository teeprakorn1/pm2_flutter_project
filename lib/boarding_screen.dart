import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class BoardingScreen extends StatefulWidget {
  const BoardingScreen({super.key});

  @override
  _BoardingScreenState createState() => _BoardingScreenState();
}

class _BoardingScreenState extends State<BoardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.toInt() ?? 0;
      });
    });
    removePrefs();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTablet = screenWidth > 600;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: onboardingData.length,
                  itemBuilder: (context, index) => OnboardingPage(
                    image: onboardingData[index]["image"]!,
                    title: onboardingData[index]["title"]!,
                    description: onboardingData[index]["description"]!,
                    isTablet: isTablet,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: isTablet ? 50 : 90,
            right: isTablet ? 50 : 30,
            child: InkWell(
              onTap: () {
                completeOnboarding(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 40 : 30,
                  vertical: isTablet ? 15 : 10,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFA45E5E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _currentPage == onboardingData.length - 1 ? "เข้าใจแล้ว" : "ข้าม",
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    fontFamily: 'NotoSansThai',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: isTablet ? 100 : 80,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                    (index) => buildDot(index, context, isTablet),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('boarding_completed', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  }

  Widget buildDot(int index, BuildContext context, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(right: isTablet ? 8 : 5),
      height: isTablet ? 16 : 12,
      width: isTablet ? 16 : 12,
      decoration: BoxDecoration(
        color: _currentPage == index ? Color(0xFFD85E5E) : Colors.grey,
        borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
      ),
    );
  }
}

Future<void> removePrefs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

List<Map<String, String>> onboardingData = [
  {
    "image": "assets/images/onboarding_man.png",
    "title": "ตรวจสอบได้ตลอดเวลา 24 ชั่วโมง",
    "description": "Forecast PM2.5 เป็นแอปพลิเคชันสำหรับดูสภาพอากาศทุกสถานีตรวจวัดทั่วประเทศ"
        "และสามารถดูค่าพยากรณ์ฝุ่น PM2.5 ล่วงหน้า 7 วัน ได้ทุกจังหวัด อีกทั้งยังสามารถดููจังหวัดที่ใกล้ที่สุด"
        "ตาม GPS ของคุณได้"
  },
  {
    "image": "assets/images/onboarding_thailand_map.png",
    "title": "แผนที่คุณภาพอากาศ",
    "description": "สามารถดูคุณภาพอากาศตามสถานีตรวจวัดทั่วประเทศ ในรูปแบบแผนที่"
  },
  {
    "image": "assets/images/onboarding_graph.png",
    "title": "กราฟเปรียบเทียบ",
    "description": "เปรียบเทียบระหว่างค่าความจริงกับค่าที่พยากรณ์ย้อนหลัง 7 วัน"
  },
  {
    "image": "assets/images/onboarding_people.png",
    "title": "คู่มือแนะนำการป้องกัน PM2.5",
    "description": "ช่วยให้คำแนะนำวิธีการรับมือกับ PM2.5  อย่างถูกต้อง และ แนะนำอุปกรณ์ป้องกัน PM2.5 ที่ได้มาตรฐาน"
  }
];

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final bool isTablet;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    double imageHeight = isTablet ? 450 : 300;
    double titleFontSize = isTablet ? 32 : 24;
    double descFontSize = isTablet ? 22 : 16;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 50 : 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(image, height: imageHeight),
              SizedBox(height: isTablet ? 30 : 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontFamily: 'NotoSansThai',
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isTablet ? 15 : 10),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: descFontSize,
                  fontFamily: 'NotoSansThai',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
