import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

const String baseUrl = "http://localhost:3000/api";

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

  // --- 2. REQUEST OTP ---
  Future<bool> requestOtp(String phone, String aadhaar) async {
    try {
      await _dio.post('/auth/request-otp',
          data: {'phone': phone, 'aadhaarNumber': aadhaar});
      return true;
    } catch (e) {
      print("OTP Request Failed: $e");
      return false;
    }
  }

  // --- 3. REGISTER WITH OTP ---
  Future<bool> register(String phone, String password, String aadhaar,
      String role, String otp) async {
    try {
      await _dio.post('/auth/register', data: {
        'phone': phone,
        'password': password,
        'aadhaarHash': aadhaar,
        'role': role,
        'otp': otp // Sending the 6-digit OTP to the backend
      });
      return true;
    } catch (e) {
      print("Registration Failed: $e");
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
      print("GET => $baseUrl/schemes/evaluate");

      final res = await _dio.get('/schemes/evaluate');

      print(res.data);

      return res.data['schemes'];
    } on DioException catch (e) {
      print("STATUS : ${e.response?.statusCode}");
      print("URL    : ${e.requestOptions.uri}");
      print("BODY   : ${e.response?.data}");
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
      e.response?.data['message'] ??
          "Failed to submit application.",
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

    final response = await _dio.post(
      "/user/upload-document",
      data: formData,
    );

    return response.data;
  } on DioException catch (e) {
    print("Upload Error: ${e.response?.data}");
    throw Exception(
      e.response?.data["message"] ?? "Document upload failed",
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

    final response = await _dio.post(
      "/user/upload-document",
      data: formData,
    );

    return response.data;
  } on DioException catch (e) {
    print("Upload Error: ${e.response?.data}");

    throw Exception(
      e.response?.data["message"] ??
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
      e.response?.data["message"] ??
          "Profile photo upload failed",
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
      e.response?.data["message"] ??
          "Unable to open document",
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

  // --- 9. LOGOUT ---
  Future<void> logout() async {
    await _storage.delete(key: 'jwt');
    await _storage.delete(key: 'role'); // Also clear the role on logout
  }

  Future<Map<String, dynamic>> getAdminDashboard() async {
  final response = await _dio.get("/admin/dashboard");
  return response.data;
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
      e.response?.data["message"] ??
          "Failed to fetch application details",
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
