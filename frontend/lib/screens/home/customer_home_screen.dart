import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/notification_provider.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  void _openNotifications(BuildContext context, WidgetRef ref) async {
    await context.push('/notifications');
    ref.invalidate(unreadCountProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fixora'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final countAsync = ref.watch(unreadCountProvider);

              return countAsync.when(
                loading: () => IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
                error: (e, st) => IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => _openNotifications(context, ref),
                ),
                data: (count) => Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () => _openNotifications(context, ref),
                    ),
                    if (count > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
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