import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Apple Liquid Glass Container with frosted haze & specular highlights
class LiquidGlass extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final Color? tintColor;
  final Border? border;
  final VoidCallback? onTap;

  const LiquidGlass({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.padding,
    this.blur = 24.0,
    this.tintColor,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tintColor ?? const Color(0x331C1C24),
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ??
                Border.all(
                  color: const Color(0x38FFFFFF),
                  width: 0.8,
                ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        pressedOpacity: 0.75,
        child: content,
      );
    }
    return content;
  }
}

/// Floating Liquid Pill Navigation Bar matching iOS dynamic island / Netflix dock
class LiquidPillNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List<LiquidPillItem> items;

  const LiquidPillNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      child: Center(
        heightFactor: 1.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0x7314141B),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: const Color(0x40FFFFFF),
                  width: 0.9,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(items.length, (index) {
                  final isSelected = selectedIndex == index;
                  final item = items[index];
                  return GestureDetector(
                    onTap: () => onItemSelected(index),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0x38FFFFFF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(28),
                        border: isSelected
                            ? Border.all(
                                color: const Color(0x55FFFFFF),
                                width: 0.8,
                              )
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 22,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF8E8E93),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontFamily: '.SF Pro Text',
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF8E8E93),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LiquidPillItem {
  final IconData icon;
  final String label;

  const LiquidPillItem({
    required this.icon,
    required this.label,
  });
}

/// Cupertino-styled Frosted Button
class LiquidGlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;

  const LiquidGlassButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.height = 50,
    this.borderRadius = 16,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: backgroundColor ?? const Color(0x3D6366F1),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: const Color(0x40FFFFFF),
                width: 0.8,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

