import 'package:flutter/material.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/widgets/Info_Card.dart';
import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

class CustomDetailCage extends StatefulWidget {
  const CustomDetailCage({super.key});

  @override
  State<CustomDetailCage> createState() => _CustomDetailCageState();
}

class _CustomDetailCageState extends State<CustomDetailCage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true ,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                  color: AppStyles.IconCageCardColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8)
              ),
              child: Iconify(
                MaterialSymbols.house_siding,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "Kandang 1",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppStyles.primaryColor
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child:Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/images/10.png'),
                      ),
                      const SizedBox(width: 10),
                         Text(
                          'Ehsan Bin Mail',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    'Aktif',
                    style: GoogleFonts.poppins
                      (color: Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Populasi
            Container(
              width: double.infinity, //
              decoration: BoxDecoration(
                color: AppStyles.highlightColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Opacity(
                      opacity: 1,
                      child: ClipRRect(
                        child: SvgPicture.asset(
                            "assets/images/ic_populasi.svg",
                            width: MediaQuery.of(context).size.width * 0.3,
                            fit: BoxFit.fitHeight,
                            height: MediaQuery.of(context).size.width * 0.3
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 20, bottom: 20, top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Populasi",
                          style:GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "7.800",
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w600
                          ),
                        ),
                        Text(
                          "Kematian",
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        const Text(
                          "200",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            // Sekam dan Solar Digunakan
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppStyles.highlightColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -10,
                          bottom: -10,
                          child: Opacity(
                            opacity: 1,
                            child: ClipRRect(
                              child: SvgPicture.asset(
                                  "assets/images/ic_sekam.svg",
                                  width: MediaQuery.of(context).size.width * 0.15,
                                  fit: BoxFit.fitHeight,
                                  height: MediaQuery.of(context).size.width * 0.15
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          child:  Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Sekam Digunakan",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "1 Kg",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 15), // jarak antar card
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppStyles.highlightColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 0,
                          bottom: 5,
                          child: Opacity(
                            opacity: 1,
                            child: ClipRRect(
                              child: SvgPicture.asset(
                                  "assets/images/ic_solar.svg",
                                  width: MediaQuery.of(context).size.width * 0.2,
                                  fit: BoxFit.fitHeight,
                                  height: MediaQuery.of(context).size.width * 0.2
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Solar Digunakan",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "20 L",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            //Pakan
            Container(
              width: double.infinity, //
              decoration: BoxDecoration(
                color: AppStyles.highlightColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [

                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Opacity(
                      opacity: 1,
                      child: ClipRRect(
                        child: SvgPicture.asset(
                            "assets/images/ic_pakan.svg",
                            width: MediaQuery.of(context).size.width * 0.25,
                            fit: BoxFit.fitHeight,
                            height: MediaQuery.of(context).size.width * 0.25
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Konsumsi Pakan",
                          style:GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "100 Kg",
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w600
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 15),
            //Obat
            Container(
              width: double.infinity, //
              decoration: BoxDecoration(
                color: AppStyles.highlightColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [

                  Positioned(
                    right: 0,
                    bottom: 10,
                    child: Opacity(
                      opacity: 1,
                      child: ClipRRect(
                        child: SvgPicture.asset(
                            "assets/images/ic_obat.svg",
                            width: MediaQuery.of(context).size.width * 0.2,
                            fit: BoxFit.fitHeight,
                            height: MediaQuery.of(context).size.width * 0.2
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Obat",
                          style:GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "20 L",
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w600
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
