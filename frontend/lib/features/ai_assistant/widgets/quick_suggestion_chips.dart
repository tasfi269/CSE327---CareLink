import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class QuickSuggestionChips extends StatefulWidget {
  final Function(String text) onSelectSuggestion;

  const QuickSuggestionChips({
    super.key,
    required this.onSelectSuggestion,
  });

  @override
  State<QuickSuggestionChips> createState() => _QuickSuggestionChipsState();
}

class _QuickSuggestionChipsState extends State<QuickSuggestionChips> {
  int _selectedIndex = -1;

  static const List<Map<String, dynamic>> suggestions = [
    {
      'title': 'Symptom Checker',
      'query': 'I would like to check some symptoms. Can you guide me through a medical evaluation?',
      'icon': Icons.health_and_safety_outlined,
    },
    {
      'title': 'Prescription Guide',
      'query': 'Can you explain how I should upload and check my prescription with you?',
      'icon': Icons.description_outlined,
    },
    {
      'title': 'Find a Specialist',
      'query': 'How can you help me find the right doctor or medical specialist for my health concern?',
      'icon': Icons.person_search_outlined,
    },
    {
      'title': 'Lab Test Insights',
      'query': 'Can you help me understand and interpret diagnostic lab reports and blood tests?',
      'icon': Icons.biotech_outlined,
    },
    {
      'title': 'Medication Safety',
      'query': 'What general safety advice should I keep in mind when taking medicines?',
      'icon': Icons.medication_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: Colors.transparent,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = suggestions[index];
          final isSelected = _selectedIndex == index;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                widget.onSelectSuggestion(item['query'] as String);
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.secondaryLight : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 1.4 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isSelected ? 0.04 : 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 15,
                      color: isSelected ? AppColors.primary : AppColors.primaryDark,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
