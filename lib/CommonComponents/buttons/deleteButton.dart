import 'package:a4m/Constants/myColors.dart';
import 'package:flutter/material.dart';

class DeleteButton extends StatefulWidget {
  const DeleteButton({super.key});

  @override
  State<DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<DeleteButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      width: 35,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), color: Mycolors().red),
      child: Center(
        child: Icon(
          Icons.delete_outline,
        ),
      ),
    );
  }
}