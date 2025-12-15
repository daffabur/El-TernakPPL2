import 'package:flutter/material.dart';

enum AlertVariant { info, success, warning, error }

class AlertItem {
  final String id;
  final String title;   // mis. "Persediaan rendah"
  final String message; // mis. "Pakan tersisa 100 kg dari 1000 kg"
  final AlertVariant variant;

  const AlertItem({
    required this.id,
    required this.title,
    required this.message,
    this.variant = AlertVariant.warning,
  });
}

class AlertBanner extends StatelessWidget {
  final AlertItem alert;
  final VoidCallback? onClose;
  final EdgeInsetsGeometry? margin;

  const AlertBanner({
    super.key,
    required this.alert,
    this.onClose,
    this.margin,
  });

  Color _bg(AlertVariant v, BuildContext c) {
    switch (v) {
      case AlertVariant.success: return Colors.green.shade600;
      case AlertVariant.warning: return Colors.orange.shade700;
      case AlertVariant.error:   return Colors.red.shade700;
      case AlertVariant.info:    return Colors.blueGrey.shade600;
    }
  }

  IconData _icon(AlertVariant v) {
    switch (v) {
      case AlertVariant.success: return Icons.check_circle_rounded;
      case AlertVariant.warning: return Icons.warning_amber_rounded;
      case AlertVariant.error:   return Icons.error_rounded;
      case AlertVariant.info:    return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = _bg(alert.variant, context);
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 8)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon(alert.variant), color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    )),
                const SizedBox(height: 2),
                Text(
                  alert.message,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
          if (onClose != null)
            InkWell(
              onTap: onClose,
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
