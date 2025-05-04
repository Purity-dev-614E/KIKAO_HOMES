import 'package:flutter/material.dart';

class NotificationDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback? onConfirm;

  const NotificationDialog({super.key, 
    required this.title,
    required this.content,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (onConfirm != null)
          TextButton(
            onPressed: onConfirm,
            child: const Text('Confirm'),
          ),
      ],
    );
  }
}