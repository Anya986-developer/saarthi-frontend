import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service.dart';

const Color kNavy = Color(0xFF0C447C);
const Color kMidBlue = Color(0xFF378ADD);
const Color kBgBlue = Color(0xFFF4F8FD);

class ProfileProcessingScreen extends StatefulWidget {
  const ProfileProcessingScreen({super.key});

  @override
  State<ProfileProcessingScreen> createState() =>
      _ProfileProcessingScreenState();
}

class _ProfileProcessingScreenState extends State<ProfileProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _evaluateSchemes();
    
  }


  Future<void> _evaluateSchemes() async {
    try {
      await ApiService().getEligibleSchemes();
      

      

      if (!mounted) return;

      context.go('/profile');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

      context.go('/profile');
    }
  }

    

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgBlue,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 70,
                    color: kMidBlue,
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  "Analyzing Your Profile",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: kNavy,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  "Please wait while we evaluate your eligibility for government schemes.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                const SizedBox(
                  width: 55,
                  height: 55,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    color: kMidBlue,
                  ),
                ),

                const SizedBox(height: 40),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person_outline, color: kMidBlue),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Verifying profile information",
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Icon(Icons.rule_folder_outlined, color: kMidBlue),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Checking eligibility rules",
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Icon(Icons.recommend_outlined, color: kMidBlue),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Finding best matching schemes",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  "This usually takes a few seconds...",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
