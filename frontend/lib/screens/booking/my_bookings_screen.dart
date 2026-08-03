import 'package:flutter/material.dart';
import '../../models/booking_models.dart';
import '../../services/booking_service.dart';

class MyBookingsScreen extends StatefulWidget {
  final bool isWorker;

  const MyBookingsScreen({super.key, required this.isWorker});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final _bookingService = BookingService();
  List<Booking> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
  try {
    print('Loading bookings...');
    final bookings = await _bookingService.getMyBookings();

    print('Bookings loaded: ${bookings.length}');

    setState(() {
      _bookings = bookings;
      _isLoading = false;
    });
  } catch (e, st) {
    print(e);
    print(st);

    setState(() {
      _isLoading = false;
    });
  }
}

  Future<void> _updateStatus(int bookingId, String status) async {
    final success = await _bookingService.updateStatus(bookingId, status);
    if (success) _load();
  }

  Color _statusColor(String status, BuildContext context) {
    switch (status) {
      case 'confirmed':
      case 'in_progress':
        return Theme.of(context).colorScheme.primary;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Theme.of(context).colorScheme.error;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My bookings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(child: Text('No bookings yet'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final b = _bookings[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.isWorker ? (b.customerName ?? 'Customer') : (b.workerName ?? 'Worker'),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(b.serviceDescription ?? ''),
                              const SizedBox(height: 8),
                              Chip(
                                label: Text(b.status),
                                backgroundColor: _statusColor(b.status, context).withOpacity(0.15),
                                labelStyle: TextStyle(color: _statusColor(b.status, context)),
                              ),
                              if (widget.isWorker && b.status == 'pending') ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => _updateStatus(b.id, 'confirmed'),
                                        child: const Text('Accept'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _updateStatus(b.id, 'cancelled'),
                                        child: const Text('Decline'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (widget.isWorker && b.status == 'confirmed') ...[
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () => _updateStatus(b.id, 'in_progress'),
                                  child: const Text('Start job'),
                                ),
                              ],
                              if (widget.isWorker && b.status == 'in_progress') ...[
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () => _updateStatus(b.id, 'completed'),
                                  child: const Text('Mark completed'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}