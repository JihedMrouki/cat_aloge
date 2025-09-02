import 'package:cat_aloge/core/theme/app_colors.dart';
import 'package:cat_aloge/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

class SettingTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget trailing;
  final VoidCallback? onTap;
  
  const SettingTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    required this.trailing,
    this.onTap,
  });

  // Switch Setting
  factory SettingTile.switch({
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
  
  // Dropdown Setting
  factory SettingTile.dropdown<T>({
    required String title,
    String? subtitle,
    Widget? leading,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return SettingTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        underline: Container(),
        style: AppTextStyles.buttonText,
        dropdownColor: AppColors.surface,
      ),
    );
  }
  
  // Slider Setting
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
        width: 120,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              valueFormatter?.call(value) ?? value.toStringAsFixed(2),
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
  
  // Number Setting
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
          Container(
            width: 60,
            child: Text(
              value.toString(),
              style: AppTextStyles.buttonText.copyWith(
                fontWeight: FontWeight.w600,
              ),
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 16),
            ],
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.buttonText.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: AppTextStyles.buttonText.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            trailing,
          ],
        ),
      ),
    );
  }
}
