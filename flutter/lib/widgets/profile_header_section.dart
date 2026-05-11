import 'dart:io';

import 'package:ai_fitness_coach/core/theme/profile_theme.dart';
import 'package:ai_fitness_coach/models/user_data.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'profile_widgets.dart';

class ProfileHeaderSection extends StatefulWidget {
  const ProfileHeaderSection({
    super.key,
    required this.userData,
    required this.onChanged,
  });

  final UserData userData;
  final VoidCallback onChanged;

  @override
  State<ProfileHeaderSection> createState() => _ProfileHeaderSectionState();
}

class _ProfileHeaderSectionState extends State<ProfileHeaderSection> {
  final ImagePicker picker = ImagePicker();

  String? localImagePath;

  @override
  void initState() {
    super.initState();
    localImagePath = widget.userData.imagePath;
  }

  @override
  void didUpdateWidget(covariant ProfileHeaderSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.userData.imagePath != oldWidget.userData.imagePath &&
        widget.userData.imagePath?.isNotEmpty == true) {
      localImagePath = widget.userData.imagePath;
    }
  }

  bool get hasImage => localImagePath?.isNotEmpty == true;

  String get displayName {
    if (widget.userData.userName?.trim().isNotEmpty == true) {
      return widget.userData.userName!.trim();
    }

    if (widget.userData.email?.contains('@') == true) {
      return widget.userData.email!.split('@').first;
    }

    return 'User';
  }

  String get email {
    if (widget.userData.email?.trim().isNotEmpty == true) {
      return widget.userData.email!.trim();
    }

    return 'No email added';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: showImageOptions,
            child: CircleAvatar(
              radius: 62,
              backgroundColor: AppColors.primary,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFF101010),
                backgroundImage:
                    hasImage ? FileImage(File(localImagePath!)) : null,
                child: hasImage
                    ? null
                    : const Icon(
                        Icons.person,
                        color: Colors.white38,
                        size: 55,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            email,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          ProfileActionButton(
            icon: Icons.photo_camera_back_rounded,
            title: 'Change profile photo',
            onTap: showImageOptions,
          ),
        ],
      ),
    );
  }

  void showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 14),
              const BottomSheetHandle(),
              const SizedBox(height: 14),
              SheetButton(
                icon: Icons.photo_library_outlined,
                title: 'Choose from gallery',
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
              SheetButton(
                icon: Icons.camera_alt_outlined,
                title: 'Take a photo',
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
              if (hasImage)
                SheetButton(
                  icon: Icons.delete_outline_rounded,
                  title: 'Remove current photo',
                  isDanger: true,
                  onTap: () {
                    Navigator.pop(context);
                    removeImage();
                  },
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final image = await picker.pickImage(source: source);

      if (image == null) return;

      final appDir = await getApplicationDocumentsDirectory();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();

      final savedImage = await File(image.path).copy(
        '${appDir.path}/$fileName.jpg',
      );

      final updatedUser = widget.userData.copyWith(
        imagePath: savedImage.path,
      );

      await updatedUser.save();

      if (!mounted) return;

      setState(() {
  localImagePath = savedImage.path;
});
widget.onChanged();

      showMessage('Profile photo updated successfully');
    } catch (e) {
      showMessage('Failed to pick image');
    }
  }

  Future<void> removeImage() async {
    try {
      final updatedUser = widget.userData.copyWith(
  clearImagePath: true,
);

await updatedUser.save();

if (!mounted) return;

setState(() {
  localImagePath = null;
});

widget.onChanged();

showMessage('Profile photo removed successfully');
    } catch (e) {
      showMessage('Failed to remove image');
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}