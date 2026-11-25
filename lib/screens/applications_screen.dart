import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

//  My Applications Screen
//  Navigation: accessible from home_screen AppBar icon
//              AND from results_screen drawer
//  Route: '/applications'  (pushed, not go'd — so back works)

class ApplicationsScreen extends ConsumerStatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  ConsumerState<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends ConsumerState<ApplicationsScreen> {
  late Future<List<dynamic>> _appsFuture;
  List<dynamic> applications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load live data using the provider
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      applications = await ref.read(apiProvider).getMyApplications();
    } catch (e) {
      applications = [];
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C447C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "My Applications",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadApplications,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Part 2
                  _buildInfoCard(),

                  const SizedBox(height: 20),

                  // Part 3
                  _buildApplicationHeader(),

                  const SizedBox(height: 16),

                  // Part 4
                  if (applications.isEmpty) ...[
                    _buildEmptyState(),
                  ] else ...[
                    ...applications.map(
                      (app) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _buildApplicationCard(app),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildBrowseSchemesCard(),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD8E6FF),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F0FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.description,
              color: Color(0xFF1565C0),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              "Track the status of all schemes\nyou have applied for",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.fact_check_outlined,
              color: Color(0xFF1565C0),
              size: 34,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationHeader() {
    return Row(
      children: [
        Text(
          "Applications (${applications.length})",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const Spacer(),
        Row(
          children: const [
            Icon(
              Icons.refresh,
              size: 20,
              color: Colors.grey,
            ),
            SizedBox(width: 6),
            Text(
              "Pull to refresh",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> app) {
    final String status = app["status"] ?? "PENDING";

    Color statusColor;

    switch (status.toUpperCase()) {
      case "APPROVED":
        statusColor = Colors.green;
        break;

      case "REJECTED":
        statusColor = Colors.red;
        break;

      default:
        statusColor = Colors.orange;
    } 
    final String schemeName = app["scheme"]?["name"] ?? "Scheme";

    final String appliedDate = app["submittedAt"].toString().substring(0, 10);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        context.push(
          "/scheme_detail",
          extra: app["scheme"],
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            /// Scheme Icon
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description_outlined,
                color: statusColor,
                size: 30,
              ),
            ),

            const SizedBox(width: 16),

            /// Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schemeName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Government of India",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Applied on: $appliedDate",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            /// Status + Arrow
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(.12),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowseSchemesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF5FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.travel_explore,
              color: Color(0xFF1565C0),
              size: 40,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            "Looking for new schemes?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Explore government schemes that match your profile and apply in just a few taps.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                context.go('/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.search),
              label: const Text(
                "Browse Schemes",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF5FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              size: 60,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No Applications Yet",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "You haven't applied for any government schemes yet.\nBrowse available schemes and submit your first application.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: 220,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                context.go('/home');
              },
              icon: const Icon(Icons.search),
              label: const Text("Browse Schemes"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
