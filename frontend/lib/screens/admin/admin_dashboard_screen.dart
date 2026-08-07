import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/admin_models.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin_service.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends ConsumerState<AdminDashboardScreen> {
  final _service = AdminService();

  AdminSummary? _summary;
  List<PendingVerification> _pending = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);

    final summary = await _service.getSummary();
    final pending = await _service.getPendingVerifications();

    if (!mounted) return;

    setState(() {
      _summary = summary;
      _pending = pending;
      _isLoading = false;
    });
  }

  Future<void> _review(
    int verificationId,
    bool approve,
  ) async {
    final success = await _service.reviewVerification(
      verificationId,
      approve,
    );

    if (success) {
      await _load();
    }
  }

  Widget _statCard(
    BuildContext context,
    String label,
    int value,
  ) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                '$value',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Admin Dashboard'),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await ref.read(authProvider.notifier).logout();

            if (context.mounted) {
              context.go('/login');
            }
          },
        ),
      ],
    ),
    body: _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_summary != null) ...[
                  Row(
                    children: [
                      _statCard(
                        context,
                        'Workers',
                        _summary!.totalWorkers,
                      ),
                      const SizedBox(width: 8),
                      _statCard(
                        context,
                        'Verified',
                        _summary!.verifiedWorkers,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _statCard(
                        context,
                        'Customers',
                        _summary!.totalCustomers,
                      ),
                      const SizedBox(width: 8),
                      _statCard(
                        context,
                        'Bookings',
                        _summary!.totalBookings,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            '${_summary!.pendingVerifications}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium,
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Pending Verifications',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                Text(
                  'Pending Verification Requests',
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 12),

                if (_pending.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'No pending verification requests.',
                      ),
                    ),
                  )
                else
                  ..._pending.map(
                    (v) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              v.workerName,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),

                            if (v.workerPhone != null)
                              Text(
                                v.workerPhone!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),

                            const SizedBox(height: 8),

                            if (v.skills.isNotEmpty)
                              Wrap(
                                spacing: 6,
                                children: v.skills
                                    .map(
                                      (s) => Chip(
                                        label: Text(
                                          s,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        padding: EdgeInsets.zero,
                                        visualDensity:
                                            VisualDensity.compact,
                                      ),
                                    )
                                    .toList(),
                              ),

                            const SizedBox(height: 8),

                            if (v.city != null)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(v.city!),
                                  if (v.experienceYears != null) ...[
                                    const SizedBox(width: 12),
                                    const Icon(
                                      Icons.work_outline,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${v.experienceYears} years',
                                    ),
                                  ],
                                ],
                              )
                            else
                              Text(
                                'Profile not completed yet',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .error,
                                  fontSize: 13,
                                ),
                              ),

                            if (v.bio != null &&
                                v.bio!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                v.bio!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall,
                              ),
                            ],

                            const SizedBox(height: 4),

                            Text(
                              'Submitted: ${v.submittedAt}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall,
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _review(
                                      v.verificationId,
                                      true,
                                    ),
                                    child: const Text(
                                      'Approve',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _review(
                                      v.verificationId,
                                      false,
                                    ),
                                    child: const Text(
                                      'Reject',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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