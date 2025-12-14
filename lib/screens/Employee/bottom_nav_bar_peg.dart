// lib/screens/Employee/bottom_nav_bar_peg.dart
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/healthicons.dart';
import 'package:provider/provider.dart';

import 'package:el_ternak_ppl2/services/auth_service.dart';
import 'package:el_ternak_ppl2/screens/Employee/Home_Screen/home_screen.dart';
import 'package:el_ternak_ppl2/screens/Employee/Cage_management/cage_management_peg.dart';

class BottomNavBarPeg extends StatefulWidget {
  const BottomNavBarPeg({super.key});

  @override
  State<BottomNavBarPeg> createState() => _BottomNavBarPegState();
}

class _BottomNavBarPegState extends State<BottomNavBarPeg> {
  int _selectedIndex = 0;

  final _homeNavKey = GlobalKey<NavigatorState>();
  final _cageNavKey = GlobalKey<NavigatorState>();
  late final List<GlobalKey<NavigatorState>> _navKeys;

  @override
  void initState() {
    super.initState();
    _navKeys = [_homeNavKey, _cageNavKey];
  }

  Future<bool> _onWillPop() async {
    final currentNav = _navKeys[_selectedIndex].currentState!;
    if (currentNav.canPop()) {
      currentNav.pop();
      return false;
    }

    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return false;
    }

    return true;
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      final nav = _navKeys[index].currentState!;
      while (nav.canPop()) {
        nav.pop();
      }
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  Widget _buildTabNavigator({
    required GlobalKey<NavigatorState> key,
    required Widget root,
  }) {
    return Navigator(
      key: key,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (_) => root, settings: settings);
      },
    );
  }

  final Color _primaryColor = const Color(0xFF3E7B27);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildTabNavigator(
              key: _homeNavKey,
              root: HomeScreen(onLogout: () => authService.logout()),
            ),
            _buildTabNavigator(
              key: _cageNavKey,
              root: const CageManagementPeg(),
            ),
          ],
        ),

        // ===== BOTTOM NAVBAR =====
        bottomNavigationBar: SafeArea(
          child: Container(
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(
                  icon: MaterialSymbols.home,
                  label: "Beranda",
                  index: 0,
                ),
                _buildNavItem(
                  icon: Healthicons.animal_chicken,
                  label: "Kandang",
                  index: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== NAV ITEM (TEXT SELALU MUNCUL) =====
  Widget _buildNavItem({
    required String icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? _primaryColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Iconify(icon, size: 26, color: _primaryColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
