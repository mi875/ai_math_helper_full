import 'package:ai_math_helper/config.dart';
import 'package:ai_math_helper/data/user/model/auth_model.dart';
import 'package:ai_math_helper/l10n/localization_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authModelProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Icon
                Icon(
                  Icons.school_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),

                // App Title
                Text(
                  L10n.get('appName'),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),

                // App Description
                Text(
                  L10n.get('personalMathAssistant'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Google Sign-In Button (using ElevatedButton while following Google's brand guidelines)
                ElevatedButton(
                  onPressed:
                      authState.isLoading
                          ? null
                          : () =>
                              ref
                                  .read(authModelProvider.notifier)
                                  .signInWithGoogle(),
                  child:
                      authState.isLoading
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.grey,
                            ),
                          )
                          : Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/google_logo.webp',
                                height: 18,
                                width: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(L10n.get('signInWithGoogle')),
                            ],
                          ),
                ),

                // Error message
                if (authState.errorMessage != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      authState.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
