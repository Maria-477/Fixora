import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/worker_profile_provider.dart';

class WorkerDashboardScreen extends ConsumerWidget {
  const WorkerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(workerProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fixora — Worker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, st) => const Center(
          child: Text('Could not load profile'),
        ),
        data: (profile) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (profile == null) ...[
                const Text("You haven't set up your profile yet."),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.push('/worker/voice-registration'),
                  child: const Text('Set up my profile'),
                ),
              ] else ...[
                Text(
                  'Welcome, ${profile['full_name']}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  '${profile['city']} • ${profile['experience_years']} years experience',
                ),
                const SizedBox(height: 24),
              ],

              /// Location Button
              Consumer(
                builder: (context, ref, _) {
                  final locationAsync = ref.watch(locationProvider);

                  return locationAsync.when(
                    loading: () => const SizedBox(
                      height: 48,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (e, st) => ElevatedButton(
                      onPressed: () async {
                        await context.push('/set-location?redirect=/home');
                        ref.invalidate(locationProvider);
                      },
                      child: const Text('Set my location'),
                    ),
                    data: (location) => ElevatedButton(
                      onPressed: () async {
                        await context.push('/set-location?redirect=/home');
                        ref.invalidate(locationProvider);
                      },
                      child: Text(
                        location == null
                            ? 'Set my location'
                            : '📍 ${location['city']} — Edit',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: () => context.push('/worker/portfolio'),
                child: const Text('Manage my photos'),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: () => context.push('/worker/bookings'),
                child: const Text('My bookings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}