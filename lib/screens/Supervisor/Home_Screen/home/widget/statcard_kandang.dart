import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StatCardKandang extends StatelessWidget {
  const StatCardKandang({
    super.key,
    required this.title,
    required this.value,
    required this.kandangNames,
    required this.selectedIndex,
    required this.onChangeIndex,
    this.trailingIcon,
  });

  final String title;
  final num value;
  final List<String> kandangNames;
  final int selectedIndex;
  final ValueChanged<int> onChangeIndex;
  final IconData? trailingIcon;

  String _fmt(num n) => NumberFormat.decimalPattern('id_ID').format(n);

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF2F6F51);

    return Container(
      height: 125,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (trailingIcon != null)
            Positioned(
              right: -8,
              bottom: -8,
              child: Icon(
                trailingIcon,
                size: 90,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ====== Title ======
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                // ====== DROPDOWN FULL WIDTH ======
                SizedBox(
                  width: double.infinity,
                  child: _MiniDropdownChip(
                    items: kandangNames,
                    selectedIndex: selectedIndex,
                    onSelected: onChangeIndex,
                  ),
                ),

                const Spacer(),

                // ====== Nilai angka besar ======
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _fmt(value),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniDropdownChip extends StatelessWidget {
  const _MiniDropdownChip({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final String label = (selectedIndex >= 0 && selectedIndex < items.length)
        ? items[selectedIndex]
        : 'Kandang';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTapDown: (details) async {
          final selected = await showMenu<int>(
            context: context,
            position: RelativeRect.fromLTRB(
              details.globalPosition.dx,
              details.globalPosition.dy,
              details.globalPosition.dx,
              details.globalPosition.dy,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            items: [
              for (int i = 0; i < items.length; i++)
                PopupMenuItem<int>(
                  value: i,
                  height: 40,
                  child: SizedBox(
                    width: 220, // <-- LEBAR POPUP DIPERBESAR
                    child: Text(
                      items[i],
                      maxLines: 2, // <-- BOLEH 2 BARIS
                      softWrap: true,
                      overflow: TextOverflow.clip, // <-- TANPA ELLIPSIS
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                  ),
                ),
            ],
          );
          if (selected != null && selected != selectedIndex) {
            onSelected(selected);
          }
        },
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 26,
            maxHeight: 40, // ruang 2 baris kalau perlu
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.20),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24, width: 0.8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.clip,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
