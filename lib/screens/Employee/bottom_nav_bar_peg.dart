// lib/base/bottom_nav_bar_peg.dart
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/healthicons.dart';

// Tab konten
import 'package:el_ternak_ppl2/screens/Employee/Home_Screen/home_screen.dart';
import 'package:el_ternak_ppl2/screens/Employee/Cage_management/cage_management_peg.dart';

/// Bottom navbar versi Pegawai:
/// - Kiri: Home
/// - Kanan: Kandang (ikon ayam)
class BottomNavBarPeg extends StatefulWidget {
  const BottomNavBarPeg({super.key});

  @override
  State<BottomNavBarPeg> createState() => _BottomNavBarPegState();
}

class _BottomNavBarPegState extends State<BottomNavBarPeg> {
  int _selectedIndex = 0;

  // Menjaga state/scroll per tab
  final PageStorageBucket _bucket = PageStorageBucket();

  // Halaman untuk 2 tab
  late final List<Widget> _pages = const [
    HomeScreen(key: PageStorageKey('emp_home_tab')),
    CageManagementPeg(key: PageStorageKey('emp_cage_tab')),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  // Warna
  final Color _selectedIconColor = const Color(0xFF3E7B27);
  final Color _unselectedIconColor = const Color(0xFF3E7B27);
  final Color _selectedBg = const Color(0xFF3E7B27);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack menjaga state setiap tab
      body: PageStorage(
        bucket: _bucket,
        child: IndexedStack(index: _selectedIndex, children: _pages),
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: 8),
        child: Container(
          height: 70, // fixed height supaya tidak “melar”
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 32),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
          // Home kiri — Ayam kanan
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
                  color: _selectedBg.withOpacity(0.10),
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
