import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ButtonVariant { primary, secondary, outlined, text }

enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? icon;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final textStyle = _getTextStyle(context);
    final padding = _getPadding();

    Widget button = _buildButton(buttonStyle, textStyle, padding);

    if (isFullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildButton(
    ButtonStyle style,
    TextStyle textStyle,
    EdgeInsets padding,
  ) {
    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: _buildContent(textStyle),
        );
      case ButtonVariant.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: _buildContent(textStyle),
        );
      case ButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: _buildContent(textStyle),
        );
    }
  }

  Widget _buildContent(TextStyle textStyle) {
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textStyle.color!),
            ),
          ),
          const SizedBox(width: 8),
          Text('Loading...', style: textStyle),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: 8),
          Text(text, style: textStyle),
        ],
      );
    }

    return Text(text, style: textStyle);
  }

  ButtonStyle _getButtonStyle() {
    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      case ButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.surface,
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      case ButtonVariant.outlined:
        return OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: AppColors.primary),
        );
      case ButtonVariant.text:
        return TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    switch (size) {
      case ButtonSize.small:
        return Theme.of(context).textTheme.labelMedium!;
      case ButtonSize.medium:
        return Theme.of(context).textTheme.labelLarge!;
      case ButtonSize.large:
        return Theme.of(context).textTheme.titleMedium!;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }
}
