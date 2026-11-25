import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final String applicationId;

  const ApplicationDetailScreen({
    super.key,
    required this.applicationId,
  });

  @override
  State<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _error;

  Map<String, dynamic>? _application;

  @override
  void initState() {
    super.initState();
    _loadApplication();
  }

  Future<void> _loadApplication() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final application = await _apiService.getApplicationDetails(
        widget.applicationId,
      );

      setState(() {
        _application = application;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Applicant Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadApplication,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadApplication,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildApplicantCard(),
          const SizedBox(height: 16),
          _buildPersonalInformationCard(),
          const SizedBox(height: 16),
          _buildAppliedSchemeCard(),
          const SizedBox(height: 16),
          _buildDocumentsCard(),
          const SizedBox(height: 16),
          _buildStatusTimelineCard(),
          const SizedBox(height: 16),
          _buildAdminActionCard(),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String status) async {
    try {
      await _apiService.updateApplicationStatus(
        widget.applicationId,
        status,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Application marked as $status",
          ),
        ),
      );

      _loadApplication();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  Widget _buildApplicantCard() {
    final profile = _application?["user"]?["profile"];

    final user = _application?["user"];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: profile?["profilePhotoUrl"] != null
                  ? NetworkImage(
                      profile!["profilePhotoUrl"],
                    )
                  : null,
              child: profile?["profilePhotoUrl"] == null
                  ? const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    )
                  : null,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?["name"] ?? "Unknown",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?["phone"] ?? "",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _application?["status"] ?? "",
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInformationCard() {
    final profile = _application?["user"]?["profile"];

    Widget buildRow(
      IconData icon,
      String title,
      String value,
    ) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.blue,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Personal Information",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            buildRow(
              Icons.cake_outlined,
              "Age",
              "${profile?["age"] ?? "-"} Years",
            ),
            const Divider(),
            buildRow(
              Icons.person_outline,
              "Gender",
              profile?["gender"] ?? "-",
            ),
            const Divider(),
            buildRow(
              Icons.groups_outlined,
              "Category",
              profile?["category"] ?? "-",
            ),
            const Divider(),
            buildRow(
              Icons.work_outline,
              "Occupation",
              profile?["occupation"] ?? "-",
            ),
            const Divider(),
            buildRow(
              Icons.location_on_outlined,
              "State",
              profile?["state"] ?? "-",
            ),
            const Divider(),
            buildRow(
              Icons.currency_rupee,
              "Annual Income",
              "₹ ${profile?["income"] ?? "-"}",
            ),
            const Divider(),
            buildRow(
              Icons.verified_user_outlined,
              "BPL Status",
              profile?["isBPL"] == true ? "Yes" : "No",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppliedSchemeCard() {
    final scheme = _application?["scheme"];

    Widget buildTile(
      IconData icon,
      String title,
      String value,
    ) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Colors.blue,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Applied Scheme",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            buildTile(
              Icons.account_balance,
              "Scheme Name",
              scheme?["name"] ?? "-",
            ),
            const Divider(),
            buildTile(
              Icons.description_outlined,
              "Description",
              scheme?["description"] ?? "-",
            ),
            const Divider(),
            buildTile(
              Icons.card_giftcard,
              "Benefits",
              scheme?["benefits"] ?? "-",
            ),
            const Divider(),
            buildTile(
              Icons.language,
              "Official Website",
              scheme?["officialWebsite"] ?? "-",
            ),
            const Divider(),
            buildTile(
              Icons.calendar_today,
              "Applied On",
              _application?["submittedAt"] ?? "-",
            ),
            const Divider(),
            const Text(
              "Required Documents",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...(scheme?["documentsRequired"] as List<dynamic>? ?? []).map(
              (doc) => Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(doc.toString()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _documentName(String? category) {
    switch ((category ?? "").toUpperCase()) {
      case "AADHAAR":
        return "Aadhaar Card";

      case "CASTE":
        return "Caste Certificate";

      case "INCOME":
        return "Income Certificate";

      case "RESIDENCE":
        return "Residence Certificate";

      case "BANK":
        return "Bank Passbook";

      case "PHOTO":
        return "Passport Photo";

      default:
        return category ?? "Document";
    }
  }

  Widget _buildDocumentsCard() {
    final documents =
        _application?["user"]?["documents"] as List<dynamic>? ?? [];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Uploaded Documents",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (documents.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "No documents uploaded",
                  ),
                ),
              )
            else
              ...documents.map((doc) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Colors.grey.shade50,
                  child: ListTile(
                    leading: const Icon(
                      Icons.description,
                      color: Colors.blue,
                    ),
                    title: Text(
                      _documentName(doc["category"]),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      doc["status"] ?? "PENDING",
                    ),
                    trailing: Icon(
                      doc["status"] == "APPROVED"
                          ? Icons.check_circle
                          : doc["status"] == "REJECTED"
                              ? Icons.cancel
                              : Icons.pending,
                      color: doc["status"] == "APPROVED"
                          ? Colors.green
                          : doc["status"] == "REJECTED"
                              ? Colors.red
                              : Colors.orange,
                    ),
                    onTap: () async {
                      final documentId = doc["id"];

                      final response =
                          await _apiService.getAdminDocument(documentId);

                      final url = response["url"];

                      if (url != null) {
                        await launchUrl(
                          Uri.parse(url),
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimelineCard() {
    final status = _application?["status"] ?? "Pending";

    Widget buildStep(
      String title,
      bool completed,
    ) {
      return Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: completed ? Colors.green : Colors.grey.shade300,
            child: Icon(
              completed ? Icons.check : Icons.circle,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: completed ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Application Progress",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            buildStep(
              "Application Submitted",
              true,
            ),
            buildStep(
              "Under Review",
              status != "Pending",
            ),
            buildStep(
              "Approved",
              status == "Approved",
            ),
            buildStep(
              "Rejected",
              status == "Rejected",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminActionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Admin Actions",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _updateStatus("Approved"),
                icon: const Icon(Icons.check),
                label: const Text("Approve"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _updateStatus("Rejected"),
                icon: const Icon(Icons.close),
                label: const Text("Reject"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _updateStatus("Pending"),
                icon: const Icon(Icons.schedule),
                label: const Text("Mark Pending"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
