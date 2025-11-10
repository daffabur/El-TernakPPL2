import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/models/user_model.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/widgets/Custom_Bottom_Sheets.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/widgets/Custom_Card_Employee.dart';
import 'package:el_ternak_ppl2/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/line_md.dart';
import 'package:collection/collection.dart'; // <-- 1. TAMBAHKAN IMPORT INI

class AccountManagement extends StatefulWidget {
  const AccountManagement({super.key});

  @override
  State<AccountManagement> createState() => _AccountManagementState();
}

class _AccountManagementState extends State<AccountManagement> {
  final ApiService apiService = ApiService();
  late Future<List<User>> _petinggiFuture;
  late Future<List<User>> _pegawaiFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _petinggiFuture = apiService.getPetinggi();
      _pegawaiFuture = apiService.getPegawai();
    });
  }

  void _showAddSheet() {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding:
        EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const CustomBottomSheets(mode: BottomSheetMode.add),
      ),
    ).then((result) {
      if (result == true) {
        _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Daftar akun telah diperbarui.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manajemen Akun',
            style: GoogleFonts.poppins(
                fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: Future.wait([_petinggiFuture, _pegawaiFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Gagal memuat data: ${snapshot.error}'),
              ),
            );
          }

          final List<User> petinggi = snapshot.data![0];
          final List<User> pegawai = snapshot.data![1];

          if (petinggi.isEmpty && pegawai.isEmpty) {
            return const Center(child: Text('Tidak ada data akun.'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SEKSI PETINGGI ---
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                    child: Text('Petinggi',
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  _buildPetinggiList(petinggi),

                  const SizedBox(height: 24),

                  // --- SEKSI PEGAWAI (JUDUL UTAMA) ---
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text('Pegawai',
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  // --- DAFTAR PEGAWAI YANG SUDAH DI-FILTER ---
                  _buildGroupedPegawaiList(pegawai),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        backgroundColor: AppStyles.primaryColor,
        child: const Iconify(LineMd.account_add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildPetinggiList(List<User> petinggi) {
    if (petinggi.isEmpty) {
      return const Text('Tidak ada data petinggi.');
    }
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: petinggi.length,
        itemBuilder: (context, index) {
          final user = petinggi[index];
          return SizedBox(
            width: 250,
            child: CustomCardEmployee(
              user: user,
              onDataChanged: _refreshData,
            ),
          );
        },
      ),
    );
  }

  // --- 2. GANTI FUNGSI LAMA DENGAN FUNGSI BARU INI ---
  Widget _buildGroupedPegawaiList(List<User> pegawai) {
    if (pegawai.isEmpty) {
      return const Text('Tidak ada data pegawai.');
    }

    // Kelompokkan pegawai berdasarkan kandang_id
    final groupedPegawai = groupBy(pegawai, (User user) => user.kandangId);

    // --- PERBAIKAN: Urutkan grup agar "null" selalu di akhir ---
    final sortedEntries = groupedPegawai.entries.toList()
      ..sort((a, b) {
        if (a.key == null) return 1; // Pindahkan null ke akhir
        if (b.key == null) return -1; // Pindahkan null ke akhir
        return a.key!.compareTo(b.key!); // Urutkan sisanya berdasarkan ID
      });

    // Bangun UI berdasarkan grup yang sudah diurutkan
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedEntries.map((entry) {
        final kandangId = entry.key;
        final usersInKandang = entry.value;

        // --- PERBAIKAN: Tentukan nama grup secara dinamis ---
        final String groupTitle =
        kandangId == null ? 'Pegawai Tanpa Kandang' : 'Kandang $kandangId';

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sub-judul untuk setiap kandang
              Text(
                groupTitle, // Gunakan judul yang sudah dinamis
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kandangId == null ? Colors.grey.shade700 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              // ListView untuk pegawai di grup ini
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: usersInKandang.length,
                itemBuilder: (context, index) {
                  final user = usersInKandang[index];
                  return CustomCardEmployee(
                    user: user,
                    onDataChanged: _refreshData,
                  );
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
