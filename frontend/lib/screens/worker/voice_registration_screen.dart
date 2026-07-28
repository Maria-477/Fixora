import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/speech_service.dart';
import '../../services/worker_service.dart';

class VoiceRegistrationScreen extends StatefulWidget {
  const VoiceRegistrationScreen({super.key});

  @override
 State<VoiceRegistrationScreen> createState() =>
      _VoiceRegistrationScreenState();
}

class _VoiceRegistrationScreenState
    extends State<VoiceRegistrationScreen> {
  final _speechService = SpeechService();
  final _workerService = WorkerService();

  String _transcript = '';
  bool _isListening = false;
  bool _isProcessing = false;
  String? _error;

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechService.stopListening();

      setState(() {
        _isListening = false;
      });

      return;
    }

    final ready = await _speechService.initialize();

    if (!ready) {
      setState(() {
        _error = 'Microphone permission is required.';
      });
      return;
    }

    setState(() {
      _isListening = true;
      _transcript = '';
      _error = null;
    });

    await _speechService.startListening(
      onResult: (text) {
        setState(() {
          _transcript = text;
        });
      },
      onDone: () {
        setState(() {
          _isListening = false;
        });
      },
    );
  }

  Future<void> _submitTranscript() async {
    if (_transcript.trim().isEmpty) {
      setState(() {
        _error = 'Please record something first.';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    final extracted =
        await _workerService.extractProfile(_transcript);

    setState(() {
      _isProcessing = false;
    });

    if (extracted == null) {
      setState(() {
        _error = 'Profile extraction failed.';
      });
      return;
    }

    if (!mounted) return;

    context.push(
      '/worker/confirm-profile',
      extra: extracted,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tell us about yourself'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              'Tap the microphone and tell us your name, city, profession and experience.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            GestureDetector(
              onTap: _toggleListening,
              child: CircleAvatar(
                radius: 56,
                backgroundColor: _isListening
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary,
                child: Icon(
                  _isListening
                      ? Icons.stop
                      : Icons.mic,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _transcript.isEmpty
                    ? 'Your words will appear here...'
                    : _transcript,
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ],

            const Spacer(),

            ElevatedButton(
              onPressed:
                  _isProcessing ? null : _submitTranscript,
              child: _isProcessing
                  ? const CircularProgressIndicator()
                  : const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}