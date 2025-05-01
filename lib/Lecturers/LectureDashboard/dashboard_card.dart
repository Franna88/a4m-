import 'package:a4m/Constants/myColors.dart';
import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final Widget content;
  final double height;
  final double? width;
  final EdgeInsetsGeometry padding;
  final List<Widget>? actions;
  final Color backgroundColor;
  final double borderRadius;
  final BoxShadow? boxShadow;

  const DashboardCard({
    super.key,
    required this.title,
    required this.content,
    this.height = 200,
    this.width,
    this.padding = const EdgeInsets.all(16.0),
    this.actions,
    this.backgroundColor = Colors.white,
    this.borderRadius = 12.0,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          boxShadow ??
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4.0,
                spreadRadius: 2.0,
              ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
          const SizedBox(height: 16.0),
          Expanded(child: content),
        ],
      ),
    );
  }
}

class DashboardMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Color? valueColor;
  final Color? subtitleColor;
  final double height;
  final double? width;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final double borderRadius;
  final BoxShadow? boxShadow;

  const DashboardMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    this.icon,
    this.iconColor,
    this.valueColor,
    this.subtitleColor,
    this.height = 200,
    this.width,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor = Colors.white,
    this.borderRadius = 12.0,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          boxShadow ??
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4.0,
                spreadRadius: 2.0,
              ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 48.0,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
          if (icon != null)
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (iconColor ?? Mycolors().green).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: iconColor ?? Mycolors().green,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: subtitleColor ?? iconColor ?? Mycolors().green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
