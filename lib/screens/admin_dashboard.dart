import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import 'application_details_screen.dart';
import 'scheme_management.dart';

//  Admin Dashboard
//  Route: '/admin'
//  Access: login with role = 'admin'
//  No navigation bugs — kept mostly as original
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ApiService _api = ApiService();

  Map<String, dynamic>? dashboard;
  List<dynamic> applications = [];
  Map<String, dynamic>? analytics;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final dashboardData = await _api.getAdminDashboard();
      final applicationData = await _api.getAdminApplications();
      final analyticsData = await _api.getAdminAnalytics();

      print("Dashboard: $dashboardData");
      print("Applications: $applicationData");
      print("Analytics: $analyticsData");

      setState(() {
        dashboard = dashboardData;
        applications = applicationData;
        analytics = analyticsData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (dashboard == null || analytics == null) {
      return const Scaffold(
        body: Center(
          child: Text("No data available"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text(
          "Scheme Saarthi",
          style: TextStyle(
            color: Color(0xff123A73),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await _api.logout();

              if (!mounted) return;

              context.go("/login");
            },
            icon: const Icon(
              Icons.logout,
              color: Color(0xff123A73),
            ),
            label: const Text(
              "Logout",
              style: TextStyle(
                color: Color(0xff123A73),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAdminData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(),

              const SizedBox(height: 20),

              // Horizontal Stats
              _buildStatsSection(),

              const SizedBox(height: 20),

              // Status Overview
              _buildStatusOverview(),

              const SizedBox(height: 20),

              // Recent Applications
              _buildRecentApplications(),

              const SizedBox(height: 20),

              // Latest Applications
              _buildLatestApplications(),

              const SizedBox(height: 30),

              // Footer
              _buildFooter(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          if (isMobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome Back 👋",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff123A73),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Manage schemes, users and applications from one place.",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SchemeManagementScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.description_outlined),
                    label: const Text(
                      "Manage Schemes",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back 👋",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff123A73),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Manage schemes, users and applications from one place.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SchemeManagementScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.description_outlined),
                  label: const Text(
                    "Manage Schemes",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsSection() {
    return SizedBox(
      height: 170,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(
            "Users",
            dashboard!["stats"]["totalUsers"].toString(),
            Icons.people_alt_rounded,
            const Color(0xff1565C0),
          ),
          const SizedBox(width: 14),
          _buildStatCard(
            "Schemes",
            dashboard!["stats"]["totalSchemes"].toString(),
            Icons.account_balance,
            Colors.deepPurple,
          ),
          const SizedBox(width: 14),
          _buildStatCard(
            "Applications",
            dashboard!["stats"]["totalApplications"].toString(),
            Icons.description_outlined,
            Colors.orange,
          ),
          const SizedBox(width: 14),
          _buildStatCard(
            "Profiles",
            dashboard!["stats"]["totalProfiles"].toString(),
            Icons.person_outline,
            Colors.green,
          ),
          const SizedBox(width: 14),
          _buildStatCard(
            "Saved",
            dashboard!["stats"]["totalSavedSchemes"].toString(),
            Icons.bookmark_outline,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(.12),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOverview() {
    final approved = analytics?["analytics"]["approved"] ?? 0;
    final pending = analytics?["analytics"]["pending"] ?? 0;
    final rejected = analytics?["analytics"]["rejected"] ?? 0;

    final total = approved + pending + rejected;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Application Status Overview",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff123A73),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 45,
                sectionsSpace: 3,
                sections: total == 0
                    ? [
                        PieChartSectionData(
                          value: 1,
                          color: Colors.grey.shade300,
                          radius: 45,
                          title: "",
                        ),
                      ]
                    : [
                        PieChartSectionData(
                          value: approved.toDouble(),
                          color: Colors.green,
                          radius: 45,
                          title: "",
                        ),
                        PieChartSectionData(
                          value: pending.toDouble(),
                          color: Colors.orange,
                          radius: 45,
                          title: "",
                        ),
                        PieChartSectionData(
                          value: rejected.toDouble(),
                          color: Colors.red,
                          radius: 45,
                          title: "",
                        ),
                      ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildLegend(
            Colors.green,
            "Approved",
            approved.toString(),
          ),
          const SizedBox(height: 10),
          _buildLegend(
            Colors.orange,
            "Pending",
            pending.toString(),
          ),
          const SizedBox(height: 10),
          _buildLegend(
            Colors.red,
            "Rejected",
            rejected.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(
    Color color,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentApplications() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Recent Applications",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff123A73),
                ),
              ),
              const Spacer(),
              const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 15),
          if (applications.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "No recent applications",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...applications
                .take(3)
                .map((app) => _recentApplicationTile(app))
                .toList(),
        ],
      ),
    );
  }

  Widget _recentApplicationTile(Map<String, dynamic> app) {
    final applicant = app["user"]?["profile"]?["name"] ?? "Unknown";

    final scheme = app["scheme"]?["name"] ?? "Unknown Scheme";

    final status = app["status"] ?? "PENDING";

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

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: statusColor.withOpacity(.15),
            child: Text(
              applicant.isNotEmpty ? applicant[0].toUpperCase() : "U",
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  applicant,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  scheme,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestApplications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Latest Applications",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xff123A73),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // Future: Navigate to full applications page
              },
              child: const Text("View All"),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (applications.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 50,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "No applications found",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...applications.map(
            (app) => _applicationCard(app),
          ),
      ],
    );
  }

  Widget _applicationCard(Map<String, dynamic> app) {
    final applicant = app["user"]?["profile"]?["name"] ?? "Unknown";

    final scheme = app["scheme"]?["name"] ?? "Unknown Scheme";

    final status = app["status"] ?? "PENDING";

    final date = app["submittedAt"] != null
        ? app["submittedAt"].toString().split("T").first
        : "-";

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ApplicationDetailScreen(
              applicationId: app["id"],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue.withOpacity(.1),
                  child: Text(
                    applicant.isNotEmpty ? applicant[0].toUpperCase() : "U",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        applicant,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        scheme,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusChip(status),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 420;

                if (isMobile) {
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.visibility),
                          label: const Text("View"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ApplicationDetailScreen(
                                  applicationId: app["id"],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.check),
                              label: const Text("Approve"),
                              onPressed: () async {
                                try {
                                  await _api.updateApplicationStatus(
                                    app["id"],
                                    "APPROVED",
                                  );

                                  if (!mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Application Approved"),
                                    ),
                                  );

                                  await _loadAdminData();
                                } catch (e) {}
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              icon: const Icon(Icons.close),
                              label: const Text("Reject"),
                              onPressed: () async {
                                try {
                                  await _api.updateApplicationStatus(
                                    app["id"],
                                    "REJECTED",
                                  );

                                  if (!mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Application Rejected"),
                                    ),
                                  );

                                  await _loadAdminData();
                                } catch (e) {}
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.visibility),
                        label: const Text("View"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ApplicationDetailScreen(
                                applicationId: app["id"],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text("Approve"),
                        onPressed: () async {
                          await _api.updateApplicationStatus(
                            app["id"],
                            "APPROVED",
                          );

                          await _loadAdminData();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        icon: const Icon(Icons.close),
                        label: const Text("Reject"),
                        onPressed: () async {
                          await _api.updateApplicationStatus(
                            app["id"],
                            "REJECTED",
                          );

                          await _loadAdminData();
                        },
                      ),
                    ),
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: const [
            Divider(),
            SizedBox(height: 15),
            Text(
              "Scheme Saarthi",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xff123A73),
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Government Scheme Management System",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
            SizedBox(height: 15),
            Text(
              "© 2026 All Rights Reserved",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toUpperCase()) {
      case "APPROVED":
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        break;

      case "REJECTED":
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        break;

      default:
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xff123A73),
        ),
      ),
    );
  }
}
