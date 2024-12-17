import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:flutter/material.dart';

class DeleteButton extends StatefulWidget {
  final VoidCallback onPress;
  const DeleteButton({super.key, required this.onPress});

  @override
  State<DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<DeleteButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPress,
      child: Container(
        height: 35,
        width: 35,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: Mycolors().red),
        child: Center(
          child: Icon(
            Icons.delete_outline,
          ),
        ),
      ),
    );
  }
}
