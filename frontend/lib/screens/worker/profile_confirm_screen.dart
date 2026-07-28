import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/worker_models.dart';
import '../../services/worker_service.dart';

class ProfileConfirmScreen extends StatefulWidget {
  final ExtractedProfile extracted;

  const ProfileConfirmScreen({
    super.key,
    required this.extracted,
  });

  @override
  State<ProfileConfirmScreen> createState() =>
      _ProfileConfirmScreenState();
}

class _ProfileConfirmScreenState
    extends State<ProfileConfirmScreen> {
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _experienceController;
  late TextEditingController _bioController;

  final _workerService = WorkerService();

  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.extracted.fullName ?? '',
    );

    _cityController = TextEditingController(
      text: widget.extracted.city ?? '',
    );

    _experienceController = TextEditingController(
      text: widget.extracted.experienceYears.toString(),
    );

    _bioController = TextEditingController(
      text: widget.extracted.bio,
    );
  }

  Future<void> _confirm() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    final success = await _workerService.saveProfile(
      fullName: _nameController.text.trim(),
      city: _cityController.text.trim(),
      experienceYears:
          int.tryParse(_experienceController.text.trim()) ?? 0,
      bio: _bioController.text.trim(),
      skillName: widget.extracted.skill,
    );

    setState(() {
      _isSaving = false;
    });

    if (success && mounted) {
      context.go('/home');
    } else {
      setState(() {
        _error = 'Could not save profile.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm your details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (widget.extracted.skill != null) ...[
                Chip(
                  label: Text(
                    'Detected trade: ${widget.extracted.skill}',
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _experienceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Years of experience',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed:
                    _isSaving ? null : _confirm,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Confirm and Save'),
              ),

              TextButton(
                onPressed: () => context.pop(),
                child: const Text(
                  'Go back and re-record',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}