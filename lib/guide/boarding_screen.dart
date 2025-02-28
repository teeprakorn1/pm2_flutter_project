import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  List<Map<String, String>> onboardingData = [
    {
      "image": "assets/onboarding1.png",
      "title": "ยินดีต้อนรับ!",
      "description": "แอปของเราจะช่วยให้คุณทำสิ่งต่างๆ ได้ง่ายขึ้น"
    },
    {
      "image": "assets/onboarding2.png",
      "title": "ฟีเจอร์สุดเจ๋ง",
      "description": "เรามีฟีเจอร์มากมายให้คุณใช้งาน"
    },
    {
      "image": "assets/onboarding3.png",
      "title": "ใช้งานง่าย",
      "description": "ดีไซน์ที่เรียบง่าย ใช้งานได้สะดวก"
    },
    {
      "image": "assets/onboarding4.png",
      "title": "เริ่มต้นเลย!",
      "description": "กดปุ่มด้านล่างเพื่อเข้าสู่แอปของเรา"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingData.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) => OnboardingPage(
                image: onboardingData[index]["image"]!,
                title: onboardingData[index]["title"]!,
                description: onboardingData[index]["description"]!,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              onboardingData.length,
                  (index) => buildDot(index, context),
            ),
          ),
          SizedBox(height: 20),
          _currentPage == onboardingData.length - 1
              ? ElevatedButton(
            onPressed: () {
              // ไปยังหน้าแรกของแอป
            },
            child: Text("เริ่มต้นใช้งาน"),
          )
              : TextButton(
            onPressed: () {
              _pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            },
            child: Text("ถัดไป"),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 5),
      height: 10,
      width: _currentPage == index ? 20 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.blue : Colors.grey,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnboardingPage({super.key, required this.image, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(image, height: 250),
        SizedBox(height: 20),
        Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(description, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
