import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyableInfoTile extends StatelessWidget {
  final String title;
  final dynamic value;

  const CopyableInfoTile({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue =
        value?.toString().trim().isNotEmpty == true
            ? value.toString()
            : "-";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: SelectableText(
              displayValue,
              style: const TextStyle(
                height: 1.4,
              ),
            ),
          ),

          IconButton(
            tooltip: "Copy",
            icon: const Icon(
              Icons.copy,
              size: 18,
            ),
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(text: displayValue),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Copied"),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}