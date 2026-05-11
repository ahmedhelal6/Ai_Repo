import 'package:ai_fitness_coach/controllers/profile_controller.dart';
import 'package:ai_fitness_coach/core/theme/profile_theme.dart';
import 'package:ai_fitness_coach/models/user_data.dart';
import 'package:ai_fitness_coach/views/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'profile_widgets.dart';

class ProfileSettingsSection extends StatelessWidget {
  ProfileSettingsSection({
    super.key,
    required this.userData,
    required this.onChanged,
  });

  final UserData userData;
  final VoidCallback onChanged;

  final ProfileController controller = ProfileController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
      ),
      child: Column(
        children: [
          ProfileSettingsTile(
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            subtitle: 'Update your personal data',
            onTap: () => showEditProfileSheet(context),
          ),
          const AppDivider(),
          ProfileSettingsTile(
            icon: Icons.flag_rounded,
            title: 'Goal',
            subtitle: userData.goal?.isNotEmpty == true
                ? userData.goal!
                : 'No goal selected',
          ),
          const AppDivider(),
          ProfileSettingsTile(
            icon: Icons.wc_rounded,
            title: 'Gender',
            subtitle: userData.gender?.isNotEmpty == true
                ? userData.gender!
                : 'Not specified',
          ),
          const AppDivider(),
          ProfileSettingsTile(
            icon: Icons.mail_outline_rounded,
            title: 'Email',
            subtitle: userData.email?.isNotEmpty == true
                ? userData.email!
                : 'Not verified',
          ),
          const AppDivider(),
          ProfileSettingsTile(
            icon: Icons.logout_rounded,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            isLogout: true,
            onTap: () => logout(context),
          ),
        ],
      ),
    );
  }

  Future<void> showEditProfileSheet(BuildContext context) async {
    final nameController = TextEditingController(text: userData.userName ?? '');
    final ageController =
        TextEditingController(text: userData.age?.toString() ?? '');
    final heightController =
        TextEditingController(text: userData.height?.toString() ?? '');
    final weightController =
        TextEditingController(text: userData.weight?.toString() ?? '');

    String gender = userData.gender ?? 'Male';
    String goal = userData.goal ?? 'Stay Fit';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 14,
                right: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 12,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF121212),
                      Color(0xFF0A0A0A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withValues(alpha: .08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .45),
                      blurRadius: 30,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const BottomSheetHandle(),
                      const SizedBox(height: 18),

                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Edit Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      _ModernTextField(
                        controller: nameController,
                        label: 'User Name',
                        icon: Icons.person,
                      ),

                      const SizedBox(height: 14),

                      _ModernDropdownField(
                        label: 'Goal',
                        value: goal,
                        icon: Icons.flag,
                        items: const [
                          'Stay Fit',
                          'Build Muscle',
                          'Lose Weight',
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          setSheetState(() => goal = v);
                        },
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: _ModernTextField(
                              controller: ageController,
                              label: 'Age',
                              icon: Icons.cake,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ModernTextField(
                              controller: heightController,
                              label: 'Height',
                              icon: Icons.height,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ModernTextField(
                              controller: weightController,
                              label: 'Weight',
                              icon: Icons.monitor_weight,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () async {
                            await saveProfile(
                              context: context,
                              sheetContext: sheetContext,
                              name: nameController.text,
                              goal: goal,
                              gender: gender,
                              age: ageController.text,
                              height: heightController.text,
                              weight: weightController.text,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> saveProfile({
    required BuildContext context,
    required BuildContext sheetContext,
    required String name,
    required String goal,
    required String gender,
    required String age,
    required String height,
    required String weight,
  }) async {
    final userName = name.trim();
    final userAge = int.tryParse(age.trim());
    final userHeight = int.tryParse(height.trim());
    final userWeight = int.tryParse(weight.trim());

    if (userName.isEmpty ||
        goal.isEmpty ||
        userAge == null ||
        userHeight == null ||
        userWeight == null) {
      showMessage(context, 'Please enter valid data');
      return;
    }

    try {
      await controller.updateProfile(
        userData: userData,
        userName: userName,
        goal: goal,
        age: userAge,
        height: userHeight,
        weight: userWeight,
      );

      if (!sheetContext.mounted) return;
      Navigator.pop(sheetContext);

      onChanged();
      showMessage(context, 'Profile updated successfully');
    } catch (e) {
      showMessage(context, 'Failed to update profile');
    }
  }

  void logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await controller.logout();

                if (!context.mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OnboardingScreen(),
                  ),
                  (_) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _ModernTextField extends StatelessWidget {
  const _ModernTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: .05),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}

class _ModernDropdownField extends StatelessWidget {
  const _ModernDropdownField({
    required this.label,
    required this.value,
    required this.icon,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final IconData icon;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: const Color(0xFF1A1A1A),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: .05),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 1.2,
          ),
        ),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }
} 