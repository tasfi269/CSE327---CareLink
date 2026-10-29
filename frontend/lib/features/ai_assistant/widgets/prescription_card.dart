import 'package:flutter/material.dart';
import '../../../../models/chat_message.dart';
import '../../../../core/constants/colors.dart';

class PrescriptionMedicineCard extends StatelessWidget {
  final MedicineItem medicine;

  const PrescriptionMedicineCard({
    super.key,
    required this.medicine,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Medicine Capsule Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.medication_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (medicine.purpose.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    medicine.purpose,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (medicine.dosage.isNotEmpty)
                      _buildChip(
                        Icons.schedule_rounded,
                        'Take: ${medicine.dosage}',
                        AppColors.tagBlueBg,
                        AppColors.tagBlueText,
                      ),
                    if (medicine.frequency.isNotEmpty)
                      _buildChip(
                        Icons.repeat_rounded,
                        medicine.frequency,
                        AppColors.tagGreenBg,
                        AppColors.tagGreenText,
                      ),
                    if (medicine.mealTiming.isNotEmpty)
                      _buildChip(
                        Icons.restaurant_rounded,
                        medicine.mealTiming,
                        AppColors.tagPurpleBg,
                        AppColors.tagPurpleText,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
      IconData icon, String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
