import 'dart:convert';
import 'dart:io';
import 'package:el_ternak_ppl2/screens/Supervisor/Storage_Management/models/item_stock_model.dart';
import 'package:http/http.dart' as http;

import 'package:el_ternak_ppl2/services/auth_service.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/models/user_model.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/models/transaction_model.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/models/summary_model.dart';
import 'package:intl/intl.dart';

class NoTransactionFoundException implements Exception {
  final String message;
  NoTransactionFoundException(this.message);

  @override
  String toString() => message;
}
class ApiService {
  static const String _baseUrl =
      'http://ec2-54-169-33-190.ap-southeast-1.compute.amazonaws.com:80/api/';
  final AuthService _authService = AuthService();

  // ================== Helpers ==================

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Token not found. Please log in again.');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': token,
    };
  }

  T _safeDecode<T>(String source) {
    final decoded = jsonDecode(source);
    if (decoded is T) return decoded;
    throw Exception('Unexpected response shape');
  }

  List<Map<String, dynamic>> _extractDataList(dynamic body) {
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      }
      return const <Map<String, dynamic>>[];
    }
    if (body is List) {
      return body.whereType<Map<String, dynamic>>().toList();
    }
    return const <Map<String, dynamic>>[];
  }

  // ================== Auth ==================

  Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('${_baseUrl}auth/login'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = _safeDecode(response.body);
      final String? token = responseBody['data']?['token'];
      if (token != null && token.isNotEmpty) {
        return token;
      } else {
        throw Exception('Respons login tidak valid: token tidak ditemukan.');
      }
    } else {
        String serverMessage = 'Terjadi kesalahan. Coba lagi nanti';
        try{
          final Map<String, dynamic> responseBody = _safeDecode(response.body);
          serverMessage = responseBody['message'] ?? 'Pesan error tidak ditemukan di server.';
        }catch (_) {
          print("Gagal membaca body JSON dari respons error. Status: ${response.statusCode}");
        }
        switch (response.statusCode) {
          case 401:
          case 400:
            throw Exception(
                serverMessage.contains('Pesan error tidak ditemukan')
                    ? 'Username atau password salah.'
                    : serverMessage);
          case 403:
            throw Exception('Anda tidak memiliki hak akses untuk masuk.');
          case 404:
            throw Exception(
                'Endpoint login tidak ditemukan. Hubungi developer.');
          case 500:
            throw Exception(
                'Server sedang mengalami masalah. Coba lagi beberapa saat.');

          default:
            throw Exception(
                'Gagal login dengan status: ${response.statusCode}');
        }
    }
  }

  // ================== Manage Account ==================

  Future<List<User>> getAllUsers() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${_baseUrl}manage/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Model kamu sendiri: apiResponseFromJson -> jangan diubah
        final apiResponse = apiResponseFromJson(response.body);
        if (apiResponse.success) {
          return apiResponse.data;
        } else {
          throw Exception(apiResponse.message ?? 'Failed to load users');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi anda habis, tolong login kembali');
      } else {
        throw Exception('Gagal memuat data. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  Future<List<User>> getPegawaiOnly() async {
    try {
      final headers = await _getAuthHeaders();
      final res = await http.get(
        Uri.parse('${_baseUrl}manage/pegawai'),
        headers: headers,
      );

      if (res.statusCode != 200) {
        if (res.statusCode == 401) {
          throw Exception('Sesi anda habis, tolong login kembali');
        }
        throw Exception('Gagal memuat pegawai. Status: ${res.statusCode}');
      }

      final body = jsonDecode(res.body);
      final list = _extractDataList(body);
      return list.map<User>((j) => User.fromJson(j)).toList();
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<List<User>> getActivePegawaiOnly() async {
    final list = await getPegawaiOnly();
    return list.where((u) => (u.isActive ?? true) == true).toList();
  }

  Future<void> createUser(Map<String, dynamic> userData) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('${_baseUrl}manage/create'),
        headers: headers,
        body: jsonEncode(userData),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        try {
          final Map<String, dynamic> responseBody = _safeDecode(response.body);
          final errorMessage = responseBody['message'] ?? 'Gagal membuat user.';
          throw Exception(errorMessage);
        } catch (_) {
          throw Exception('Gagal membuat user. Status: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  // PUT /manage/edit
  Future<void> updateUser(
    String originalUsername, // tetap dipertahankan agar kompatibel
    Map<String, dynamic> updateData,
  ) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('${_baseUrl}manage/edit'),
        headers: headers,
        body: jsonEncode(updateData),
      );

      if (response.statusCode != 200) {
        try {
          final Map<String, dynamic> responseBody = _safeDecode(response.body);
          final errorMessage =
              responseBody['message'] ?? 'Gagal memperbarui user.';
          throw Exception(errorMessage);
        } catch (_) {
          throw Exception(
            'Gagal memperbarui user. Status: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  Future<void> deleteUser(String username) async {
    try {
      final url = Uri.parse('${_baseUrl}manage/delete');
      final body = jsonEncode({'username': username});

      final request = http.Request('DELETE', url);
      request.headers.addAll(await _getAuthHeaders());
      request.body = body;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        try {
          final Map<String, dynamic> responseBody = _safeDecode(response.body);
          final errorMessage =
              responseBody['message'] ?? 'Gagal menghapus user.';
          throw Exception(errorMessage);
        } catch (_) {
          throw Exception('Gagal menghapus. Status: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  // ================== Transaksi ==================

  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${_baseUrl}transaksi/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = _safeDecode(response.body);
        final List<dynamic> dataList = jsonResponse['data'] ?? [];
        return dataList
            .whereType<Map<String, dynamic>>()
            .map((json) => TransactionModel.fromJson(json))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception(
          'Error 401: Unauthorized. Token tidak valid atau kedaluwarsa.',
        );
      } else {
        throw Exception(
          'Gagal memuat transaksi. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server saat mengambil transaksi: $e');
    }
  }

  Future<List<TransactionModel>> getFilteredTransactions({
    String? periode,
    DateTime? tanggal,
  }) async {
    if ((periode == null || periode.isEmpty) && tanggal == null) {
      return getAllTransactions();
    }
    final endpoint = '${_baseUrl}transaksi/filter';
    final Map<String, String> queryParams = {};
    if (periode != null && periode.isNotEmpty) {
      queryParams['periode'] = periode;
      print("Memanggil API filter dengan periode: $periode");
    }else if (tanggal != null) {
      // --- PERBAIKAN UTAMA DI SINI ---
      // Backend mewajibkan parameter 'periode' jika 'tanggal' ada.
      queryParams['periode'] = 'per_hari';

      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      queryParams['tanggal'] = formatter.format(tanggal);

      // Perbaiki juga pesan print agar akurat
      print("Memanggil API filter dengan periode: ${queryParams['periode']} & tanggal: ${queryParams['tanggal']}");
      // --- AKHIR PERBAIKAN ---

    } else {
      return getAllTransactions();
    }

    // Bangun URI lengkap dengan query parameters.
    final uri = Uri.parse(endpoint).replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        uri,
        headers: await _getAuthHeaders(),
      );

      print("Status Code Filter: ${response.statusCode}");
      print("URL Filter yang dipanggil: $uri");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = _safeDecode(response.body);
        final List<dynamic> dataList = jsonResponse['data'] ?? [];
        return dataList
            .whereType<Map<String, dynamic>>()
            .map((json) => TransactionModel.fromJson(json))
            .toList();
      } else if (response.statusCode == 400) {
        // Jika status 400, lempar exception khusus yang sudah kita buat.
        throw NoTransactionFoundException(
            'Tidak ada transaksi yang ditemukan untuk filter yang dipilih.');
      }
      else {
        throw Exception(
          'Gagal memuat transaksi terfilter. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is NoTransactionFoundException) {
        throw e;
      }
      throw Exception('Gagal terhubung ke server saat filtering: $e');
    }
  }

  Future<double> getTotalAmounByType(String type) async {
    if (type != 'pemasukan' && type != 'pengeluaran') {
      throw Exception('Jenis transaksi tidak valid: $type');
    }
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${_baseUrl}transaksi/jenis/$type'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = _safeDecode(response.body);
        if (responseBody['success'] == true && responseBody['data'] != null) {
          double totalAmount = 0.0;
          for (final t in (responseBody['data'] as List)) {
            final n = (t as Map<String, dynamic>)['Total'] ?? 0;
            totalAmount += (n as num).toDouble();
          }
          return totalAmount;
        } else {
          throw Exception('Gagal memuat data: ${responseBody['message']}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi anda habis, silakan login kembali.');
      } else {
        throw Exception('Gagal memuat data. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  Future<void> createTransaction(
      Map<String, dynamic> transactionData,
      String? imagePath,
      ) async {
    // ---- BAGIAN DEBUGGING ----
    print("=============================================");
    print("🚀 [ApiService] Mencoba membuat transaksi...");
    print("SENDING DATA: " + jsonEncode(transactionData));
    if (imagePath != null) {
      print("WITH IMAGE AT: $imagePath");
    }
    print("=============================================");
    // ---- AKHIR BAGIAN DEBUGGING ----

    try {
      final url = Uri.parse('${_baseUrl}transaksi/create');
      final request = http.MultipartRequest('POST', url);

      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }
      // Pastikan format token konsisten
      request.headers['Authorization'] = token.startsWith('Bearer ') ? token : 'Bearer $token';

      // fields
      transactionData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // file (opsional)
      if (imagePath != null) {
        final file = File(imagePath);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath('bukti_transaksi', imagePath),
          );
        } else {
          print("⚠️ WARNING: Path gambar ada, tetapi file tidak ditemukan di '$imagePath'. Mengirim tanpa gambar.");
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Selalu log respons dari server
      print("📦 [ApiService] RESPONSE RECEIVED:");
      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY: ${response.body}");
      print("=============================================");

      // ---- PERBAIKAN ERROR HANDLING ----
      if (response.statusCode != 201 && response.statusCode != 200) {

        // --- PERBAIKAN UTAMA DI SINI ---
        // Deklarasikan serverMessage di luar blok try-catch
        String serverMessage = 'Gagal membuat transaksi.';
        // --- AKHIR PERBAIKAN UTAMA ---

        try {
          final Map<String, dynamic> responseBody = _safeDecode(response.body);
          // Isi nilainya di dalam try
          serverMessage = responseBody['message'] ?? 'Tidak ada pesan error spesifik dari server.';
        } catch (_) {
          // Jika parsing gagal, serverMessage akan tetap menggunakan nilai default-nya.
        }

        // Buat pesan error yang lebih detail, menyertakan data yang dikirim
        final String detailedError =
            "Server Error: $serverMessage (Status: ${response.statusCode})\n"
            "Data yang Dikirim: ${jsonEncode(transactionData)}";

        // Lempar exception dengan pesan yang detail
        throw Exception(detailedError);
      }
      // ---- AKHIR PERBAIKAN ERROR HANDLING ----

    } on Exception catch (e) {
      // Tangkap exception yang sudah kita buat atau exception lain, lalu lempar kembali
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    } catch (e) {
      // Tangkap error lain yang mungkin terjadi (misal: koneksi, dll)
      throw Exception("Terjadi error tak terduga: $e");
    }
  }

  Future<SummaryModel> getSummary() async {
    print("===== MEMULAI GET SUMMARY =====");
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${_baseUrl}transaksi/summary'),
        headers: headers,
      );

      print("Status Code Summary: ${response.statusCode}");
      print("Response Body Summary: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = _safeDecode(response.body);

        if (responseBody.containsKey('data') &&
            responseBody['data'] is Map<String, dynamic>) {
          print("Parsing summary dari dalam object 'data'.");
          return SummaryModel.fromJson(
            responseBody['data'] as Map<String, dynamic>,
          );
        } else {
          print("Parsing summary dari root object.");
          return SummaryModel.fromJson(responseBody);
        }
      } else {
        throw Exception(
          'Gagal memuat summary. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server saat mengambil summary: $e');
    }
  }

  Future<void> deleteTransaction(int transactionId) async {
    print("Mencoba menghapus transaksi dengan ID: $transactionId");

    try {
      final response = await http.delete(
        Uri.parse('${_baseUrl}transaksi/$transactionId'),
        headers: await _getAuthHeaders(),
      );

      print("Status Code Delete: ${response.statusCode}");
      print("Response Body Delete: ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Gagal menghapus transaksi. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server saat menghapus: $e');
    }
  }

  Future<TransactionModel> getTransactionById(int transactionId) async {
    print("Mengambil detail untuk transaksi ID: $transactionId");

    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}transaksi/$transactionId'),
        headers: await _getAuthHeaders(),
      );

      print("Status Code Detail: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = _safeDecode(response.body);
        return TransactionModel.fromJson(
          (jsonResponse['data'] as Map<String, dynamic>),
        );
      } else {
        throw Exception(
          'Gagal memuat detail transaksi. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server saat mengambil detail: $e');
    }
  }

  Future<List<ItemStockModel>> getPakanByType(String itemType) async{
    if (itemType.isEmpty) {
      throw Exception('Jenis item tidak valid: $itemType');
    }
    final validItemType = itemType.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    if (validItemType.isEmpty) {
      throw Exception('Jenis item tidak valid.');
    }

    try{
      final response = await http.get(
        Uri.parse('${_baseUrl}/pakan'),
        headers: await _getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data
            .map((json) => ItemStockModel.fromJson(json))
            .where((item) => item.nama.trim().isNotEmpty)
            .toList();
      } else if (response.statusCode == 401) {
          throw Exception('Sesi anda habis, silakan login kembali.');
        }
        else {
          throw Exception(
            'Gagal memuat data $validItemType. Status: ${response.statusCode}',
          );
        }
      } catch (e) {
      throw Exception('Gagal terhubung ke server saat mengambil $validItemType: $e');
    }
  }
  Future<List<ItemStockModel>> getOvkByType(String itemType) async{
    if (itemType.isEmpty) {
      throw Exception('Jenis item tidak valid: $itemType');
    }
    final validItemType = itemType.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    if (validItemType.isEmpty) {
      throw Exception('Jenis item tidak valid.');
    }

    try{
      final response = await http.get(
        Uri.parse('${_baseUrl}/ovk'),
        headers: await _getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data
            .map((json) => ItemStockModel.fromJson(json))
            .where((item) => item.nama.trim().isNotEmpty)
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Sesi anda habis, silakan login kembali.');
      }
      else {
        throw Exception(
          'Gagal memuat data $validItemType. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server saat mengambil $validItemType: $e');
    }
  }
}
