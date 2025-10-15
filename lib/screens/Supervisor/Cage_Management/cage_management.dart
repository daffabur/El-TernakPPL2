// lib/screens/Supervisor/Cage_Management/cage_management.dart
import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/models/cage_model.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/widgets/Custom_Bottom_Sheets.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/widgets/Custom_Card_Cage.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/widgets/Custom_Detail_Cage.dart';
import 'package:el_ternak_ppl2/services/cage_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';

class CageManagement extends StatefulWidget {
  const CageManagement({super.key});

  @override
  State<CageManagement> createState() => _CageManagementState();
}

class _CageManagementState extends State<CageManagement> {
  final CageService _service = CageService();

  List<Cage> _items = <Cage>[];
  bool _loading = true;

  /// Override PIC lokal (jaga-jaga kalau GET BE belum kirim PIC).
  final Map<int, String> _picOverrides = {};

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    try {
      final data = await _service.getAll();
      if (!mounted) return;
      setState(() {
        _items = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _items = [];
        _loading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat kandang: $e')));
    }
  }

  Future<void> _showAddSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const CustomBottomSheets(mode: CageSheetMode.add),
      ),
    );

    if (!mounted || result == null) return;

    try {
      // kirim apa adanya; CageService.create() sudah mapping ke format BE
      await _service.create(result);
      await _fetchAll();

      // Simpan PIC override (kalau BE belum mengembalikan PIC di GET)
      final name = (result['name'] as String?)?.trim();
      final cap =
          int.tryParse('${result['capacity'] ?? result['kapasitas'] ?? 0}') ??
          0;
      final pic = (result['pic'] as String?)?.trim();
      if ((name ?? '').isNotEmpty && (pic ?? '').isNotEmpty) {
        final idx = _items.indexWhere(
          (c) => c.name.trim() == name && c.capacity == cap,
        );
        if (idx != -1) {
          _picOverrides[_items[idx].id] = pic!;
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kandang berhasil ditambahkan')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menambah kandang: $e')));
    }
  }

  Future<void> _showEditSheet(Cage cage) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CustomBottomSheets(mode: CageSheetMode.edit, initial: cage),
      ),
    );

    if (!mounted || result == null) return;

    try {
      // Persist ke DB (PATCH/PUT di CageService)
      await _service.updateById(cage.id, result);
      await _fetchAll();

      // simpan override PIC untuk tampilan detail (jika ada)
      final newPic = (result['pic'] as String?)?.trim();
      if ((newPic ?? '').isNotEmpty) {
        _picOverrides[cage.id] = newPic!;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kandang berhasil diperbarui')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memperbarui kandang: $e')));
    }
  }

  Future<void> _goToDetail(Cage cage) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CustomDetailCage(cage: cage, overridePic: _picOverrides[cage.id]),
      ),
    );

    // Jika dari detail ada penghapusan
    final deleted = (result == true) || (result == 'deleted');
    if (deleted) {
      await _fetchAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kandang "${cage.name}" berhasil dihapus')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchAll,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 60.0),
          children: [
            Text(
              "Informasi Kandang",
              style: GoogleFonts.poppins(
                color: AppStyles.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  "Belum ada data kandang.",
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              )
            else
              Column(
                children: _items
                    .map(
                      (cage) => CustomCardCage(
                        cage: cage,
                        onTap: () => _goToDetail(cage),
                        onEdit: () => _showEditSheet(cage),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        backgroundColor: AppStyles.highlightColor,
        child: const Iconify(MaterialSymbols.add_rounded, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
