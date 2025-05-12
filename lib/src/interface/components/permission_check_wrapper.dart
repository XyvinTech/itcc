import 'package:flutter/material.dart';
import 'package:itcc/src/data/services/user_access_service.dart';
import 'package:itcc/src/interface/components/Dialogs/permission_denied_dialog.dart';

class PermissionCheckWrapper extends StatelessWidget {
  final Widget child;
  final Future<bool> Function() permissionCheck;
  final String permissionDeniedMessage;
  final VoidCallback onTap;

  const PermissionCheckWrapper({
    Key? key,
    required this.child,
    required this.permissionCheck,
    required this.permissionDeniedMessage,
    required this.onTap,
  }) : super(key: key);

  Future<void> _handleTap(BuildContext context) async {
    final hasPermission = await permissionCheck();
    if (!hasPermission) {
      if (context.mounted) {
        PermissionDeniedDialog.show(
          context,
          message: permissionDeniedMessage,
        );
      }
      return;
    }
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: child,
    );
  }
}

// Convenience methods for common permission checks
class PermissionWrappers {
  static Widget forAddReward({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return PermissionCheckWrapper(
      child: child,
      permissionCheck: UserAccessService.canAddReward,
      permissionDeniedMessage: 'You do not have permission to add rewards. Please contact your administrator for access.',
      onTap: onTap,
    );
  }

  static Widget forAddCertificate({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return PermissionCheckWrapper(
      child: child,
      permissionCheck: UserAccessService.canAddCertificate,
      permissionDeniedMessage: 'You do not have permission to add certificates. Please contact your administrator for access.',
      onTap: onTap,
    );
  }

  static Widget forAddSocialMedia({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return PermissionCheckWrapper(
      child: child,
      permissionCheck: UserAccessService.canAddSocialMedia,
      permissionDeniedMessage: 'You do not have permission to add social media. Please contact your administrator for access.',
      onTap: onTap,
    );
  }
} 