import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';
import '../../services/api_client.dart';

class SetLocationScreen extends StatefulWidget {
  final String redirectTo;
  const SetLocationScreen({super.key, required this.redirectTo});

  @override
  State<SetLocationScreen> createState() => _SetLocationScreenState();
}

class _SetLocationScreenState extends State<SetLocationScreen> {
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _locationService = LocationService();
  bool _isSaving = false;
  bool _isLoadingExisting = true;
  bool _hasExistingLocation = false;
  String? _error;
  bool _showOpenSettings = false;

  @override
  void initState() {
    super.initState();
    _loadExistingLocation();
  }

  Future<void> _loadExistingLocation() async {
    try {
      final response = await ApiClient().dio.get('/locations/me');
      setState(() {
        _addressController.text = response.data['address_line'] ?? '';
        _cityController.text = response.data['city'] ?? '';
        _hasExistingLocation = true;
        _isLoadingExisting = false;
      });
    } catch (e) {
      // 404 = no location set yet — that's fine, just leave fields empty
      setState(() => _isLoadingExisting = false);
    }
  }

  Future<void> _save() async {
    if (_addressController.text.trim().isEmpty || _cityController.text.trim().isEmpty) {
      setState(() => _error = 'Please fill in both fields');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
      _showOpenSettings = false;
    });

    final result = await _locationService.saveCurrentLocation(
      addressLine: _addressController.text.trim(),
      city: _cityController.text.trim(),
    );

    setState(() => _isSaving = false);

    switch (result) {
      case LocationSaveResult.success:
        if (mounted) context.go(widget.redirectTo);
        break;
      case LocationSaveResult.serviceDisabled:
        setState(() => _error = 'Please turn on Location in your phone settings, then try again.');
        break;
      case LocationSaveResult.permissionDeniedForever:
        setState(() {
          _error = 'Location permission was denied before. Tap below to allow it in settings.';
          _showOpenSettings = true;
        });
        break;
      case LocationSaveResult.permissionDenied:
        setState(() => _error = 'Location permission is needed to continue.');
        break;
      case LocationSaveResult.serverError:
        setState(() => _error = 'Could not save your location. Please try again.');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_hasExistingLocation ? 'Edit your location' : 'Set your location')),
      body: _isLoadingExisting
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('We use your current location to connect you with nearby jobs or workers.'),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    if (_showOpenSettings) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Geolocator.openAppSettings(),
                        child: const Text('Open app settings'),
                      ),
                    ],
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(_hasExistingLocation ? 'Update location' : 'Save location'),
                  ),
                ],
              ),
            ),
    );
  }
}