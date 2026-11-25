import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

// ── Riverpod provider for scheme list
// This is the Riverpod version of the schemes screen (used via drawer).
// The home_screen.dart uses a plain StatefulWidget + FutureBuilder.
// Both are valid; keep whichever you prefer and delete the other.

final schemesProvider = FutureProvider<List<dynamic>>((ref) async {
  return ApiService().getEligibleSchemes();
});

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schemesAsync = ref.watch(schemesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Matched Schemes')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF0C447C)),
              child: Text('Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            // Admin Dashboard entry
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Admin Dashboard'),
              // Use push so user can go back
              onTap: () => context.push('/admin'),
            ),
            // My Applications entry
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('My Applications'),
              // Use push so user can go back
              onTap: () => context.push('/applications'),
            ),
            // Profile entry
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Edit Profile'),
              onTap: () => context.push('/profile'),
            ),
            const Divider(),
            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout',
                  style: TextStyle(color: Colors.red)),
              onTap: () async {
                // Call ApiService directly — no apiProvider needed
                await ApiService().logout();
                if (context.mounted) {
                  context.go('/auth');
                }
              },
            ),
          ],
        ),
      ),
      body: schemesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Error loading schemes.\n$err',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
        data: (schemes) {
          if (schemes.isEmpty) {
            return const Center(
              child: Text('No schemes matched your profile.'),
            );
          }
          return ListView.builder(
            itemCount: schemes.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final scheme = schemes[index];
              if (scheme is! Map<String, dynamic>) {
                return const SizedBox.shrink();
              }
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    child: const Icon(Icons.verified, color: Colors.teal),
                  ),
                  title: Text(
                    scheme['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Eligibility: ${scheme['matchPercentage'] ?? 0}%',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  // Pass scheme map as extra — matches the '/detail' route
                  onTap: () => context.push('/scheme_detail', extra: scheme),
                ),
              );
            },
          );
        },
      ),
    );
  }
}