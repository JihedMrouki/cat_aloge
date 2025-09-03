import 'package:cat_aloge/core/theme/app_colors.dart';
import 'package:cat_aloge/core/theme/text_styles.dart';
import 'package:cat_aloge/features/settings/presentation/views/widgets/settings_tile.dart';
import 'package:flutter/material.dart';

class DropdownSettingTile<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const DropdownSettingTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SettingTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        underline: const SizedBox.shrink(),
        style: AppTextStyles.buttonText,
        dropdownColor: AppColors.surface,
      ),
    );
  }
}
