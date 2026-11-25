import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service.dart';

const Color kNavy = Color(0xFF0C447C);
const Color kMidBlue = Color(0xFF378ADD);
const Color kBgBlue = Color(0xFFF4F8FD);

class SchemeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> scheme;

  const SchemeDetailScreen({
    super.key,
    required this.scheme,
  });

  @override
  State<SchemeDetailScreen> createState() => _SchemeDetailScreenState();
}

class _SchemeDetailScreenState extends State<SchemeDetailScreen> {
  bool _isApplying = false;

  Future<void> _apply() async {
    setState(() {
      _isApplying = true;
    });

    try {
      final api = ApiService();

      if (widget.scheme['eligible'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "You don't fully meet the eligibility criteria for this scheme.",
            ),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
  _isApplying = false;
});
        return;
      }

      await api.applyToScheme(
        widget.scheme['id'].toString(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 3),
          backgroundColor: Colors.green,
          content: Text(
            "Application submitted successfully.\nYour application has been sent for admin approval.",
          ),
        ),
      );

      context.go(
        '/home',
        extra: 1,
      );
    } catch (e) {
      final message = e.toString().replaceFirst("Exception: ", "");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isApplying = false;
      });
    }
  }

  Widget buildSection(
    String title,
    IconData icon,
    List items,
  ) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 18),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: kMidBlue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(e.toString()),
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

  @override
  Widget build(BuildContext context) {
    final scheme = widget.scheme;

    return Scaffold(
      backgroundColor: kBgBlue,
      appBar: AppBar(
        title: Text(
          scheme['name'] ?? "Scheme Details",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              scheme['name'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Chip(
                  label: Text(
                    "${scheme['matchPercentage'] ?? 100}% Match",
                  ),
                  backgroundColor: Colors.green.shade100,
                ),
                const SizedBox(width: 10),
                Chip(
                  label: Text(
                    scheme['eligible'] == true
                        ? "Eligible"
                        : "Partially Eligible",
                  ),
                  backgroundColor: scheme['eligible'] == true
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Description",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              scheme['description'] ?? "",
            ),
            const SizedBox(height: 25),
            buildSection(
              "Benefits",
              Icons.card_giftcard,
              (scheme['benefits'] ?? "").toString().split("|"),
            ),
            buildSection(
              "Eligibility",
              Icons.verified_user,
              (scheme['eligibility'] ?? "").toString().split("|"),
            ),
            buildSection(
              "Required Documents",
              Icons.description,
              List<String>.from(
                scheme['documentsRequired'] ?? [],
              ),
            ),
            buildSection(
              "How to Apply",
              Icons.assignment,
              (scheme['howToApply'] ?? "").toString().split("|"),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.language),
                title: const Text("Official Website"),
                subtitle: Text(
                  scheme['officialWebsite'] ?? "Not Available",
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.account_balance),
                title: const Text("Department"),
                subtitle: Text(
                  scheme['category'] ?? "General",
                ),
              ),
            ),
            if (scheme['reasons'] != null)
              buildSection(
                "Why Recommended",
                Icons.thumb_up,
                List<String>.from(scheme['reasons']),
              ),
            if (scheme['missing'] != null &&
                (scheme['missing'] as List).isNotEmpty)
              buildSection(
                "Missing Criteria",
                Icons.error,
                List<String>.from(scheme['missing']),
              ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isApplying ? null : _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kMidBlue,
                ),
                child: _isApplying
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "Apply Now",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
