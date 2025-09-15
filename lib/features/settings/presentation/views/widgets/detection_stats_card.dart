import 'package:cat_aloge/core/theme/app_colors.dart';
import 'package:cat_aloge/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DetectionStatsCard extends ConsumerWidget {
  const DetectionStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withAlpha(26),
            AppColors.secondary.withAlpha(13),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(51),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text('Detection Statistics', style: AppTextStyles.captionText),
            ],
          ),

          const SizedBox(height: 20),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  value: '847', // TODO: Get from provider
                  label: 'Total Photos',
                  icon: Icons.photo_library,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.gray500.withAlpha(76),
              ),
              Expanded(
                child: _buildStatItem(
                  value: '143', // TODO: Get from provider
                  label: 'Cats Found',
                  icon: Icons.pets,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.gray500.withAlpha(76),
              ),
              Expanded(
                child: _buildStatItem(
                  value: '92%', // TODO: Get from provider
                  label: 'Accuracy',
                  icon: Icons.verified,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Last Scan Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface.withAlpha(127),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, size: 16, color: AppColors.secondary),
                const SizedBox(width: 8),
                Text(
                  'Last scan: 2 hours ago', // TODO: Get from provider
                  style: AppTextStyles.captionText.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                const Spacer(),
                Text(
                  'Avg: 250ms/photo', // TODO: Get from provider
                  style: AppTextStyles.captionText.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.captionText.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.captionText.copyWith(color: AppColors.gray800),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
