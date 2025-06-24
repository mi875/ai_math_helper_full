import 'package:ai_math_helper/services/authenticated_image_provider.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.radius,
    this.profileImageUrl,
    this.fallbackPhotoUrl,
    this.backgroundColor,
    this.iconColor,
    this.onTap,
    this.showEditButton = false,
    this.onEditPressed,
  });

  final double radius;
  final String? profileImageUrl;
  final String? fallbackPhotoUrl;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool showEditButton;
  final VoidCallback? onEditPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? 
          theme.colorScheme.primary.withOpacity(0.1),
      backgroundImage: _getImageProvider(),
      child: _getImageProvider() == null
          ? Icon(
              Icons.person,
              size: radius,
              color: iconColor ?? theme.colorScheme.primary,
            )
          : null,
    );

    if (onTap != null) {
      avatar = GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    if (showEditButton) {
      return Stack(
        children: [
          avatar,
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                ),
                onPressed: onEditPressed,
                iconSize: radius * 0.33, // Scale icon size with radius
              ),
            ),
          ),
        ],
      );
    }

    return avatar;
  }

  ImageProvider? _getImageProvider() {
    // Prioritize API profile image (needs authentication)
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      return AuthenticatedNetworkImage(profileImageUrl!);
    }
    
    // Fall back to Firebase profile image (no auth needed)
    if (fallbackPhotoUrl != null && fallbackPhotoUrl!.isNotEmpty) {
      return NetworkImage(fallbackPhotoUrl!);
    }
    
    return null;
  }
}