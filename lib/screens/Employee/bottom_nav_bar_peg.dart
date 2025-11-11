// lib/screens/Employee/bottom_nav_bar_peg.dart
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/healthicons.dart';
import 'package:provider/provider.dart'; // <-- 1. TAMBAHKAN IMPORT PROVIDER
import 'package:el_ternak_ppl2/services/auth_service.dart';
// Tab pages
import 'package:el_ternak_ppl2/screens/Employee/Home_Screen/home_screen.dart';
import 'package:el_ternak_ppl2/screens/Employee/Cage_management/cage_management_peg.dart';
class BottomNavBarPeg extends StatefulWidget {
  const BottomNavBarPeg({super.key});

  @override
  State<BottomNavBarPeg> createState() => _BottomNavBarPegState();
}

class _BottomNavBarPegState extends State<BottomNavBarPeg> {
  int _selectedIndex = 0;

  // Navigator keys per tab
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
      return false; // cegah keluar app, pop di tab dulu
    }
    // Kalau di root route tab & bukan tab Home, balik ke Home dulu
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return false;
    }
    return true; // izinkan sistem keluar app
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

  // Navigator per tab
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

  // ---------- UI ----------
  final Color _selectedIconColor = const Color(0xFF3E7B27);
  final Color _unselectedIconColor = const Color(0xFF3E7B27);
  final Color _selectedBg = const Color(0xFF3E7B27);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        // IndexedStack supaya state tiap tab terjaga
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildTabNavigator(key: _homeNavKey, root: HomeScreen(onLogout: () => authService.logout(),)),
            _buildTabNavigator(
              key: _cageNavKey,
              root: const CageManagementPeg(),
            ),
          ],
        ),

        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.only(bottom: 8),
          child: Container(
            height: 70,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 32),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(MaterialSymbols.home, "Home", 0),
                _buildNavItem(
                  Healthicons.animal_chicken,
                  "Kandang",
                  1,
                  alignRight: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    String icon,
    String label,
    int index, {
    bool alignRight = false,
  }) {
    final bool isSelected = _selectedIndex == index;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onItemTapped(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          margin: EdgeInsets.only(
            left: alignRight ? 0 : 4,
            right: alignRight ? 4 : 0,
          ),
          decoration: isSelected
              ? BoxDecoration(
                  color: _selectedBg.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                )
              : const BoxDecoration(),
          child: Iconify(
            icon,
            size: 28,
            color: isSelected ? _selectedIconColor : _unselectedIconColor,
          ),
        ),
      ),
    );
  }
}
