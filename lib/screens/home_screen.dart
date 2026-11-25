import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

import 'applications_screen.dart';
import 'profile_screen.dart';

const Color kNavy = Color(0xFF0C447C);
const Color kMidBlue = Color(0xFF378ADD);
const Color kBgBlue = Color(0xFFF4F8FD);

class HomeScreen extends StatefulWidget {
  final int initialTab;

  const HomeScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _schemesFuture;
  final GlobalKey _topMatchedKey = GlobalKey();

  Set<String> _appliedSchemeIds = {};
  List<dynamic> _applications = [];

  late int _selectedIndex;

  // Default fallback name
  String _userName = "Citizen";
  String? _profilePhotoUrl;

  @override
  void initState() {
    super.initState();

    print("Initial Tab = ${widget.initialTab}");

    _selectedIndex = widget.initialTab;

    _loadData();
  }

  void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });
}

  Future<void> _loadData() async {
    // 1. Fetch Schemes
    setState(() {
      _schemesFuture = _apiService.getEligibleSchemes();
    });

    // 2. Fetch User Profile Data from Backend
    final profileData = await _apiService.getUserProfile();

    if (mounted && profileData != null) {
      setState(() {
        if (profileData['name'] != null &&
            profileData['name'].toString().trim().isNotEmpty) {
          _userName = profileData['name'];
        }

        _profilePhotoUrl = profileData['profilePhotoUrl'];
      });
    }
    final applications = await _apiService.getMyApplications();

    if (mounted) {
      setState(() {
        _applications = applications;
        _appliedSchemeIds = applications
            .map<String>((app) => app['schemeId'].toString())
            .toSet();
      });
    }
  }

  void _logout() async {
    await _apiService.logout();
    if (!mounted) return;

    context.go('/auth');
  }

  void _scrollToTopMatched() {
  final context = _topMatchedKey.currentContext;

  if (context != null) {
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
    );
  }
}

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String number,
    required String title,
  }) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            number,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeroCard(int totalSchemes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xff1565C0),
            Color(0xff42A5F5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "You are eligible for",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "$totalSchemes Schemes",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Based on your profile details",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
  onPressed: _scrollToTopMatched,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff11479A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Explore Schemes",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward)
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: 18),
          Container(
            height: 120,
            width: 110,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              size: 70,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSchemesFeed() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: kMidBlue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, $_userName 👋",
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: kNavy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Let's find the right schemes for you",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xffEAF3FF),
                  backgroundImage:
                      (_profilePhotoUrl != null && _profilePhotoUrl!.isNotEmpty)
                          ? NetworkImage(_profilePhotoUrl!)
                          : null,
                  child: _profilePhotoUrl == null
                      ? const Icon(
                          Icons.person,
                          color: kMidBlue,
                          size: 34,
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 24),
            FutureBuilder<List<dynamic>>(
              future: _schemesFuture,
              builder: (context, snapshot) {
                final schemes = snapshot.data ?? [];

                return _buildHeroCard(schemes.length);
              },
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Application Status",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kNavy,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/applications');
                  },
                  child: const Text("View All"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                _onItemTapped(1); // Opens Applications tab
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: FutureBuilder<List<dynamic>>(
                  future: _schemesFuture,
                  builder: (context, snapshot) {
                    final total = snapshot.data?.length ?? 0;

                    // These will work if you store the complete applications list.
                    final pending = _applications
                        .where((app) =>
                            app['status'].toString().toUpperCase() == 'PENDING')
                        .length;

                    final approved = _applications
                        .where((app) =>
                            app['status'].toString().toUpperCase() ==
                            'APPROVED')
                        .length;

                    final rejected = _applications
                        .where((app) =>
                            app['status'].toString().toUpperCase() ==
                            'REJECTED')
                        .length;

                    return Row(
                      children: [
                        _buildStatItem(
                          icon: Icons.verified,
                          color: Colors.green,
                          number: "$total",
                          title: "Eligible",
                        ),
                        _buildStatItem(
                          icon: Icons.pending_actions,
                          color: Colors.orange,
                          number: "$pending",
                          title: "Pending",
                        ),
                        _buildStatItem(
                          icon: Icons.check_circle,
                          color: Colors.blue,
                          number: "$approved",
                          title: "Approved",
                        ),
                        _buildStatItem(
                          icon: Icons.cancel,
                          color: Colors.red,
                          number: "$rejected",
                          title: "Rejected",
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  context.push('/applications');
                },
                icon: const Icon(Icons.folder_open),
                label: const Text("View All Applications"),
              ),
            ),
            const SizedBox(height: 30),
            Container(
  key: _topMatchedKey,
  child: const Text(
    "Top Matched Schemes",
    style: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: kNavy,
    ),
  ),
),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            FutureBuilder<List<dynamic>>(
              future: _schemesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: kMidBlue),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Could not load schemes.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                final schemes = snapshot.data ?? [];

                if (schemes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.folder_off_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No eligible schemes found yet.\nUpdate your profile to see more!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    ...List.generate(schemes.length, (index) {
                      final scheme = Map<String, dynamic>.from(schemes[index]);
                      final bool isApplied =
                          _appliedSchemeIds.contains(scheme['id']);

                      return InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () async {
                          await context.push(
                            '/scheme_detail',
                            extra: scheme,
                          );

                          _loadData();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(.08),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              /// Top Row
                              Row(
                                children: [
                                  Container(
                                    height: 55,
                                    width: 55,
                                    decoration: BoxDecoration(
                                      color: const Color(0xffE8F2FF),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.account_balance_rounded,
                                      color: kMidBlue,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          scheme['name'] ?? '',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: kNavy,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          scheme['category'] ?? '',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Text(
                                      "${scheme['matchPercentage'] ?? 100}%",
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              Text(
                                scheme['description'] ?? '',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  height: 1.45,
                                ),
                              ),

                              const SizedBox(height: 18),

                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffEEF6FF),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      scheme['category'] ?? 'General',
                                      style: const TextStyle(
                                        color: kMidBlue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await context.push(
                                        '/scheme_detail',
                                        extra: scheme,
                                      );

                                      _loadData();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: kMidBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          isApplied ? "Applied" : "View",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(
                                          isApplied
                                              ? Icons.check_circle
                                              : Icons.arrow_forward,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xffEDF5FF),
                            Color(0xffDCEBFF),
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.person_search,
                            color: kMidBlue,
                            size: 50,
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "Not finding the right schemes?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: kNavy,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Update your profile to improve your recommendations.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _onItemTapped(2),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kMidBlue,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                "Update Profile",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        centerTitle: false,
        title: Row(
          children: [
            // Using your uploaded custom app logo
            Image.asset(
              'assets/image_001137.png',
              height: 32,
              width: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            const Text('Scheme Sarthi',
                style: TextStyle(
                    color: kNavy,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: -0.5)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: kNavy,
              size: 28,
            ),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: kNavy,
            ),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildSchemesFeed(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 15,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.transparent,
            selectedItemColor: kNavy,
            unselectedItemColor: Colors.grey.shade400,
            showUnselectedLabels: true,
            selectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_filled),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
