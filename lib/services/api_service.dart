import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/models/summary_model.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/models/transaction_model.dart';
import 'package:el_ternak_ppl2/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/models/user_model.dart';

class ApiService {
  static const String _baseUrl = 'http://ec2-54-169-33-190.ap-southeast-1.compute.amazonaws.com:80/api/';
  final AuthService _authService = AuthService();

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

  Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('${_baseUrl}auth/login'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final String? token = responseBody['data']?['token'];
      if (token != null && token.isNotEmpty) {
        // print('Login successful, token received.');
        return token;
      } else {
        throw Exception('Respons login tidak valid: token tidak ditemukan.');
      }
    } else {
      try {
        final responseBody = jsonDecode(response.body);
        final errorMessage =
            responseBody['message'] ?? 'Username atau password salah.';
        throw Exception(errorMessage);
      } catch (_) {
        throw Exception('Gagal login. Status: ${response.statusCode}');
      }
    }
  }
  Future<List<User>> getAllUsers() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${_baseUrl}manage/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
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

  // =========================================================
  // MANAGE ACCOUNT: Get pegawai only
  // GET /manage/pegawai
  // (dipakai utk dropdown Penanggung Jawab)
  // =========================================================
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
      final data = (body is Map<String, dynamic>) ? body['data'] : body;

      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map<User>((j) => User.fromJson(j))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Opsional: hanya pegawai aktif (kalau model User punya isActive/is_active)
  Future<List<User>> getActivePegawaiOnly() async {
    final list = await getPegawaiOnly();
    // Sesuaikan properti boolean aktif di model User kamu
    return list.where((u) {
      final v = (u.isActive ?? u.isActive ?? true);
      return v == true;
    }).toList();
  }

  // =========================================================
  // MANAGE ACCOUNT: Create user
  // POST /manage/create
  // =========================================================
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
          final responseBody = jsonDecode(response.body);
          final errorMessage = responseBody['message'] ?? 'Gagal membuat user.';
          throw Exception(errorMessage);
        } catch (_) {
          throw Exception('Gagal membuat user. Status: ${response.statusCode}');
        }
      }
      // print('User berhasil dibuat: ${response.body}');
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  // =========================================================
  // MANAGE ACCOUNT: Update user
  // PUT /manage/edit
  // =========================================================
  Future<void> updateUser(
    String originalUsername,
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
          final responseBody = jsonDecode(response.body);
          final errorMessage =
              responseBody['message'] ?? 'Gagal memperbarui user.';
          throw Exception(errorMessage);
        } catch (_) {
          throw Exception(
            'Gagal memperbarui user. Status: ${response.statusCode}',
          );
        }
      }
      // print('User "$originalUsername" berhasil diperbarui: ${response.body}');
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  // =========================================================
  // MANAGE ACCOUNT: Delete user
  // DELETE /manage/delete (body: { username })
  // =========================================================
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
          final responseBody = jsonDecode(response.body);
          final errorMessage =
              responseBody['message'] ?? 'Gagal menghapus user.';
          throw Exception(errorMessage);
        } catch (_) {
          throw Exception('Gagal menghapus. Status: ${response.statusCode}');
        }
      }
      // print('User "$username" berhasil dihapus.');
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  // Fungsi untuk mengambil seluruh transaksi
  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${_baseUrl}transaksi/'),
        headers: headers, // Gunakan helper header yang sama
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> dataList = jsonResponse['data'];
        return dataList.map((json) => TransactionModel.fromJson(json)).toList();

      } else if (response.statusCode == 401) {
        throw Exception('Error 401: Unauthorized. Token tidak valid atau kedaluwarsa.');
      } else {
        throw Exception('Gagal memuat transaksi. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server saat mengambil transaksi: $e');
    }
  }

  // Fungsi untuk mengambil transaksi berdasarkan periode
  Future<List<TransactionModel>> getFilteredTransactions(String periode) async {
    // Validasi untuk memastikan periode tidak kosong
    if (periode.isEmpty) {
      // Jika periode kosong, kembalikan daftar kosong atau panggil getAllTransactions
      return getAllTransactions();
    }

    print("Memanggil API filter dengan periode: $periode"); // Untuk debugging

    try {
      final response = await http.get(

        Uri.parse('${_baseUrl}transaksi/filter?periode=$periode'),
        headers: await _getAuthHeaders(),
      );

      print("Status Code Filter: ${response.statusCode}"); // Untuk debugging

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> dataList = jsonResponse['data'];
        return dataList.map((json) => TransactionModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat transaksi terfilter. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server saat filtering: $e');
    }
  }

  // Fungsi untuk mengambil total pengeluaran dan pemasukan
  Future<double> getTotalAmounByType(String type) async{
    if (type != 'pemasukan' && type != 'pengeluaran') {
      throw Exception('Jenis transaksi tidak valid: $type');
    }
    try{
      final headers = await _getAuthHeaders();
      final response = await http.get (
        Uri.parse('${_baseUrl}transaksi/jenis/$type'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true && responseBody['data'] != null) {
          double totalAmount = 0.0;
          for (var transaction in responseBody['data']) {
            // Tambahkan nilai 'Total' ke totalAmount
            totalAmount += (transaction['Total'] ?? 0).toDouble();
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
    }catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
    }

  // Fungsi untuk membuat transaksi baru
  Future<void> createTransaction(Map<String, dynamic> transactionData, String? imagePath) async {
    print("Mencoba membuat transaksi dengan data: $transactionData");
    if (imagePath != null) {
      print("Dengan path gambar: $imagePath");
    }

    try {
      final url = Uri.parse('${_baseUrl}transaksi/create');
      var request = http.MultipartRequest('POST', url);

      // Ambil token dari AuthService
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token not found. Please log in again.');
      }
      request.headers['Authorization'] = token;

      // Tambahkan semua data teks dari Map
      transactionData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Tambahkan file gambar HANYA jika path-nya ada (tidak null)
      if (imagePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'bukti_transaksi', // Nama field ini harus sama dengan yang diharapkan backend
            imagePath,
          ),
        );
      }

      // Kirim request dan tunggu response
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("Status Code Create Transaction: ${response.statusCode}");
      print("Response Body: ${response.body}");

      // Cek jika request tidak berhasil
      if (response.statusCode != 201 && response.statusCode != 200) {
        try {
          final responseBody = jsonDecode(response.body);
          final errorMessage = responseBody['message'] ?? 'Gagal membuat transaksi.';
          throw Exception(errorMessage);
        } catch (_) {
          throw Exception('Gagal membuat transaksi. Status: ${response.statusCode}');
        }
      }
      print('Transaksi berhasil dibuat: ${response.body}');
    } catch (e) {
      // Lempar kembali error dengan format yang bersih
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  Future<SummaryModel> getSummary() async {
    print("===== MEMULAI GET SUMMARY ====="); // Untuk debugging
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${_baseUrl}transaksi/summary'),
        headers: headers,
      );

      print("Status Code Summary: ${response.statusCode}"); // Untuk debugging
      print("Response Body Summary: ${response.body}");   // Untuk debugging

      if (response.statusCode == 200) {
        // 1. Decode seluruh response body terlebih dahulu
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        // 2. Cek apakah ada wrapper 'data' dan 'data' tersebut adalah Map
        if (responseBody.containsKey('data') && responseBody['data'] is Map<String, dynamic>) {
          print("Parsing summary dari dalam object 'data'.");
          return SummaryModel.fromJson(responseBody['data']);
        } else {
          print("Parsing summary dari root object.");
          return SummaryModel.fromJson(responseBody);
        }
      } else {
        throw Exception('Gagal memuat summary. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server saat mengambil summary: $e');
    }
  }

  // Fungsi untuk delete transaction
  Future<void> deleteTransaction(int transactionId) async {
    print("Mencoba menghapus transaksi dengan ID: $transactionId"); // Untuk debugging

    try {
      final response = await http.delete(
        Uri.parse('${_baseUrl}transaksi/$transactionId'),
        headers: await _getAuthHeaders(),
      );

      print("Status Code Delete: ${response.statusCode}");
      print("Response Body Delete: ${response.body}");

      // Status 200 (OK) atau 204 (No Content) adalah sukses untuk DELETE
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Gagal menghapus transaksi. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server saat menghapus: $e');
    }
  }

  //fungsi untuk mendapatkan detail transaksi
  Future<TransactionModel> getTransactionById(int transactionId) async {
    print("Mengambil detail untuk transaksi ID: $transactionId"); // Debugging

    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}transaksi/$transactionId'),
        headers: await _getAuthHeaders(),
      );

      print("Status Code Detail: ${response.statusCode}"); // Debugging

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Data transaksi ada di dalam key 'data'
        return TransactionModel.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Gagal memuat detail transaksi. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server saat mengambil detail: $e');
    }
  }

  }

