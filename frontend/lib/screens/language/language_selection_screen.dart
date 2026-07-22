import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/language_provider.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Choose your language',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _LanguageButton(
                label: 'English',
                language: AppLanguage.english,
                ref: ref,
                context: context,
              ),
              const SizedBox(height: 16),
              _LanguageButton(
                label: 'اردو',
                language: AppLanguage.urdu,
                ref: ref,
                context: context,
              ),
              const SizedBox(height: 16),
              _LanguageButton(
                label: 'ਪੰਜਾਬੀ',
                language: AppLanguage.punjabi,
                ref: ref,
                context: context,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final AppLanguage language;
  final WidgetRef ref;
  final BuildContext context;

  const _LanguageButton({
    required this.label,
    required this.language,
    required this.ref,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await ref.read(languageProvider.notifier).setLanguage(language);

        if (context.mounted) {
          context.go('/login');
        }
      },
      child: Text(
        label,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}