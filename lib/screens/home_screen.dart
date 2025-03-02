import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final Color backgroundColor; // ตัวแปรสีพื้นหลัง

  const HomeScreen({super.key, required this.backgroundColor}); // รับค่า backgroundColor ผ่านคอนสตรัคเตอร์

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // ใช้ตัวแปรนี้ในการตั้งสีพื้นหลัง
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            Container(
              height: (MediaQuery.of(context).size.height + 280) / 3,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue,
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
                child: Text("Top Box", style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: (MediaQuery.of(context).size.height - 100) / 8,
                  width: (MediaQuery.of(context).size.width - 40) / 3,
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
                    child: Text("Box 1", style: TextStyle(color: Colors.black)),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  height: (MediaQuery.of(context).size.height - 100) / 8,
                  width: (MediaQuery.of(context).size.width - 40) / 3,
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
                    child: Text("Box 2", style: TextStyle(color: Colors.black)),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  height: (MediaQuery.of(context).size.height - 100) / 8,
                  width: (MediaQuery.of(context).size.width - 40) / 3,
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
                    child: Text("Box 3", style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 40,vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                "การพยากรณ์ 7วัน ล่วงหน้า",
                style: TextStyle(fontSize: 18,fontFamily: "NotoSansThai", fontWeight: FontWeight.normal),
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: (MediaQuery.of(context).size.height - 150) / 5,
              width: double.infinity,
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
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
