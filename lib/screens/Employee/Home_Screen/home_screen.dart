import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/fa6_solid.dart';
import 'package:iconify_flutter/icons/healthicons.dart';
import 'package:iconify_flutter/icons/heroicons_solid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> appScreens = [
    const Center(child: Text("Home Pegawai")),
    const Center(child: Text("Pakan")),
    const Center(child: Text("Ternak")),
    const Center(child: Text("Keuangan")),
    const Center(child: Text("Profil")),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final Color selectedColor = const Color(0xFF3E7B27);
  final Color unselectedColor = Colors.grey;
  final Color selectedBackgroundColor = const Color(0xFF3E7B27);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: appScreens[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(MaterialSymbols.home, "Home", 0),
            _buildNavItem(Fa6Solid.plate_wheat, "Pakan", 1),
            _buildNavItem(Healthicons.animal_chicken, "Ternak", 2),
            _buildNavItem(MaterialSymbols.attach_money, "Keuangan", 3),
            _buildNavItem(HeroiconsSolid.user, "Profil", 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String iconData, String label, int index) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(12.0),
        decoration: isSelected
            ? BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: selectedBackgroundColor.withOpacity(0.1),
        )
            : const BoxDecoration(),
        child: Iconify(
          iconData,
          color: isSelected ? selectedColor : unselectedColor,
          size: 28,
        ),
      ),
    );
  }
}


