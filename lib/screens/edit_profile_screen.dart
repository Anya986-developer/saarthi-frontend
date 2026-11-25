import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  String? profilePhotoUrl;

  bool _loading = true;
  bool _saving = false;

  DateTime? _selectedDOB;

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final incomeController = TextEditingController();

  String gender = "Male";
  String category = "General";
  String occupation = "Student";
  String state = "Bihar";
  String bplStatus = "No";

  final genders = ["Male", "Female", "Other"];
  final categories = ["General", "OBC", "EBC", "SC", "ST"];
  final occupations = [
    "Student",
    "Farmer",
    "Businessman",
    "Employee",
    "Unemployed"
  ];
  final bplOptions = ["Yes", "No"];
  final states = [
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chhattisgarh",
    "Delhi",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Tamil Nadu",
    "Telangana",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal"
  ];

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    incomeController.dispose();
    super.dispose();
  }

  Future<void> loadProfile() async {
    final api = ref.read(apiProvider);

    try {
      final profile = await api.getUserProfile();

      if (profile == null) return;

      setState(() {
        profilePhotoUrl = profile["profilePhotoUrl"];
        nameController.text = profile["name"] ?? "";

        _selectedDOB = profile["dateOfBirth"] != null
            ? DateTime.parse(profile["dateOfBirth"])
            : null;

        ageController.text = (profile["age"] ?? "").toString();

        incomeController.text = (profile["income"] ?? "").toString();

        gender = profile["gender"] ?? gender;
        category = profile["category"] ?? category;
        occupation = profile["occupation"] ?? occupation;
        state = profile["state"] ?? state;

        bplStatus = (profile["isBPL"] ?? false) ? "Yes" : "No";
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> uploadProfilePhoto() async {
    showModalBottomSheet(
      context: context,
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
                    imageQuality: 80,
                  );

                  if (image == null) return;

                  await ref.read(apiProvider).uploadProfilePhoto(
                        file: image,
                      );

                  await loadProfile();

                  if (!mounted) return;

                  
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () async {
                  Navigator.pop(context);

                  final image = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                  );

                  if (image == null) return;

                  await ref.read(apiProvider).uploadProfilePhoto(
                        file: image,
                      );

                  await loadProfile();

                  if (!mounted) return;

                  await loadProfile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> selectDOB() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDOB ?? DateTime(2003),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked == null) return;

    final today = DateTime.now();

    int age = today.year - picked.year;

    if (today.month < picked.month ||
        (today.month == picked.month && today.day < picked.day)) {
      age--;
    }

    setState(() {
      _selectedDOB = picked;
      ageController.text = age.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    ImageProvider? imageProvider;

    if (profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty) {
      imageProvider = NetworkImage(profilePhotoUrl!);
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Column(children: [
          Text("Edit Profile",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          SizedBox(height: 2),
          Text("Update your personal information",
              style: TextStyle(fontSize: 12, color: Colors.grey))
        ]),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ]),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xffE8F8EF),
                          backgroundImage: imageProvider,
                          child: imageProvider == null
                              ? const Icon(
                                  Icons.person,
                                  size: 42,
                                  color: Color(0xff21B573),
                                )
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xff21B573),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              iconSize: 18,
                              constraints: const BoxConstraints.tightFor(
                                  width: 34, height: 34),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                uploadProfilePhoto();
                              },
                              icon: const Icon(Icons.camera_alt,
                                  color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Profile Photo",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text("JPG, PNG up to 5MB",
                              style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              uploadProfilePhoto();
                            },
                            icon: const Icon(Icons.camera_alt_outlined,
                                color: Color(0xff21B573)),
                            label: const Text("Change Photo",
                                style: TextStyle(color: Color(0xff21B573))),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xff21B573)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              // ======================= PART 2 =======================
// Paste this code inside the Column(children: [...])
// immediately AFTER the Profile Card Container,
// and BEFORE the closing ], of the Column.

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        CircleAvatar(
                          radius: 5,
                          backgroundColor: Color(0xff21B573),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Personal Information",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: "Full Name",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            onTap: selectDOB,
                            controller: TextEditingController(
                              text: _selectedDOB == null
                                  ? ""
                                  : "${_selectedDOB!.day}/${_selectedDOB!.month}/${_selectedDOB!.year}",
                            ),
                            decoration: const InputDecoration(
                              labelText: "Date of Birth",
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_month),
                              hintText: "Select DOB",
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: ageController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: "Age",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: gender,
                            decoration: const InputDecoration(
                              labelText: "Gender",
                              border: OutlineInputBorder(),
                            ),
                            items: genders
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) => setState(() => gender = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: category,
                            decoration: const InputDecoration(
                              labelText: "Category",
                              border: OutlineInputBorder(),
                            ),
                            items: categories
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) => setState(() => category = v!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: occupation,
                            decoration: const InputDecoration(
                              labelText: "Occupation",
                              border: OutlineInputBorder(),
                            ),
                            items: occupations
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) => setState(() => occupation = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: incomeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              prefixText: "₹ ",
                              labelText: "Annual Income",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: state,
                            decoration: const InputDecoration(
                              labelText: "State",
                              border: OutlineInputBorder(),
                            ),
                            items: states
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) => setState(() => state = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: bplStatus,
                      decoration: const InputDecoration(
                        labelText: "BPL Status",
                        border: OutlineInputBorder(),
                      ),
                      items: bplOptions
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => bplStatus = v!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _saving
                      ? null
                      : () async {
                          setState(() {
                            _saving = true;
                          });

                          try {
                            final api = ref.read(apiProvider);

                            await api.updateProfile({
                              "name": nameController.text,
                              "dateOfBirth": _selectedDOB?.toIso8601String(),
                              "age": int.tryParse(ageController.text) ?? 0,
                              "income":
                                  int.tryParse(incomeController.text) ?? 0,
                              "gender": gender,
                              "category": category,
                              "occupation": occupation,
                              "state": state,
                              "isBPL": bplStatus == "Yes",
                            });

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Profile Updated"),
                              ),
                            );

                            context.go('/profile_processing');
                          } catch (e) {
                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          } finally {
                            if (mounted) {
                              setState(() {
                                _saving = false;
                              });
                            }
                          }
                          // Your existing Save Changes code
                        },
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_saving ? "Saving..." : "Save Changes"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff21B573),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ), // Column
        ), // SingleChildScrollView
      ), // Form
    ); // Scaffold
  }
}
