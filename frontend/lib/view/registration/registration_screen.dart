import 'package:ai_math_helper/data/user/data/user_profile.dart';
import 'package:ai_math_helper/data/user/model/profile_model.dart';
import '../../l10n/localization_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  String? _selectedGrade;

  List<GradeOption> get _gradeOptions => [
    GradeOption(
      key: 'junior_high_1',
      displayName: L10n.get('juniorHigh1'),
      category: 'junior_high',
    ),
    GradeOption(
      key: 'junior_high_2',
      displayName: L10n.get('juniorHigh2'),
      category: 'junior_high',
    ),
    GradeOption(
      key: 'junior_high_3',
      displayName: L10n.get('juniorHigh3'),
      category: 'junior_high',
    ),
    GradeOption(
      key: 'senior_high_1',
      displayName: L10n.get('seniorHigh1'),
      category: 'senior_high',
    ),
    GradeOption(
      key: 'senior_high_2',
      displayName: L10n.get('seniorHigh2'),
      category: 'senior_high',
    ),
    GradeOption(
      key: 'senior_high_3',
      displayName: L10n.get('seniorHigh3'),
      category: 'senior_high',
    ),
    GradeOption(
      key: 'kosen_1',
      displayName: L10n.get('kosen1'),
      category: 'kosen',
    ),
    GradeOption(
      key: 'kosen_2',
      displayName: L10n.get('kosen2'),
      category: 'kosen',
    ),
    GradeOption(
      key: 'kosen_3',
      displayName: L10n.get('kosen3'),
      category: 'kosen',
    ),
    GradeOption(
      key: 'kosen_4',
      displayName: L10n.get('kosen4'),
      category: 'kosen',
    ),
    GradeOption(
      key: 'kosen_5',
      displayName: L10n.get('kosen5'),
      category: 'kosen',
    ),
  ];

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _completeRegistration() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final profileModel = ref.read(profileModelProvider.notifier);

    final success = await profileModel.completeRegistration(
      displayName: _displayNameController.text.trim(),
      grade: _selectedGrade!,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.get('userRegistrationTitle')),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Text(
              L10n.get('profileSetupTitle'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              L10n.get('profileSetupDescription'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _displayNameController,
                    decoration: InputDecoration(
                      labelText: L10n.get('displayNameFieldLabel'),
                      hintText: L10n.get('displayNameHintText'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return L10n.get('pleaseEnterDisplayName');
                      }
                      if (value.trim().length > 100) {
                        return L10n.get('displayNameTooLong');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedGrade,
                    decoration: InputDecoration(
                      labelText: L10n.get('gradeLevelFieldLabel'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.school),
                    ),
                    items: _gradeOptions.map((grade) {
                      return DropdownMenuItem<String>(
                        value: grade.key,
                        child: Text(grade.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGrade = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return L10n.get('pleaseSelectGrade');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  if (profileState.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              profileState.errorMessage!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ElevatedButton(
                    onPressed: profileState.isUpdating ? null : _completeRegistration,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: profileState.isUpdating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            L10n.get('registrationCompleteButton'),
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}