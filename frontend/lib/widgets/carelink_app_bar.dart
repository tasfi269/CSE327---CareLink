import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class CareLinkAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onCartPressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;

  const CareLinkAppBar({
    super.key,
    this.onCartPressed,
    this.onNotificationPressed,
    this.onProfilePressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 4,
        bottom: 6,
        left: 12,
        right: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Official CareLink Logo (flexible to avoid horizontal overflow)
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 28, maxWidth: 130),
              child: Image.asset(
                'assets/images/carelink-logo-600w.png',
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
                errorBuilder: (_, _, _) => const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_rounded, color: AppColors.primary, size: 20),
                    SizedBox(width: 6),
                    Text(
                      'CareLink',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Right action icons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Shopping cart with red badge
              _buildIconButton(
                icon: Icons.shopping_cart_outlined,
                hasBadge: true,
                onTap: onCartPressed ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cart module assigned to team member.'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
              ),
              const SizedBox(width: 2),

              // Notification bell with red badge
              _buildIconButton(
                icon: Icons.notifications_none_rounded,
                hasBadge: true,
                onTap: onNotificationPressed ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No new notifications.'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
              ),
              const SizedBox(width: 6),

              // User profile avatar with dropdown
              InkWell(
                onTap: onProfilePressed,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.userPillBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 11,
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(
                          Icons.person,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 15,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required bool hasBadge,
    required VoidCallback onTap,
  }) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: AppColors.textPrimary, size: 21),
          constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
          padding: const EdgeInsets.all(6),
          visualDensity: VisualDensity.compact,
          splashRadius: 18,
        ),
        if (hasBadge)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.badgeRed,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
