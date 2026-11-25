import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

const String baseUrl = "https://saarthi-t64v.onrender.com/api";

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    // Automatically attaches the JWT token to every request if the user is logged in
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt');
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
    ));
  }

  // --- 1. LOGIN ---
  Future<bool> login(String phone, String password, String role) async {
    try {
      final res = await _dio.post('/auth/login', data: {
        'phone': phone,
        'password': password,
        'role': role // Now sending the role (user/admin)
      });
      // Save the token to local secure storage AND the role for auto-login routing
      await _storage.write(key: 'jwt', value: res.data['token']);
      await _storage.write(key: 'role', value: role);
      return true;
    } catch (e) {
      print("Login Failed: $e");
      return false;
    }
  }

  Future<bool> adminLogin(
    String username,
    String password,
  ) async {
    try {
      final res = await _dio.post(
        '/admin/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      await _storage.write(
        key: 'jwt',
        value: res.data['token'],
      );

      await _storage.write(
        key: 'role',
        value: 'admin',
      );

      return true;
    } catch (e) {
      print("Admin Login Failed: $e");
      return false;
    }
  }

  // --- 2. REQUEST OTP ---
  // --- 2. REQUEST OTP ---
  Future<bool> requestOtp(
    String phone,
    String aadhaar,
  ) async {
    try {
      await _dio.post(
        '/auth/request-otp',
        data: {
          'phone': phone,
          'aadhaarNumber': aadhaar,
        },
      );

      return true;
    } catch (e) {
      print("OTP Request Failed: $e");
      return false;
    }
  }

  Future<bool> verifyOtp(
    String phone,
    String otp,
  ) async {
    try {
      await _dio.post(
        '/auth/verify-otp',
        data: {
          'phone': phone,
          'otp': otp,
        },
      );

      return true;
    } catch (e) {
      print("OTP Verification Failed: $e");
      return false;
    }
  }

  Future<bool> requestAdminOtp(
    String email,
  ) async {
    try {
      await _dio.post(
        '/admin/request-otp',
        data: {
          'email': email,
        },
      );

      return true;
    } catch (e) {
      print("Admin OTP Failed: $e");
      return false;
    }
  }

  // --- 3. REGISTER WITH OTP ---
  Future<bool> register(
      String phone, String password, String aadhaar, String role) async {
    try {
      await _dio.post('/auth/register', data: {
        'phone': phone,
        'password': password,
        'aadhaarNumber': aadhaar,
        'role': role,
      });
      return true;
    } catch (e) {
      print("Registration Failed: $e");
      return false;
    }
  }

  Future<bool> adminRegister(
    String username,
    String name,
    String department,
    String email,
    String password,
    String otp,
  ) async {
    try {
      await _dio.post(
        '/admin/register',
        data: {
          'username': username,
          'name': name,
          'department': department,
          'email': email,
          'password': password,
          'otp': otp,
        },
      );

      return true;
    } catch (e) {
      print("Admin Registration Failed: $e");
      return false;
    }
  }

  // --- 4. GET USER PROFILE (NEW) ---
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final res = await _dio.get('/user/profile');
      return res.data;
    } catch (e) {
      print("Fetch Profile Error: $e");
      return null;
    }
  }

  // =========================================
// ADD THIS METHOD RIGHT HERE
// =========================================
  Future<List<dynamic>> getDocuments() async {
    try {
      final response = await _dio.get('/user/documents');
      return List<dynamic>.from(response.data);
    } on DioException catch (e) {
      print("Get Documents Error: ${e.response?.data}");
      return [];
    }
  }

  // --- 5. PROFILE UPDATE ---
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      print("POST URL: $baseUrl/user/profile");
      print("BODY: $data");

      final response = await _dio.post(
        '/user/profile',
        data: data,
      );

      print("STATUS: ${response.statusCode}");
      print("RESPONSE: ${response.data}");
    } on DioException catch (e) {
      print("STATUS: ${e.response?.statusCode}");
      print("RESPONSE: ${e.response?.data}");
      rethrow;
    }
  }

  // --- 6. EVALUATE SCHEMES ---
  Future<List<dynamic>> getEligibleSchemes() async {
    try {
      final res = await _dio.get('/schemes/evaluate');

      return List<dynamic>.from(res.data['schemes'] ?? []);
    } on DioException catch (e) {
      print("STATUS : ${e.response?.statusCode}");
      print("URL    : ${e.requestOptions.uri}");
      print("BODY   : ${e.response?.data}");

      // User has not completed profile yet
      if (e.response?.statusCode == 400 || e.response?.statusCode == 404) {
        return [];
      }

      // Server temporarily unavailable (Render waking up)
      if (e.response?.statusCode == 500) {
        return [];
      }

      rethrow;
    }
  }

  // --- 7. APPLY TO SCHEME (TRACKING) ---
  Future<void> applyToScheme(String schemeId) async {
    try {
      final response = await _dio.post(
        '/applications',
        data: {
          'schemeId': schemeId,
        },
      );

      print("Application submitted.");
      print(response.data);
    } on DioException catch (e) {
      print("STATUS : ${e.response?.statusCode}");
      print("BODY   : ${e.response?.data}");

      throw Exception(
        e.response?.data['message'] ?? "Failed to submit application.",
      );
    }
  }

  // --- 8. GET MY APPLICATIONS ---
  Future<List<dynamic>> getMyApplications() async {
    try {
      final res = await _dio.get('/applications');
      return res.data['applications'];
    } catch (e) {
      print("Get Applications Error: $e");
      return [];
    }
  }

  // --- 9. UPLOAD DOCUMENT ---
  Future<Map<String, dynamic>> uploadDocument({
    required XFile file,
    required String documentType,
    required String category,
  }) async {
    try {
      final formData = FormData.fromMap({
        "documentType": documentType,
        "category": category,
        "document": MultipartFile.fromBytes(
          await file.readAsBytes(),
          filename: file.name,
        )
      });

      print("Uploading:");
      print("documentType = $documentType");
      print("category = $category");
      print("filename = ${file.name}");

      final response = await _dio.post(
        "/user/upload-document",
        data: formData,
      );

      return response.data;
    } on DioException catch (e) {
      print("Upload Error: ${e.response?.data}");
      print("STATUS : ${e.response?.statusCode}");
      print("BODY   : ${e.response?.data}");
      print("URL    : ${e.requestOptions.uri}");

      throw Exception(
        e.response?.data?["message"] ??
            e.response?.data.toString() ??
            "Document upload failed",
      );
    }
  }

  Future<Map<String, dynamic>> uploadDocumentFromPlatformFile({
    required PlatformFile file,
    required String documentType,
    required String category,
  }) async {
    try {
      final formData = FormData.fromMap({
        "documentType": documentType,
        "category": category,
        "document": MultipartFile.fromBytes(
          file.bytes!,
          filename: file.name,
        ),
      });

      print("Uploading:");
      print("documentType = $documentType");
      print("category = $category");
      print("filename = ${file.name}");

      final response = await _dio.post(
        "/user/upload-document",
        data: formData,
      );

      return response.data;
    } on DioException catch (e) {
      print("Upload Error: ${e.response?.data}");

      print("STATUS : ${e.response?.statusCode}");
      print("BODY   : ${e.response?.data}");
      print("URL    : ${e.requestOptions.uri}");

      throw Exception(
        e.response?.data?["message"] ??
            e.response?.data.toString() ??
            "Document upload failed",
      );
    }
  }

// --- UPLOAD PROFILE PHOTO ---
  Future<Map<String, dynamic>> uploadProfilePhoto({
    required XFile file,
  }) async {
    try {
      final formData = FormData.fromMap({
        "photo": MultipartFile.fromBytes(
          await file.readAsBytes(),
          filename: file.name,
        )
      });

      final response = await _dio.post(
        "/user/upload-profile-photo",
        data: formData,
      );

      return response.data;
    } on DioException catch (e) {
      print("Profile Photo Upload Error: ${e.response?.data}");

      throw Exception(
        e.response?.data["message"] ?? "Profile photo upload failed",
      );
    }
  }

// --- 10. VIEW DOCUMENT ---
  Future<Map<String, dynamic>> getDocument(
    String documentId,
  ) async {
    try {
      final response = await _dio.get(
        "/user/document/$documentId",
      );

      return response.data;
    } on DioException catch (e) {
      print("View Document Error: ${e.response?.data}");

      throw Exception(
        e.response?.data["message"] ?? "Unable to open document",
      );
    }
  }

  Future<Map<String, dynamic>> getAdminDocument(
    String documentId,
  ) async {
    final response = await _dio.get(
      "/admin/documents/$documentId",
    );

    return response.data;
  }

  Future<void> verifyDocument(
    String documentId,
  ) async {
    try {
      await _dio.patch(
        "/admin/documents/$documentId/verify",
      );
    } on DioException catch (e) {
      print("Verify Document Error: ${e.response?.data}");

      throw Exception(
        e.response?.data?["message"] ?? "Failed to verify document.",
      );
    }
  }

  Future<void> rejectDocument(
    String documentId,
  ) async {
    try {
      await _dio.patch(
        "/admin/documents/$documentId/reject",
      );
    } on DioException catch (e) {
      print("Reject Document Error: ${e.response?.data}");

      throw Exception(
        e.response?.data?["message"] ?? "Failed to reject document.",
      );
    }
  }

  // --- 9. LOGOUT ---
  Future<void> logout() async {
    await _storage.delete(key: 'jwt');
    await _storage.delete(key: 'role'); // Also clear the role on logout
  }

  Future<Map<String, dynamic>> getAdminDashboard() async {
    final response = await _dio.get("/admin/dashboard");
    return response.data;
  }

// --- GET ALL SCHEMES (ADMIN) ---
  Future<List<dynamic>> getAdminSchemes({
    String? search,
    String? category,
  }) async {
    try {
      final response = await _dio.get(
        "/admin/schemes",
        queryParameters: {
          if (search != null && search.isNotEmpty) "search": search,
          if (category != null &&
              category.isNotEmpty &&
              category != "All Categories")
            "category": category,
        },
      );

      return List<dynamic>.from(
        response.data["schemes"] ?? [],
      );
    } on DioException catch (e) {
      print("Get Admin Schemes Error: ${e.response?.data}");
      return [];
    }
  }

  Future<List<dynamic>> searchAdminSchemes(
    String search,
  ) async {
    try {
      final response = await _dio.get(
        "/admin/schemes",
        queryParameters: {
          "search": search,
        },
      );

      return List<dynamic>.from(
        response.data["schemes"] ?? [],
      );
    } on DioException catch (e) {
      print("Search Schemes Error: ${e.response?.data}");
      return [];
    }
  }

  // --- GET SINGLE SCHEME (ADMIN) ---
  Future<Map<String, dynamic>> getSingleScheme(
    String schemeId,
  ) async {
    try {
      final response = await _dio.get(
        "/admin/schemes/$schemeId",
      );

      return response.data["scheme"];
    } on DioException catch (e) {
      print("Get Single Scheme Error: ${e.response?.data}");

      throw Exception(
        e.response?.data["message"] ?? "Failed to fetch scheme details.",
      );
    }
  }

  // --- ADD SCHEME (ADMIN) ---
  Future<Map<String, dynamic>> addScheme({
    required String name,
    required String description,
    required String category,
    required String benefits,
    required String eligibility,
    required String howToApply,
    required String officialWebsite,
    List<String> documentsRequired = const [],
    String? state,
    String? gender,
    String? occupation,
    String? casteCategory,
    int? minAge,
    int? maxAge,
    int? minIncome,
    int? maxIncome,
    bool? isBPL,
    String status = "Active",
  }) async {
    try {
      final response = await _dio.post(
        "/admin/schemes",
        data: {
          "name": name,
          "description": description,
          "category": category,
          "benefits": benefits,
          "eligibility": eligibility,
          "howToApply": howToApply,
          "officialWebsite": officialWebsite,
          "documentsRequired": documentsRequired,
          "state": state,
          "gender": gender,
          "occupation": occupation,
          "casteCategory": casteCategory,
          "minAge": minAge,
          "maxAge": maxAge,
          "minIncome": minIncome,
          "maxIncome": maxIncome,
          "isBPL": isBPL,
          "status": status,
        },
      );

      return response.data;
    } on DioException catch (e) {
      print("Add Scheme Error: ${e.response?.data}");

      throw Exception(
        e.response?.data?["message"] ?? "Failed to add scheme.",
      );
    }
  }

// --- UPDATE SCHEME (ADMIN) ---
  Future<Map<String, dynamic>> updateScheme({
    required String schemeId,
    required String name,
    required String description,
    required String category,
    required String benefits,
    required String eligibility,
    required String howToApply,
    required String officialWebsite,
    List<String> documentsRequired = const [],
    String? state,
    String? gender,
    String? occupation,
    String? casteCategory,
    int? minAge,
    int? maxAge,
    int? minIncome,
    int? maxIncome,
    bool? isBPL,
    String status = "Active",
  }) async {
    try {
      final response = await _dio.put(
        "/admin/schemes/$schemeId",
        data: {
          "name": name,
          "description": description,
          "category": category,
          "benefits": benefits,
          "eligibility": eligibility,
          "howToApply": howToApply,
          "officialWebsite": officialWebsite,
          "documentsRequired": documentsRequired,
          "state": state,
          "gender": gender,
          "occupation": occupation,
          "casteCategory": casteCategory,
          "minAge": minAge,
          "maxAge": maxAge,
          "minIncome": minIncome,
          "maxIncome": maxIncome,
          "isBPL": isBPL,
          "status": status,
        },
      );

      return response.data;
    } on DioException catch (e) {
      print("Update Scheme Error: ${e.response?.data}");

      throw Exception(
        e.response?.data?["message"] ?? "Failed to update scheme.",
      );
    }
  }

// --- DELETE SCHEME (ADMIN) ---
  Future<void> deleteScheme(String schemeId) async {
    try {
      await _dio.delete(
        "/admin/schemes/$schemeId",
      );
    } on DioException catch (e) {
      print("Delete Scheme Error: ${e.response?.data}");

      throw Exception(
        e.response?.data?["message"] ?? "Failed to delete scheme.",
      );
    }
  }

// --- 12. ADMIN APPLICATIONS ---
  Future<List<dynamic>> getAdminApplications() async {
    final response = await _dio.get("/admin/applications");
    return response.data["applications"];
  }

// --- 12A. GET SINGLE APPLICATION DETAILS ---
  Future<Map<String, dynamic>> getApplicationDetails(
    String applicationId,
  ) async {
    try {
      final response = await _dio.get(
        "/admin/applications/$applicationId",
      );

      return response.data["application"];
    } on DioException catch (e) {
      print("Application Details Error: ${e.response?.data}");

      throw Exception(
        e.response?.data["message"] ?? "Failed to fetch application details",
      );
    }
  }

// --- 13. ADMIN ANALYTICS ---
  Future<Map<String, dynamic>> getAdminAnalytics() async {
    final response = await _dio.get("/admin/analytics");
    return response.data;
  }

// --- 14. UPDATE APPLICATION STATUS ---
  Future<void> updateApplicationStatus(
    String applicationId,
    String status,
  ) async {
    await _dio.patch(
      "/admin/applications/$applicationId",
      data: {
        "status": status,
      },
    );
  }
}

// --- 11. ADMIN DASHBOARD ---

// --- RIVERPOD PROVIDERS ---

final apiProvider = Provider((ref) => ApiService());

final schemesProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiProvider);
  return await api.getEligibleSchemes();
});
