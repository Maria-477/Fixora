import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/booking_service.dart';
import '../../services/api_client.dart';

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

  DateTime? _selectedDateTime;
  int? _locationId;
  List<DateTime> _bookedSlots = [];

  PriceEstimate? _estimate;
  bool _isCheckingPrice = false;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _loadLocation();
    _loadBookedSlots();

    _descController.addListener(_onDescriptionChanged);
  }

  void _onDescriptionChanged() {
    // If the customer changes the description after checking
    // the price, the old price is no longer valid.
    if (_estimate != null) {
      setState(() => _estimate = null);
    }
  }

  Future<void> _loadLocation() async {
    try {
      final response = await ApiClient().dio.get('/locations/me');

      setState(() {
        _locationId = response.data['id'];
      });
    } catch (e) {
      // Location will be checked again when submitting.
    }
  }

  Future<void> _loadBookedSlots() async {
    final slots =
        await _bookingService.getWorkerBookedSlots(widget.workerId);

    setState(() {
      _bookedSlots = slots;
    });
  }

  Future<void> _checkPrice() async {
  if (_descController.text.trim().isEmpty) {
    setState(() {
      _error = 'Please describe the job first';
    });
    return;
  }

  setState(() {
    _isCheckingPrice = true;
    _error = null;
  });

  final estimate = await _bookingService.estimatePrice(
    workerId: widget.workerId,
    description: _descController.text.trim(),
  );

  if (!mounted) return;

  setState(() {
    _isCheckingPrice = false;
    _estimate = estimate;

    if (estimate == null) {
      _error = 'Could not calculate a price right now. Please try again.';
    }
  });
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 30),
      ),
      initialDate: DateTime.now().add(
        const Duration(days: 1),
      ),
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

  bool get _isSlotTaken {
    if (_selectedDateTime == null) return false;

    return _bookedSlots.any(
      (s) =>
          s.year == _selectedDateTime!.year &&
          s.month == _selectedDateTime!.month &&
          s.day == _selectedDateTime!.day &&
          s.hour == _selectedDateTime!.hour &&
          s.minute == _selectedDateTime!.minute,
    );
  }

  Future<void> _submit() async {
    if (_locationId == null) {
      setState(() {
        _error =
            'Please set your location first, from the home screen';
      });
      return;
    }

    if (_estimate == null) {
      setState(() {
        _error = 'Please check the price before booking';
      });
      return;
    }

    if (_selectedDateTime == null) {
      setState(() {
        _error = 'Please pick a date and time';
      });
      return;
    }

    if (_isSlotTaken) {
      setState(() {
        _error =
            'This time slot is already booked. Please choose another.';
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
      suggestedPrice: _estimate!.suggestedPrice,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      context.go('/customer/bookings');
    } else {
      setState(() {
        _error = 'Could not create booking. Please try again.';
      });
    }
  }

  @override
  void dispose() {
    _descController.removeListener(_onDescriptionChanged);
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book this worker'),
      ),
      body: SingleChildScrollView(
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

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed:
                  _isCheckingPrice ? null : _checkPrice,
              icon: _isCheckingPrice
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.calculate_outlined,
                    ),
              label: Text(
                _isCheckingPrice
                    ? 'Calculating...'
                    : 'Check price',
              ),
            ),

            if (_estimate != null) ...[
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Estimated price',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PKR ${_estimate!.suggestedPrice.toStringAsFixed(0)}',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _estimate!.urgencyLevel == 'critical' || _estimate!.urgencyLevel == 'high'
                  ? Theme.of(context).colorScheme.errorContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _estimate!.urgencyLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    for (final note in _estimate!.riskNotes) ...[
                      const SizedBox(height: 4),
                      Text(
                         '• $note',
                         style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 20),

            if (_bookedSlots.isNotEmpty) ...[
              Text(
                'Already booked times:',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall,
              ),

              const SizedBox(height: 4),

              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _bookedSlots
                    .map(
                      (s) => Chip(
                        label: Text(
                          s.toString().substring(0, 16),
                          style:
                              const TextStyle(fontSize: 11),
                        ),
                        backgroundColor:
                            Theme.of(context)
                                .colorScheme
                                .errorContainer,
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 16),
            ],

            OutlinedButton.icon(
              onPressed: _pickDateTime,
              icon: const Icon(
                Icons.calendar_today,
              ),
              label: Text(
                _selectedDateTime == null
                    ? 'Pick date and time'
                    : _selectedDateTime
                        .toString()
                        .substring(0, 16),
              ),
            ),

            if (_isSlotTaken) ...[
              const SizedBox(height: 8),
              Text(
                'This slot is already booked',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .error,
                ),
              ),
            ],

            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .error,
                ),
              ),
            ],

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed:
                  _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Send booking request',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}