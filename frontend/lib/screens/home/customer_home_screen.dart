import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fixora'),
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome, ${user?.fullName ?? "Customer"}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 24),

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
              onPressed: () => context.push('/customer/search'),
              child: const Text('Find a worker'),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () => context.push('/customer/bookings'),
              child: const Text('My bookings'),
            ),
          ],
        ),
      ),
    );
  }
}