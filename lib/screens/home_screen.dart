import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0), // กำหนด margin ระยะห่างจากขอบจอ
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // จัดแนวตั้งให้ตรงกลาง
          crossAxisAlignment: CrossAxisAlignment.center, // จัดแนวนอนให้ตรงกลาง
          children: [
            // กล่องที่ด้านบน
            Container(
              height: (MediaQuery.of(context).size.height + 300) / 3, // ทำให้กล่องบนยาวขึ้น
              width: double.infinity,
              color: Colors.blue,
              child: Center(child: Text("Top Box", style: TextStyle(color: Colors.white))),
            ),
            SizedBox(height: 10), // เว้นระยะห่าง 10 ระหว่างกล่อง

            // กล่องตรงกลาง 3 กล่อง
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // จัดแนวนอนให้ตรงกลาง
              children: [
                Container(
                  height: (MediaQuery.of(context).size.height - 40) / 8, // ทำให้กล่องกลางเล็กลง
                  width: (MediaQuery.of(context).size.width - 40) / 3, // คำนวณขนาดของแต่ละกล่อง
                  color: Colors.red,
                  child: Center(child: Text("Box 1", style: TextStyle(color: Colors.white))),
                ),
                SizedBox(width: 10), // เว้นระยะห่าง 10 ระหว่างกล่อง
                Container(
                  height: (MediaQuery.of(context).size.height - 40) / 8,
                  width: (MediaQuery.of(context).size.width - 40) / 3,
                  color: Colors.green,
                  child: Center(child: Text("Box 2", style: TextStyle(color: Colors.white))),
                ),
                SizedBox(width: 10), // เว้นระยะห่าง 10 ระหว่างกล่อง
                Container(
                  height: (MediaQuery.of(context).size.height - 40) / 8,
                  width: (MediaQuery.of(context).size.width - 40) / 3,
                  color: Colors.orange,
                  child: Center(child: Text("Box 3", style: TextStyle(color: Colors.white))),
                ),
              ],
            ),
            SizedBox(height: 10), // เว้นระยะห่าง 10 ระหว่างกล่อง

            // ข้อความระหว่างกล่อง
            Text(
              "ข้อความระหว่างกล่อง",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10), // เว้นระยะห่าง 10 ระหว่างข้อความและกล่องด้านล่าง

            // กล่องที่ด้านล่าง
            Container(
              height: (MediaQuery.of(context).size.height - 150) / 5,
              width: double.infinity,
              color: Colors.purple,
              child: Center(child: Text("Bottom Box", style: TextStyle(color: Colors.white))),
            ),
          ],
        ),
      ),
    );
  }
}
