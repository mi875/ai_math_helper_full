import 'package:ai_math_helper/data/user/model/auth_model.dart';
import 'package:ai_math_helper/data/user/model/profile_model.dart';
import 'package:ai_math_helper/view/home/view.dart';
import 'package:ai_math_helper/view/loginPage/view.dart';
import 'package:ai_math_helper/view/registration/registration_screen.dart';
import 'package:ai_math_helper/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool? _needsRegistration;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkRegistrationStatus();
    });
  }

  Future<void> _checkRegistrationStatus() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });

      try {
        final profileModel = ref.read(profileModelProvider.notifier);
        final needsRegistration = await profileModel.checkRegistrationStatus();
        
        if (mounted) {
          setState(() {
            _needsRegistration = needsRegistration;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _needsRegistration = true; // Assume needs registration on error
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authModelProvider);
    
    // If user is not authenticated, show login page
    if (authState.user == null) {
      return const LoginPage(title: appName);
    }
    
    // Show loading while checking registration status
    if (_isLoading || _needsRegistration == null) {
      return const _LoadingScreen();
    }
    
    // Show appropriate screen based on registration status
    if (_needsRegistration!) {
      return const RegistrationScreen();
    } else {
      return const MyHomePage(title: appName);
    }
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'アカウントを確認中...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}