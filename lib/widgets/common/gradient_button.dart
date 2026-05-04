// gradient_button.dart
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (loading || onPressed == null) ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: (loading || onPressed == null)
              ? const LinearGradient(
                  colors: [Color(0xFF444444), Color(0xFF444444)])
              : AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: (loading || onPressed == null)
              ? []
              : [BoxShadow(
                  color: AppTheme.accent.withOpacity(0.35),
                  blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                    ],
                    Text(label,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  ],
                ),
        ),
      ),
    );
  }
}
