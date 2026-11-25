import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> scheme;

  const DetailScreen({super.key, required this.scheme});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  bool _isApplying = false;

  Future<void> _applyOnPortal() async {
    final rawUrl = widget.scheme['applyUrl'] as String?;
    if (rawUrl == null || rawUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No portal URL available for this scheme')),
      );
      return;
    }

    try {
      final url = Uri.parse(rawUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open: $rawUrl')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid URL: $rawUrl')),
        );
      }
    }
  }

  Future<void> _trackApplication() async {
    final schemeId = widget.scheme['_id'] as String? ?? widget.scheme['id'] as String? ?? '';
    if (schemeId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Scheme ID missing')),
      );
      return;
    }

    setState(() => _isApplying = true);
    try {
      // Use the apiProvider for consistency
      await ref.read(apiProvider).applyToScheme(schemeId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application tracked! Check My Applications.'),
            backgroundColor: Colors.green,
          ),
        );
        context.push('/applications');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to track: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = widget.scheme;
    final docs = (scheme['documentsNeeded'] as List?)?.cast<String>() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(scheme['name'] ?? 'Scheme Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Match percentage badge ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                // Use withOpacity for compatibility unless we are certain of Flutter version
                // but if deprecated, we can use the opacity in the color constructor
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified, color: Colors.teal, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Match: ${scheme['matchPercentage'] ?? 0}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Description
            Text(
              scheme['description'] ?? 'No description available.',
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Ministry / Department
            if (scheme['department'] != null) ...[
              Text(
                'Ministry: ${scheme['department']}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 16),
            ],

            // Required documents
            const Text(
              'Required Documents:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(height: 10),
            if (docs.isEmpty)
              Text('No documents listed.',
                  style: TextStyle(color: Colors.grey[500]))
            else
              ...docs.map(
                    (doc) => ListTile(
                  leading: const Icon(Icons.document_scanner,
                      color: Color(0xFF378ADD)),
                  title: Text(doc),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),

            const SizedBox(height: 40),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.bookmark_add_outlined),
                    label: const Text('Track Application'),
                    onPressed: _isApplying ? null : _trackApplication,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Apply on Portal'),
                    onPressed: _applyOnPortal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
