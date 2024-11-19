import 'package:a4m/Constants/myColors.dart';
import 'package:flutter/material.dart';

class ApprovalButton extends StatefulWidget {
  final VoidCallback onPress;
  const ApprovalButton({super.key, required this.onPress});

  @override
  State<ApprovalButton> createState() => _ApprovalButtonState();
}

class _ApprovalButtonState extends State<ApprovalButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPress,
      child: Container(
        height: 35,
        width: 35,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: Mycolors().green),
        child: Center(
          child: Icon(
            Icons.check,
          ),
        ),
      ),
    );
  }
}
