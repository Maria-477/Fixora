import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/notification_service.dart';

final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  return NotificationService().getUnreadCount();
});