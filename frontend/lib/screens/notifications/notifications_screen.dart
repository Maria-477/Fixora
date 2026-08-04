import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/notification_models.dart';
import '../../providers/notification_provider.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends ConsumerState<NotificationsScreen> {
  final _service = NotificationService();

  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final notifications = await _service.getMyNotifications();

    setState(() {
      _notifications = notifications;
      _isLoading = false;
    });
  }

  Future<void> _openNotification(AppNotification n) async {
    if (!n.isRead) {
      await _service.markAsRead(n.id);

      ref.invalidate(unreadCountProvider);

      setState(() {
        _notifications = _notifications
            .map(
              (x) => x.id == n.id
                  ? AppNotification(
                      id: x.id,
                      title: x.title,
                      message: x.message,
                      isRead: true,
                      createdAt: x.createdAt,
                    )
                  : x,
            )
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _notifications.isEmpty
              ? const Center(
                  child: Text('No notifications yet'),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final n = _notifications[index];

                      return ListTile(
                        onTap: () => _openNotification(n),
                        leading: Icon(
                          n.isRead
                              ? Icons.notifications_none
                              : Icons.notifications,
                          color: n.isRead
                              ? null
                              : Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(
                          n.title,
                          style: TextStyle(
                            fontWeight: n.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(n.message),
                      );
                    },
                  ),
                ),
    );
  }
}