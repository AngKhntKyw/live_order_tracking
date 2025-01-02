import 'package:flutter/material.dart';
import 'package:live_order_tracking/driver/driver_page.dart';
import 'package:live_order_tracking/ober/ober_page.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final screens = [
    // const MyHomePage(),
    // const MapPage(),
    const OberPage(),
    const DriverPage(),
  ];
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        currentIndex: currentIndex,
        enableFeedback: true,
        // fixedColor: Colors.purple,
        elevation: 0,
        items: const [
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.home_outlined),
          //   activeIcon: Icon(Icons.home),
          //   label: "Home",
          // ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.location_on_outlined),
          //   activeIcon: Icon(Icons.location_on),
          //   label: "Map",
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_taxi_outlined),
            activeIcon: Icon(Icons.local_taxi),
            label: "Ober",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.drive_eta_outlined),
            activeIcon: Icon(Icons.drive_eta),
            label: "Driver",
          ),
        ],
      ),
    );
  }
}
