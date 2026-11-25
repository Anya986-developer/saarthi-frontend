import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_service.dart';
import 'add_edit_scheme_screen.dart';

class SchemeManagementScreen extends ConsumerStatefulWidget {
  const SchemeManagementScreen({super.key});

  @override
  ConsumerState<SchemeManagementScreen> createState() =>
      _SchemeManagementScreenState();
}

class _SchemeManagementScreenState
    extends ConsumerState<SchemeManagementScreen> {
  //---------------------------------------------------------
  // API
  //---------------------------------------------------------

  late final ApiService _api;

  //---------------------------------------------------------
  // Controllers
  //---------------------------------------------------------

  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  //---------------------------------------------------------
  // Data
  //---------------------------------------------------------

  List<dynamic> _schemes = [];

  bool _isLoading = true;
  String? _deletingSchemeId;

  //---------------------------------------------------------
  // Filters
  //---------------------------------------------------------

  String _selectedCategory = "All Categories";
  String _selectedStatus = "All Status";

  //---------------------------------------------------------
  // Statistics
  //---------------------------------------------------------

  int totalSchemes = 0;
  int activeSchemes = 0;
  int inactiveSchemes = 0;
  int totalCategories = 0;

  //---------------------------------------------------------
  // Category List
  //---------------------------------------------------------

  final List<String> categories = [
    "All Categories",
    "Agriculture & Farmers",
    "Housing & Shelter",
    "Business, Employment & MSME",
    "Education & Learning",
    "Financial Inclusion & Social Security",
    "Health & Wellness",
    "Women Empowerment",
    "Skill Development",
    "Youth",
    "Senior Citizens",
    "Disability",
    "Scholarship",
    "Insurance",
    "Others",
  ];

  //---------------------------------------------------------
  // Status List
  //---------------------------------------------------------

  final List<String> statusList = [
    "All Status",
    "Active",
    "Inactive",
  ];

  //---------------------------------------------------------
  // INIT
  //---------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _api = ref.read(apiProvider);

    _loadSchemes();

    _searchController.addListener(_onSearchChanged);
  }

  //---------------------------------------------------------
// SEARCH
//---------------------------------------------------------

  void _onSearchChanged() {
    setState(() {});

    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(
      const Duration(milliseconds: 500),
      _loadSchemes,
    );
  }

  //---------------------------------------------------------
  // LOAD SCHEMES
  //---------------------------------------------------------

  Future<void> _loadSchemes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final schemes = await _api.getAdminSchemes(
        search: _searchController.text.trim(),
        category: _selectedCategory,
      );

      final active = schemes.where(
        (e) => e["status"] == "Active",
      );

      final inactive = schemes.where(
        (e) => e["status"] == "Inactive",
      );

      final categorySet = <String>{};

      for (final scheme in schemes) {
        if (scheme["category"] != null) {
          categorySet.add(scheme["category"]);
        }
      }

      setState(() {
        _schemes = schemes;

        totalSchemes = schemes.length;
        activeSchemes = active.length;
        inactiveSchemes = inactive.length;
        totalCategories = categorySet.length;
      });
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      _isLoading = false;
    });
  }

  //---------------------------------------------------------
  // RESET FILTERS
  //---------------------------------------------------------

  Future<void> _resetFilters() async {
    _searchController.clear();

    _selectedCategory = "All Categories";
    _selectedStatus = "All Status";

    await _loadSchemes();
  }

  //---------------------------------------------------------
  // REFRESH
  //---------------------------------------------------------

  Future<void> _refresh() async {
    await _loadSchemes();
  }

  Future<void> _deleteScheme(String schemeId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Delete Scheme"),
          content: const Text(
            "Are you sure you want to delete this scheme?\n\nThis action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      setState(() {
        _deletingSchemeId = schemeId;
      });

      await _api.deleteScheme(schemeId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Scheme deleted successfully."),
          backgroundColor: Colors.green,
        ),
      );

      await _loadSchemes();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _deletingSchemeId = null;
        });
      }
    }
  }

  Future<void> _openSchemeForm({
    String? schemeId,
  }) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditSchemeScreen(
          schemeId: schemeId,
        ),
      ),
    );

    if (changed == true) {
      await _loadSchemes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            schemeId == null
                ? "Scheme added successfully."
                : "Scheme updated successfully.",
          ),
        ),
      );
    }
  }

  //---------------------------------------------------------
  // DISPOSE
  //---------------------------------------------------------

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  //---------------------------------------------------------
  // BUILD
  //---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    final filteredSchemes = _selectedStatus == "All Status"
        ? _schemes
        : _schemes
            .where(
              (scheme) => scheme["status"] == _selectedStatus,
            )
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        titleSpacing: 18,
        title: isMobile
            ? const Text(
                "Scheme Management",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Scheme Management",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "View, add, edit and manage all schemes",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: isMobile
                ? IconButton(
                    onPressed: () async {
                      await _openSchemeForm();
                    },
                    icon: const Icon(Icons.add_circle),
                  )
                : ElevatedButton.icon(
                    onPressed: () async {
                      await _openSchemeForm();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add New"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 42),
                    ),
                  ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //=========================
              // Part 2 starts here
              //=========================

              //======================================================
// SEARCH & FILTER SECTION
//======================================================

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    //--------------------------------------------------
                    // Search Box
                    //--------------------------------------------------

                    TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: "Search schemes...",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xff2563EB),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () async {
                                  _searchController.clear();
                                  await _loadSchemes();
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xffF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xff2563EB),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    //--------------------------------------------------
                    // Filters
                    //--------------------------------------------------

                    LayoutBuilder(
                      builder: (context, constraints) {
                        final mobile = constraints.maxWidth < 650;

                        if (mobile) {
                          return Column(
                            children: [
                              DropdownButtonFormField<String>(
                                value: _selectedCategory,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xffFAFAFA),
                                  prefixIcon: const Icon(Icons.grid_view),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                items: categories
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) async {
                                  if (value == null) return;

                                  setState(() {
                                    _selectedCategory = value;
                                  });

                                  await _loadSchemes();
                                },
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: _selectedStatus,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xffFAFAFA),
                                  prefixIcon: const Icon(Icons.tune),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                items: statusList
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) return;

                                  setState(() {
                                    _selectedStatus = value;
                                  });
                                },
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedCategory,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xffFAFAFA),
                                  prefixIcon: const Icon(Icons.grid_view),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                items: categories
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) async {
                                  if (value == null) return;

                                  setState(() {
                                    _selectedCategory = value;
                                  });

                                  await _loadSchemes();
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedStatus,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xffFAFAFA),
                                  prefixIcon: const Icon(Icons.tune),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                items: statusList
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) return;

                                  setState(() {
                                    _selectedStatus = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    //--------------------------------------------------
                    // Reset Filters Button
                    //--------------------------------------------------

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _resetFilters,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text(
                          "Reset Filters",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xff2563EB),
                          side: BorderSide(
                            color: Colors.blue.shade200,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

//======================================================
// Part 3 Starts Here (Statistics Cards)
//======================================================
//======================================================
// STATISTICS CARDS
//======================================================

              LayoutBuilder(
                builder: (context, constraints) {
                  final mobile = constraints.maxWidth < 700;

                  final cards = [
                    {
                      "title": "Total Schemes",
                      "value": totalSchemes.toString(),
                      "icon": Icons.description_outlined,
                      "color": const Color(0xff3B82F6),
                      "bg": const Color(0xffEEF5FF),
                    },
                    {
                      "title": "Active Schemes",
                      "value": activeSchemes.toString(),
                      "icon": Icons.check_circle_outline,
                      "color": const Color(0xff22C55E),
                      "bg": const Color(0xffEDFDF3),
                    },
                    {
                      "title": "Inactive Schemes",
                      "value": inactiveSchemes.toString(),
                      "icon": Icons.pause_circle_outline,
                      "color": const Color(0xffF59E0B),
                      "bg": const Color(0xffFFF8EB),
                    },
                    {
                      "title": "Categories",
                      "value": totalCategories.toString(),
                      "icon": Icons.sell_outlined,
                      "color": const Color(0xff8B5CF6),
                      "bg": const Color(0xffF5F0FF),
                    },
                  ];

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cards.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: mobile ? 2 : 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: mobile ? 1.15 : 1.25,
                    ),
                    itemBuilder: (context, index) {
                      final item = cards[index];

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.05),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: item["bg"] as Color,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item["icon"] as IconData,
                                color: item["color"] as Color,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              item["value"] as String,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff1F2937),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item["title"] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 24),

//======================================================
// SECTION HEADER
//======================================================

              Row(
                children: [
                  const Text(
                    "All Schemes",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    filteredSchemes.isEmpty
                        ? "Showing 0 schemes"
                        : "Showing 1–${filteredSchemes.length} of ${filteredSchemes.length} schemes",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

//======================================================
// Part 4 Starts Here
// Scheme List
//======================================================

              if (_isLoading)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, index) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xffF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 16,
                                    width: 180,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    height: 12,
                                    width: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    height: 12,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              width: 70,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              else

              //----------------------------------------------------
              // Local Status Filter
              //----------------------------------------------------

              if (filteredSchemes.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 60,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.description_outlined,
                          size: 46,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "No Schemes Found",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Try changing your search keywords or filters to find matching schemes.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton.icon(
                        onPressed: _resetFilters,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Reset Filters"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(170, 46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredSchemes.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: Colors.grey.shade200,
                    ),
                    itemBuilder: (context, index) {
                      final scheme = filteredSchemes[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final mobile = constraints.maxWidth < 650;

                            if (mobile) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.blue.shade50,
                                        child: Text(
                                          "${index + 1}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          scheme["name"] ?? "",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    scheme["category"] ?? "",
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    scheme["description"] ?? "",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: scheme["status"] == "Active"
                                              ? Colors.green.shade50
                                              : Colors.orange.shade50,
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Text(
                                          scheme["status"] ?? "",
                                          style: TextStyle(
                                            color: scheme["status"] == "Active"
                                                ? Colors.green
                                                : Colors.orange,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () async {
                                          await _openSchemeForm(
                                            schemeId: scheme["id"],
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed:
                                            _deletingSchemeId == scheme["id"]
                                                ? null
                                                : () {
                                                    _deleteScheme(
                                                      scheme["id"],
                                                    );
                                                  },
                                        icon: _deletingSchemeId == scheme["id"]
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                              ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }

                            //------------------------------------------------
                            // Desktop/Tablet Card
                            //------------------------------------------------

                            return Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.blue.shade50,
                                  child: Text(
                                    "${index + 1}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        scheme["name"] ?? "",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        scheme["category"] ?? "",
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        scheme["description"] ?? "",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: scheme["status"] == "Active"
                                            ? Colors.green.shade50
                                            : Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        scheme["status"] ?? "",
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 18),
                                IconButton(
                                  onPressed: () async {
                                    await _openSchemeForm(
                                      schemeId: scheme["id"],
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.blue,
                                  ),
                                ),
                                IconButton(
                                  onPressed: _deletingSchemeId == scheme["id"]
                                      ? null
                                      : () {
                                          _deleteScheme(
                                            scheme["id"],
                                          );
                                        },
                                  icon: _deletingSchemeId == scheme["id"]
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
