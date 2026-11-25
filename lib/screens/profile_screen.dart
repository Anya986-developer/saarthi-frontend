import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ApiService _api = ApiService();
  final ImagePicker _picker = ImagePicker();

  bool _loading = true;

  Map<String, dynamic>? profile;
  List<dynamic> documents = [];

  final Color primary = const Color(0xff10B981);
  final Color background = const Color(0xffF6F8FB);
  final Color lightGreen = const Color(0xffECFDF5);

  @override
  void initState() {
    super.initState();
    loadProfile();
    
  }

  Future<void> loadProfile() async {
    final profileData = await _api.getUserProfile();
    final documentData = await _api.getDocuments();

    if (!mounted) return;

    setState(() {
      profile = profileData;
      documents = documentData;
      _loading = false;
    });
  }

  bool isUploaded(String category) {
    return documents.any(
      (doc) => doc["category"] == category,
    );
  }

  Map<String, dynamic>? getUploadedDocument(String category) {
    try {
      return documents.firstWhere(
        (doc) => doc["category"] == category,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> uploadDocument(String documentType) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () async {
                  Navigator.pop(context);

                  final image = await _picker.pickImage(
                    source: ImageSource.camera,
                  );

                  if (image == null) return;

                  await _uploadFile(
                    image,
                    documentType,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () async {
                  Navigator.pop(context);

                  final image = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );

                  if (image == null) return;

                  await _uploadFile(
                    image,
                    documentType,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text("PDF / Files"),
                onTap: () async {
                  Navigator.pop(context);

                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: [
                      "pdf",
                      "jpg",
                      "jpeg",
                      "png",
                    ],
                  );

                  if (result == null) return;

                  final picked = result.files.single;

                  if (picked.bytes == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Unable to read file"),
                      ),
                    );
                    return;
                  }

                  try {
                    await _api.uploadDocumentFromPlatformFile(
                      file: picked,
                      documentType: documentType,
                      category: documentType,
                    );

                    await loadProfile();

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Document uploaded successfully"),
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadFile(
    XFile file,
    String documentType,
  ) async {
    try {
      await _api.uploadDocument(
        file: file,
        documentType: documentType,
        category: documentType,
      );

      await loadProfile();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Document uploaded successfully"),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget infoTile(
      IconData icon,
      String title,
      String value,
      Color bg,
      Color color,
    ) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget documentTile(
      String title,
      String subtitle,
      bool uploaded,
      String documentType,
    ) {
      return ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xffECFDF5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.description_outlined,
            color: Color(0xff10B981),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 2),
            Text(
              "Supported: PDF, JPG, JPEG, PNG (Max 5 MB)",
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: uploaded
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xffDCFCE7),
                      disabledBackgroundColor: const Color(0xffDCFCE7),
                      foregroundColor: const Color(0xff15803D),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(
                      Icons.check,
                      size: 18,
                      color: Color(0xff15803D),
                    ),
                    label: const Text(
                      "Uploaded",
                      style: TextStyle(
                        color: Color(0xff15803D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final doc = getUploadedDocument(documentType);

                      if (doc == null) return;

                      final response = await _api.getDocument(doc["id"]);

                      final url = response["url"];

                      await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text("View"),
                  ),
                ],
              )
            : OutlinedButton(
                onPressed: () {
                  uploadDocument(documentType);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: BorderSide(color: primary),
                ),
                child: const Text("Upload"),
              ),
      );
    }

    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER

                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        context.go('/home');
                      },
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "My Profile",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                const Text(
                  "Manage your personal information",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 25),

                /// PROFILE CARD

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: lightGreen,
                            backgroundImage: profile?["profilePhotoUrl"] != null
                                ? NetworkImage(profile!["profilePhotoUrl"])
                                : null,
                            child: profile?["profilePhotoUrl"] == null
                                ? Icon(
                                    Icons.person,
                                    size: 45,
                                    color: primary,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 13,
                              backgroundColor: primary,
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile?["name"] ?? "Citizen",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: lightGreen,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified,
                                    color: primary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "Verified",
                                    style: TextStyle(
                                      color: primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Government Scheme Applicant",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.white,
                          foregroundColor: primary,
                          side: BorderSide(color: primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // TODO:
                          context.push('/edit_profile');
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text("Edit Profile"),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// PERSONAL INFORMATION
                sectionTitle("Personal Information"),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: infoTile(
                              Icons.person_outline,
                              "Full Name",
                              profile?["name"] ?? "-",
                              const Color(0xffEAFBF4),
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: infoTile(
                              Icons.cake_outlined,
                              "Age",
                              "${profile?["age"] ?? "-"}",
                              const Color(0xffFFF7E8),
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: infoTile(
                              Icons.wc,
                              "Gender",
                              profile?["gender"] ?? "-",
                              const Color(0xffF4EDFF),
                              Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: infoTile(
                              Icons.work_outline,
                              "Occupation",
                              profile?["occupation"] ?? "-",
                              const Color(0xffEEF5FF),
                              Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: infoTile(
                              Icons.groups_outlined,
                              "Category",
                              profile?["category"] ?? "-",
                              const Color(0xffFFF3EB),
                              Colors.deepOrange,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: infoTile(
                              Icons.currency_rupee,
                              "Income",
                              "₹ ${profile?["income"] ?? 0}",
                              const Color(0xffFFFBE8),
                              Colors.amber.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: infoTile(
                              Icons.location_on_outlined,
                              "State",
                              profile?["state"] ?? "-",
                              const Color(0xffF4EDFF),
                              Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: infoTile(
                              Icons.credit_score,
                              "BPL",
                              (profile?["isBPL"] ?? false) ? "Yes" : "No",
                              const Color(0xffECFDF5),
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                sectionTitle("Documents"),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      documentTile(
                        "Aadhaar Card",
                        "Mandatory",
                        isUploaded("AADHAAR"),
                        "AADHAAR",
                      ),
                      documentTile(
                        "Income Certificate",
                        "Mandatory",
                        isUploaded("INCOME"),
                        "INCOME",
                      ),
                      documentTile(
                        "Caste Certificate",
                        "If Applicable",
                        isUploaded("CASTE"),
                        "CASTE",
                      ),
                      documentTile(
                        "Residence Certificate",
                        "If Applicable",
                        isUploaded("RESIDENCE"),
                        "RESIDENCE",
                      ),
                      documentTile(
                        "Bank Passbook",
                        "If Applicable",
                        isUploaded("BANK"),
                        "BANK",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      // TODO
                      context.push('/edit_profile');
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text(
                      "Edit Profile",
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () async {
                      await _api.logout();

                      if (mounted) {
                        context.go('/login');
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      "Logout",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
