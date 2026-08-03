import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/api_client.dart';
import '../../services/booking_service.dart';

class CreateBookingScreen extends StatefulWidget {
  final int workerId;

  const CreateBookingScreen({
    super.key,
    required this.workerId,
  });

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _descController = TextEditingController();
  final _bookingService = BookingService();

  int? _locationId;

  DateTime? _selectedDateTime;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      final response = await ApiClient().dio.get('/locations/me');

      setState(() {
        _locationId = response.data['id'];
      });
    } catch (e) {
      // location not saved
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (_locationId == null) {
      setState(() {
        _error = 'Please set your location first';
      });
      return;
    }

    if (_selectedDateTime == null ||
        _descController.text.trim().isEmpty) {
      setState(() {
        _error = 'Please pick a time and describe the job';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final success = await _bookingService.createBooking(
      workerId: widget.workerId,
      locationId: _locationId!,
      description: _descController.text.trim(),
      scheduledAt: _selectedDateTime!,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (success && mounted) {
      context.push('/customer/bookings');
    } else {
      setState(() {
        _error = 'Could not create booking. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book this worker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Describe the job',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickDateTime,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedDateTime == null
                    ? 'Pick date and time'
                    : _selectedDateTime.toString().substring(0, 16),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Send booking request'),
            ),
          ],
        ),
      ),
    );
  }
}