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

  String getDocumentStatus(String category) {
    final doc = getUploadedDocument(category);

    if (doc == null) {
      return "PENDING";
    }

    return doc["status"] ?? "PENDING";
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
                    withData: true,
                    allowedExtensions: [
                      "pdf",
                      "jpg",
                      "jpeg",
                      "png",
                    ],
                  );

                  if (result == null) return;

                  final picked = result.files.single;

                  if (picked.bytes == null && picked.path == null) {
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
      final status = getDocumentStatus(documentType);
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mobile = constraints.maxWidth < 650;

            return mobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(subtitle),
                                Text(
                                  "Supported: PDF, JPG, JPEG, PNG",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (uploaded)
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ElevatedButton.icon(
                              onPressed: null,
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: const Text(
                                "Uploaded",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                disabledBackgroundColor:
                                    const Color(0xFF22C55E),
                                disabledForegroundColor: Colors.white,
                                backgroundColor: const Color(0xFF22C55E),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: null,
                              icon: Icon(
                                status == "VERIFIED"
                                    ? Icons.verified
                                    : Icons.pending_outlined,
                                size: 18,
                              ),
                              label: Text(
                                status == "VERIFIED" ? "Verified" : "Pending",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: status == "VERIFIED"
                                    ? Colors.green
                                    : Colors.red,
                                side: BorderSide(
                                  color: status == "VERIFIED"
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton.icon(
                              onPressed: () async {
                                final doc = getUploadedDocument(documentType);

                                if (doc == null) return;

                                final response =
                                    await _api.getDocument(doc["id"]);

                                await launchUrl(
                                  Uri.parse(response["url"]),
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF047857),
                                backgroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Color(0xFF10B981),
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(
                                Icons.visibility_outlined,
                                size: 18,
                              ),
                              label: const Text(
                                "View",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: () {
                            uploadDocument(documentType);
                          },
                          icon:
                              const Icon(Icons.cloud_upload_outlined, size: 18),
                          label: const Text("Upload"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF059669),
                            side: const BorderSide(
                              color: Color(0xFF10B981),
                              width: 1.5,
                            ),
                            backgroundColor: const Color(0xFFF0FDF4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                    ],
                  )
                : Row(
                    children: [
                      Container(
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(subtitle),
                            Text(
                              "Supported: PDF, JPG, JPEG, PNG",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (uploaded) ...[
                        ElevatedButton.icon(
                          onPressed: null,
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: const Text(
                            "Uploaded",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            disabledBackgroundColor: const Color(0xFF22C55E),
                            disabledForegroundColor: Colors.white,
                            backgroundColor: const Color(0xFF22C55E),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: null,
                          icon: Icon(
                            status == "VERIFIED"
                                ? Icons.verified
                                : Icons.pending_outlined,
                            size: 18,
                          ),
                          label: Text(
                            status == "VERIFIED" ? "Verified" : "Pending",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: status == "VERIFIED"
                                ? Colors.green
                                : Colors.red,
                            side: BorderSide(
                              color: status == "VERIFIED"
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final doc = getUploadedDocument(documentType);

                            if (doc == null) return;

                            final response = await _api.getDocument(doc["id"]);

                            await launchUrl(
                              Uri.parse(response["url"]),
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          icon: const Icon(Icons.visibility),
                          label: const Text("View"),
                        ),
                      ] else
                        OutlinedButton.icon(
                          onPressed: () {
                            uploadDocument(documentType);
                          },
                          icon:
                              const Icon(Icons.cloud_upload_outlined, size: 18),
                          label: const Text("Upload"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF059669),
                            side: const BorderSide(
                              color: Color(0xFF10B981),
                              width: 1.5,
                            ),
                            backgroundColor: const Color(0xFFF0FDF4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                    ],
                  );
          },
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
