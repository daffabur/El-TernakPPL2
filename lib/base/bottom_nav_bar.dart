// lib/base/bottom_nav_bar.dart
import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/account_management.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/cage_management.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Home_Screen/home_screen.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/money_management.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/fluent_mdl2.dart';
import 'package:iconify_flutter/icons/healthicons.dart';
import 'package:iconify_flutter/icons/heroicons_solid.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _selectedIndex = widget.initialIndex;

  final PageStorageBucket _bucket = PageStorageBucket();

  late final List<Widget> _pages = const [
    HomeScreen(key: PageStorageKey('home_screen')),
    MoneyManagement(key: PageStorageKey('money_screen')),
    CageManagement(key: PageStorageKey('cage_screen')),
    Center(key: PageStorageKey('chicken_screen'), child: Text("Chicken")),
    AccountManagement(key: PageStorageKey('account_screen')),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  final Color selectedColor = AppStyles.highlightColor;
  final Color unselectedColor = AppStyles.highlightColor;
  final Color selectedBackgroundColor = const Color(0xFF3E7B27);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: _bucket,
        child: IndexedStack(index: _selectedIndex, children: _pages),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: 8),
        child: BottomBarOnly(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedColor: selectedColor,
          unselectedColor: unselectedColor,
          selectedBackgroundColor: selectedBackgroundColor,
        ),
      ),
    );
  }
}

/// ===== Reusable bottom bar only (tanpa Scaffold) =====
class BottomBarOnly extends StatelessWidget {
  const BottomBarOnly({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.selectedColor,
    this.unselectedColor,
    this.selectedBackgroundColor,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final Color sel = selectedColor ?? AppStyles.highlightColor;
    final Color unsel = unselectedColor ?? AppStyles.highlightColor;
    final Color selBg = selectedBackgroundColor ?? const Color(0xFF3E7B27);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 32),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            MaterialSymbols.home,
            "Home",
            0,
            sel,
            unsel,
            selBg,
          ),
          _buildNavItem(
            context,
            FluentMdl2.money,
            "Money",
            1,
            sel,
            unsel,
            selBg,
          ),
          _buildNavItem(
            context,
            Healthicons.animal_chicken,
            "Cage",
            2,
            sel,
            unsel,
            selBg,
          ),
          _buildNavItem(
            context,
            MaterialSymbols.warehouse_rounded,
            "Chicken",
            3,
            sel,
            unsel,
            selBg,
          ),
          _buildNavItem(
            context,
            HeroiconsSolid.user_group,
            "User",
            4,
            sel,
            unsel,
            selBg,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String iconData,
    String label,
    int index,
    Color selectedColor,
    Color unselectedColor,
    Color selectedBackgroundColor,
  ) {
    final bool isSelected = currentIndex == index;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
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
      ),
    );
  }
}
