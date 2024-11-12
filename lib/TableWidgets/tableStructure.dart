import 'package:flutter/material.dart';

class TableStructure extends StatelessWidget {
  final Widget child;
  const TableStructure({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: child,
      ),
    );
  }
}
