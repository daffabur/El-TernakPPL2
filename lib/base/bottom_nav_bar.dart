import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/account_management.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Home_Screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/fa6_solid.dart';
import 'package:iconify_flutter/icons/fluent_mdl2.dart';
import 'package:iconify_flutter/icons/healthicons.dart';
import 'package:iconify_flutter/icons/heroicons_solid.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  final appScreen = [
    Center(child: HomeScreen()),
    Center(child: Text("Money")),
    Center(child: Text("Food")),
    Center(child: Text("Chicken")),
    AccountManagement(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  final Color selectedColor = AppStyles.highlightColor;
  final Color unselectedColor = AppStyles.highlightColor;
  final Color selectedBackgroundColor = const Color(0xFF3E7B27);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: appScreen[_selectedIndex],

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
            _buildNavItem(FluentMdl2.money, "Money", 1),
            _buildNavItem(Fa6Solid.plate_wheat, "Food", 2),
            _buildNavItem(Healthicons.animal_chicken, "Chicken", 3),
            _buildNavItem(HeroiconsSolid.user_group, "User", 4),
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