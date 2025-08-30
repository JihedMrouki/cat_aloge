import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'custom_button.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final IconData? icon;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon
            Icon(icon ?? Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),

            // Error Title
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.gray900,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],

            // Error Message
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.gray700),
              textAlign: TextAlign.center,
            ),

            // Retry Button
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                onPressed: onRetry!,
                text: 'Try Again',
                icon: Icons.refresh,
                variant: ButtonVariant.outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
