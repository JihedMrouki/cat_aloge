import 'package:cat_aloge/core/theme/app_colors.dart';
import 'package:cat_aloge/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

class SettingTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  /// Creates a setting tile with a switch.
  factory SettingTile.switchTile({
    required String title,
    String? subtitle,
    Widget? leading,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SettingTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
      onTap: () => onChanged(!value),
    );
  }

  /// Creates a setting tile with a slider.
  factory SettingTile.slider({
    required String title,
    String? subtitle,
    Widget? leading,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
    String Function(double)? valueFormatter,
  }) {
    return SettingTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: SizedBox(
        width: 150,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              valueFormatter?.call(value) ?? value.toStringAsFixed(1),
              style: AppTextStyles.buttonText.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            Slider.adaptive(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  /// Creates a setting tile for incrementing or decrementing a number.
  factory SettingTile.number({
    required String title,
    String? subtitle,
    Widget? leading,
    required int value,
    required int min,
    required int max,
    int step = 1,
    required ValueChanged<int> onChanged,
  }) {
    return SettingTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: value > min ? () => onChanged(value - step) : null,
            icon: const Icon(Icons.remove, size: 20),
            color: AppColors.primary,
          ),
          SizedBox(
            width: 40,
            child: Text(
              value.toString(),
              style: AppTextStyles.buttonText
                  .copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: value < max ? () => onChanged(value + step) : null,
            icon: const Icon(Icons.add, size: 20),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  /// Creates a tappable setting tile, typically for navigation.
  factory SettingTile.navigation({
    required String title,
    String? subtitle,
    Widget? leading,
    Widget? trailing =
        const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
    required VoidCallback onTap,
  }) {
    return SettingTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.buttonText
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: AppTextStyles.buttonText.copyWith(
                        color: AppColors.gray500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 16),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
