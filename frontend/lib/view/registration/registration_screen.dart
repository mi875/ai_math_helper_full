import 'package:ai_math_helper/data/user/data/user_profile.dart';
import 'package:ai_math_helper/data/user/model/profile_model.dart';
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

  final List<GradeOption> _gradeOptions = [
    const GradeOption(
      key: 'junior_high_1',
      displayName: '中学1年生',
      category: 'junior_high',
    ),
    const GradeOption(
      key: 'junior_high_2',
      displayName: '中学2年生',
      category: 'junior_high',
    ),
    const GradeOption(
      key: 'junior_high_3',
      displayName: '中学3年生',
      category: 'junior_high',
    ),
    const GradeOption(
      key: 'senior_high_1',
      displayName: '高校1年生',
      category: 'senior_high',
    ),
    const GradeOption(
      key: 'senior_high_2',
      displayName: '高校2年生',
      category: 'senior_high',
    ),
    const GradeOption(
      key: 'senior_high_3',
      displayName: '高校3年生',
      category: 'senior_high',
    ),
    const GradeOption(
      key: 'kosen_1',
      displayName: '高専1年生',
      category: 'kosen',
    ),
    const GradeOption(
      key: 'kosen_2',
      displayName: '高専2年生',
      category: 'kosen',
    ),
    const GradeOption(
      key: 'kosen_3',
      displayName: '高専3年生',
      category: 'kosen',
    ),
    const GradeOption(
      key: 'kosen_4',
      displayName: '高専4年生',
      category: 'kosen',
    ),
    const GradeOption(
      key: 'kosen_5',
      displayName: '高専5年生',
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
        title: const Text('ユーザー登録'),
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
              'プロフィール設定',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'アプリを使用するためにプロフィールを設定してください',
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
                    decoration: const InputDecoration(
                      labelText: '表示名',
                      hintText: '太郎',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '表示名を入力してください';
                      }
                      if (value.trim().length > 100) {
                        return '表示名は100文字以内で入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedGrade,
                    decoration: const InputDecoration(
                      labelText: '学年',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
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
                        return '学年を選択してください';
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
                        : const Text(
                            '登録完了',
                            style: TextStyle(fontSize: 16),
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