import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // เพิ่มการ import
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/advice_screen.dart';
import 'screens/graph_screen.dart';
import 'boarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await initializeApp();

  bool showBoarding = await shouldShowBoarding();
  runApp(MyApp(showBoarding: showBoarding));
}

Future<bool> shouldShowBoarding() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('boarding_completed') ?? true;
}

Future<void> initializeApp() async {
  await Future.delayed(Duration(seconds: 2));
  print("App is ready!");
}

class MyApp extends StatelessWidget {
  final bool showBoarding;
  const MyApp({super.key, required this.showBoarding});

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
      home: showBoarding ? BoardingScreen() : MainScreen(),
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
    HomeScreen(backgroundColor: Color(0xFFFB8383)),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(1)),
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
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined, size: 30), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.south_america, size: 30), label: ''),
              BottomNavigationBarItem(icon: SvgPicture.asset('assets/icons/heart-icon.svg', height: 25, width: 25, color: _selectedIndex == 2 ? Color(0xFFD85E5E) : Colors.grey,), label: '',),
              BottomNavigationBarItem(icon: Icon(Icons.auto_graph, size: 30), label: ''),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Color(0xFFD85E5E),
            unselectedItemColor: Color(0xFF9E9E9E),
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
