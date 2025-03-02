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
  }

  @override
  Widget build(BuildContext context) {
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
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 90,
            right: 30,
            child: InkWell(
              onTap: () {
                if (_currentPage == onboardingData.length - 1) {
                  completeOnboarding(context);
                } else {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Ink(
                decoration: BoxDecoration(
                  color: Color(0xFFA45E5E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: Text(
                    _currentPage == onboardingData.length - 1 ? "เข้าใจแล้ว" : "ข้าม",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'NotoSansThai',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                    (index) => buildDot(index, context),
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

  Widget buildDot(int index, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 5),
      height: 12, // ขนาดจุด
      width: 12, // ขนาดจุด
      decoration: BoxDecoration(
        color: _currentPage == index ? Color(0xFFD85E5E) : Colors.grey,
        borderRadius: BorderRadius.circular(6), // ทำให้จุดมีมุมโค้ง
      ),
    );
  }
}

List<Map<String, String>> onboardingData = [
  {
    "image": "assets/images/onboarding_man.png",
    "title": "ตรวจสอบได้ตลอดเวลา 24 ชั่วโมง",
    "description": "Forecast PM2.5 เป็นแอปพลิเคชันดูสภาพอากาศตาม GPS "
        "ที่ตั้งไว้และตามสถานที่ที่ท่านเลือกดูสภาพอากาศ"
  },
  {
    "image": "assets/images/onboarding_thailand_map.png",
    "title": "ตรวจสอบได้ทุกที่",
    "description": "สามารถตรวจสอบสภาพอากาศ ณ ที่ท่านอยู่หรือดูทั่วประเทศไทย"
  },
  {
    "image": "assets/images/onboarding_graph.png",
    "title": "สามารถดูกราฟเปรียบเทียบ",
    "description": "เปรียบเทียบระหว่างค่าความจริงกับค่าที่พยากรณ์ย้อนหลัง 7 วัน"
  },
  {
    "image": "assets/images/onboarding_people.png",
    "title": "คู่มือแนะนำการป้องกัน PM2.5",
    "description": "สามารถแนะนำการรับมือป้องกัน PM2.5 และแนะนำอุปกรณ์ป้องกัน PM2.5 ที่ได้มาตรฐาน"
  }
];

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 400),
          SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontFamily: 'NotoSansThai',
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'NotoSansThai',
            ),
          ),
        ],
      ),
    );
  }
}
