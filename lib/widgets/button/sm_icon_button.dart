import 'package:flutter/material.dart';
import '../../resources/app_resources.dart';

class SMIconButton extends StatelessWidget {
  const SMIconButton({
    super.key,
    required this.onPressed,
    required this.asset,
    required this.label,
  });

  final Function() onPressed;
  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(Icons.delete_forever),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.contentColorRed
      )
    );
  }
}
