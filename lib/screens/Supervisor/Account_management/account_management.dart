import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/models/user_model.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/widgets/Custom_Bottom_Sheets.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/widgets/Custom_Card_Employee.dart';
import 'package:el_ternak_ppl2/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/line_md.dart';
import 'package:collection/collection.dart';

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

  Future<void> _refreshData() async {
    // assign FUTURE BARU agar FutureBuilder re-build dari server
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
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const CustomBottomSheets(mode: BottomSheetMode.add),
      ),
    ).then((result) {
      // ==> pastikan CustomBottomSheets memanggil Navigator.pop(context, true)
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
        title: Text(
          'Manajemen Akun',
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<dynamic>>(
          future: Future.wait([_petinggiFuture, _pegawaiFuture]),
          builder: (context, snapshot) {
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

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('Tidak ada data.'));
            }

            final data = snapshot.data!;
            // Guard jika ukuran future list berubah
            if (data.length < 2) {
              return const Center(child: Text('Data tidak lengkap.'));
            }

            final List<User> petinggi = List<User>.from(data[0] as List);
            final List<User> pegawai = List<User>.from(data[1] as List);

            if (petinggi.isEmpty && pegawai.isEmpty) {
              return const Center(child: Text('Tidak ada data akun.'));
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Petinggi
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                      child: Text(
                        'Petinggi',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildPetinggiList(petinggi),
                    const SizedBox(height: 24),

                    // Pegawai
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Pegawai',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildGroupedPegawaiList(pegawai),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        backgroundColor: AppStyles.primaryColor,
        child: const Iconify(LineMd.account_add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ---------- PETINGGI LIST (horizontal) ----------
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
              // <- Pastikan di CustomCardEmployee memanggil ini setelah delete sukses
              onDataChanged: _refreshData,
            ),
          );
        },
      ),
    );
  }

  // ---------- PEGAWAI LIST (group by kandang) ----------
  Widget _buildGroupedPegawaiList(List<User> pegawai) {
    if (pegawai.isEmpty) {
      return const Text('Tidak ada data pegawai.');
    }

    // Grouping by nama kandang
    final groupedPegawai = groupBy(pegawai, (User user) {
      final nk = user.namaKandang?.trim() ?? '';
      return nk.isEmpty ? 'Pegawai Tanpa Kandang' : nk;
    });

    // "Tanpa Kandang" selalu terakhir
    final sortedEntries = groupedPegawai.entries.toList()
      ..sort((a, b) {
        if (a.key == 'Pegawai Tanpa Kandang') return 1;
        if (b.key == 'Pegawai Tanpa Kandang') return -1;
        return a.key.compareTo(b.key);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedEntries.map((entry) {
        final groupTitle = entry.key;
        final usersInKandang = entry.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                groupTitle,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: groupTitle == 'Pegawai Tanpa Kandang'
                      ? Colors.grey.shade700
                      : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: usersInKandang.length,
                itemBuilder: (context, index) {
                  final user = usersInKandang[index];
                  return CustomCardEmployee(
                    user: user,
                    // <- panggil _refreshData setelah delete/edit dari kartu
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
