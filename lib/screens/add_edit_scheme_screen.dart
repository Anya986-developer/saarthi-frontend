import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';

class AddEditSchemeScreen extends StatefulWidget {
  final String? schemeId;

  const AddEditSchemeScreen({
    super.key,
    this.schemeId,
  });

  bool get isEdit => schemeId != null;

  @override
  State<AddEditSchemeScreen> createState() => _AddEditSchemeScreenState();
}

class _AddEditSchemeScreenState extends State<AddEditSchemeScreen> {
  final ApiService _api = ApiService();

  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _saving = false;

  //==========================================================
  // BASIC INFORMATION
  //==========================================================

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  final TextEditingController _benefitsController = TextEditingController();

  final TextEditingController _eligibilityController = TextEditingController();

  final TextEditingController _howToApplyController = TextEditingController();

  final TextEditingController _websiteController = TextEditingController();

  final TextEditingController _documentsController = TextEditingController();

  //==========================================================
  // AGE & INCOME
  //==========================================================

  final TextEditingController _minAgeController = TextEditingController();

  final TextEditingController _maxAgeController = TextEditingController();

  final TextEditingController _minIncomeController = TextEditingController();

  final TextEditingController _maxIncomeController = TextEditingController();

  //==========================================================
  // DROPDOWNS
  //==========================================================

  String? _selectedCategory;

  String _selectedStatus = "Active";

  String? _selectedGender;

  String? _selectedOccupation;

  String? _selectedState;

  String? _selectedCaste;

  bool? _isBPL;

  List<String> _requiredDocuments = [];

  bool get isEdit => widget.isEdit;

  //==========================================================
  // DROPDOWN OPTIONS
  //==========================================================

  final List<String> _categories = [
    "Education",
    "Scholarship",
    "Agriculture",
    "Health",
    "Women",
    "Employment",
    "Housing",
    "Finance",
    "Business",
    "Social Welfare",
    "Other",
  ];

  final List<String> _statusList = [
    "Active",
    "Inactive",
  ];

  final List<String> _genderList = [
    "Any",
    "Male",
    "Female",
  ];

  final List<String> _occupationList = [
    "Any",
    "Student",
    "Farmer",
    "Employee",
    "Business",
    "Unemployed",
  ];

  final List<String> _casteList = [
    "Any",
    "General",
    "OBC",
    "SC",
    "ST",
    "EWS",
  ];

  final List<String> _stateList = [
    "Any",
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
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal",
  ];

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      _loadScheme();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _benefitsController.dispose();
    _eligibilityController.dispose();
    _howToApplyController.dispose();
    _websiteController.dispose();
    _documentsController.dispose();

    _minAgeController.dispose();
    _maxAgeController.dispose();
    _minIncomeController.dispose();
    _maxIncomeController.dispose();

    super.dispose();
  }

  //==========================================================
// LOAD SCHEME (EDIT MODE)
//==========================================================

  Future<void> _loadScheme() async {
    if (!isEdit) return;

    setState(() {
      _loading = true;
    });

    try {
      final scheme = await _api.getSingleScheme(widget.schemeId!);

      _nameController.text = scheme["name"] ?? "";

      _descriptionController.text = scheme["description"] ?? "";

      _benefitsController.text = scheme["benefits"] ?? "";

      _eligibilityController.text = scheme["eligibility"] ?? "";

      _howToApplyController.text = scheme["howToApply"] ?? "";

      _websiteController.text = scheme["officialWebsite"] ?? "";

      _selectedCategory = scheme["category"];

      _selectedStatus = scheme["status"] ?? "Active";

      _selectedGender = scheme["gender"];

      _selectedOccupation = scheme["occupation"];

      _selectedState = scheme["state"];

      _selectedCaste = scheme["casteCategory"];

      _isBPL = scheme["isBPL"];

      _minAgeController.text = scheme["minAge"]?.toString() ?? "";

      _maxAgeController.text = scheme["maxAge"]?.toString() ?? "";

      _minIncomeController.text = scheme["minIncome"]?.toString() ?? "";

      _maxIncomeController.text = scheme["maxIncome"]?.toString() ?? "";

      if (scheme["documentsRequired"] != null) {
        _requiredDocuments = List<String>.from(
          scheme["documentsRequired"],
        );

        _documentsController.text = _requiredDocuments.join(", ");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to load scheme.\n$e"),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }
//==========================================================
// SAVE SCHEME
//==========================================================

  Future<void> _saveScheme() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    try {
      _requiredDocuments = _documentsController.text
          .split(",")
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (isEdit) {
        await _api.updateScheme(
          schemeId: widget.schemeId!,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory ?? "",
          benefits: _benefitsController.text.trim(),
          eligibility: _eligibilityController.text.trim(),
          howToApply: _howToApplyController.text.trim(),
          officialWebsite: _websiteController.text.trim(),
          documentsRequired: _requiredDocuments,
          state: _selectedState == "Any" ? null : _selectedState,
          gender: _selectedGender == "Any" ? null : _selectedGender,
          occupation: _selectedOccupation == "Any" ? null : _selectedOccupation,
          casteCategory: _selectedCaste == "Any" ? null : _selectedCaste,
          minAge: _minAgeController.text.isEmpty
              ? null
              : int.parse(_minAgeController.text),
          maxAge: _maxAgeController.text.isEmpty
              ? null
              : int.parse(_maxAgeController.text),
          minIncome: _minIncomeController.text.isEmpty
              ? null
              : int.parse(_minIncomeController.text),
          maxIncome: _maxIncomeController.text.isEmpty
              ? null
              : int.parse(_maxIncomeController.text),
          isBPL: _isBPL,
          status: _selectedStatus,
        );
      } else {
        await _api.addScheme(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory ?? "",
          benefits: _benefitsController.text.trim(),
          eligibility: _eligibilityController.text.trim(),
          howToApply: _howToApplyController.text.trim(),
          officialWebsite: _websiteController.text.trim(),
          documentsRequired: _requiredDocuments,
          state: _selectedState == "Any" ? null : _selectedState,
          gender: _selectedGender == "Any" ? null : _selectedGender,
          occupation: _selectedOccupation == "Any" ? null : _selectedOccupation,
          casteCategory: _selectedCaste == "Any" ? null : _selectedCaste,
          minAge: _minAgeController.text.isEmpty
              ? null
              : int.parse(_minAgeController.text),
          maxAge: _maxAgeController.text.isEmpty
              ? null
              : int.parse(_maxAgeController.text),
          minIncome: _minIncomeController.text.isEmpty
              ? null
              : int.parse(_minIncomeController.text),
          maxIncome: _maxIncomeController.text.isEmpty
              ? null
              : int.parse(_maxIncomeController.text),
          isBPL: _isBPL,
          status: _selectedStatus,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? "Scheme updated successfully."
                : "Scheme added successfully.",
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _saving = false;
      });
    }
  }

//==========================================================
// REUSABLE TEXT FIELD
//==========================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool requiredField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: requiredField
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return "$label is required";
                }
                return null;
              }
            : null,
      ),
    );
  }
//==========================================================
// REUSABLE DROPDOWN
//==========================================================

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
    bool requiredField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        items: items
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(e),
              ),
            )
            .toList(),
        onChanged: onChanged,
        validator: requiredField
            ? (value) {
                if (value == null || value.isEmpty) {
                  return "$label is required";
                }
                return null;
              }
            : null,
      ),
    );
  }
//==========================================================
// UI
//==========================================================

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        title: Text(
          isEdit ? "Edit Scheme" : "Add Scheme",
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //====================================================
              // BASIC INFORMATION
              //====================================================

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Basic Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _nameController,
                        label: "Scheme Name",
                        icon: Icons.account_balance,
                        requiredField: true,
                      ),
                      _buildDropdown(
                        label: "Category",
                        icon: Icons.category,
                        items: _categories,
                        value: _selectedCategory,
                        requiredField: true,
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                      _buildDropdown(
                        label: "Status",
                        icon: Icons.toggle_on,
                        items: _statusList,
                        value: _selectedStatus,
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                      _buildTextField(
                        controller: _descriptionController,
                        label: "Description",
                        icon: Icons.description,
                        maxLines: 4,
                        requiredField: true,
                      ),
                      _buildTextField(
                        controller: _benefitsController,
                        label: "Benefits",
                        icon: Icons.workspace_premium,
                        maxLines: 4,
                        requiredField: true,
                      ),
                      _buildTextField(
                        controller: _eligibilityController,
                        label: "Eligibility",
                        icon: Icons.fact_check,
                        maxLines: 4,
                        requiredField: true,
                      ),
                      _buildTextField(
                        controller: _howToApplyController,
                        label: "How To Apply",
                        icon: Icons.assignment,
                        maxLines: 4,
                        requiredField: true,
                      ),
                      _buildTextField(
                        controller: _websiteController,
                        label: "Official Website",
                        icon: Icons.language,
                      ),
                      _buildTextField(
                        controller: _documentsController,
                        label: "Required Documents (comma separated)",
                        icon: Icons.description_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 20),
                      const Text(
                        "Eligibility Conditions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildDropdown(
                        label: "Gender",
                        icon: Icons.person,
                        items: _genderList,
                        value: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                      ),
                      _buildDropdown(
                        label: "Occupation",
                        icon: Icons.work,
                        items: _occupationList,
                        value: _selectedOccupation,
                        onChanged: (value) {
                          setState(() {
                            _selectedOccupation = value;
                          });
                        },
                      ),
                      _buildDropdown(
                        label: "State",
                        icon: Icons.location_on,
                        items: _stateList,
                        value: _selectedState,
                        onChanged: (value) {
                          setState(() {
                            _selectedState = value;
                          });
                        },
                      ),
                      _buildDropdown(
                        label: "Caste Category",
                        icon: Icons.groups,
                        items: _casteList,
                        value: _selectedCaste,
                        onChanged: (value) {
                          setState(() {
                            _selectedCaste = value;
                          });
                        },
                      ),
                      DropdownButtonFormField<bool>(
                        value: _isBPL,
                        decoration: InputDecoration(
                          labelText: "BPL Required",
                          prefixIcon: const Icon(Icons.verified_user),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text("Any"),
                          ),
                          DropdownMenuItem(
                            value: true,
                            child: Text("Yes"),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text("No"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _isBPL = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _minAgeController,
                              label: "Min Age",
                              icon: Icons.cake,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _maxAgeController,
                              label: "Max Age",
                              icon: Icons.cake_outlined,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _minIncomeController,
                              label: "Min Income",
                              icon: Icons.currency_rupee,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _maxIncomeController,
                              label: "Max Income",
                              icon: Icons.currency_rupee,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _saving
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                    },
                              icon: const Icon(Icons.close),
                              label: const Text("Cancel"),
                            ),
                            ElevatedButton.icon(
                              onPressed: _saving ? null : _saveScheme,
                              icon: _saving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      isEdit ? Icons.save : Icons.add,
                                    ),
                              label: Text(
                                _saving
                                    ? "Saving..."
                                    : isEdit
                                        ? "Update Scheme"
                                        : "Save Scheme",
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
