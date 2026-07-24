import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  final String? mockOtp;

  const OtpScreen({
    super.key,
    required this.phone,
    this.mockOtp,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    final isLoading =
        authState.status == AuthStatus.authenticating;

    ref.listen(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go('/home');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify your number'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter the code sent to ${widget.phone}',
                style:
                    Theme.of(context).textTheme.bodyLarge,
              ),

              if (widget.mockOtp != null) ...[
                const SizedBox(height: 8),
                Text(
                  '(Dev Mode - OTP: ${widget.mockOtp})',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              TextField(
                controller: _otpController,
                keyboardType:
                    TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  letterSpacing: 12,
                ),
                decoration:
                    const InputDecoration(
                  counterText: '',
                  border:
                      OutlineInputBorder(),
                ),
              ),

              if (authState.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  authState.errorMessage!,
                  style: TextStyle(
                    color:
                        Theme.of(context).colorScheme.error,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        ref
                            .read(authProvider.notifier)
                            .verifyOtp(
                              widget.phone,
                              _otpController.text.trim(),
                            );
                      },
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Verify'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}