import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class CareLinkBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const CareLinkBottomNav({
    super.key,
    this.currentIndex = 4, // Default to AI Assistant tab
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(alpha: 0.8),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
              ),
              _buildNavItem(
                context,
                index: 1,
                icon: Icons.medication_outlined,
                activeIcon: Icons.medication_rounded,
                label: 'Medicines',
              ),
              _buildNavItem(
                context,
                index: 2,
                icon: Icons.person_search_outlined,
                activeIcon: Icons.person_search_rounded,
                label: 'Doctors',
              ),
              _buildNavItem(
                context,
                index: 3,
                icon: Icons.science_outlined,
                activeIcon: Icons.science_rounded,
                label: 'Labs',
              ),
              _buildNavItem(
                context,
                index: 4,
                icon: Icons.smart_toy_outlined,
                activeIcon: Icons.smart_toy_rounded,
                label: 'AI Assistant',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap!(index);
          } else if (index != 4) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '$label module is assigned to your team members and will be integrated soon!',
                ),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 24,
              color: color,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
