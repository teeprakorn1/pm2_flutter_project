import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/advice_screen.dart';
import 'screens/graph_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ต้องใส่เมื่อใช้ async ใน main

  // **โหลดข้อมูลหรือกำหนดค่าก่อนเริ่มแอป**
  await initializeApp();

  runApp(MyApp());
}

// ฟังก์ชันสำหรับเตรียมการก่อนเริ่มแอป
Future<void> initializeApp() async {
  await Future.delayed(Duration(seconds: 2)); // ตัวอย่าง: หน่วงเวลา 2 วินาที
  print("แอปพร้อมทำงานแล้ว!");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: Colors.grey[100],
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    MapScreen(),
    AdviceScreen(),
    GraphScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined, size: 30), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.south_america, size: 30), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.heart_broken, size: 30), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.auto_graph, size: 30), label: ''),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Color(0xFFD85E5E),
            unselectedItemColor: Color(0x9E9E9EFF),
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            iconSize: 30,
          ),
        ),
      ),
    );
  }
}
