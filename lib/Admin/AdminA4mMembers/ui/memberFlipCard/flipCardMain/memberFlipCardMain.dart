import 'package:flutter/material.dart';

import '../a4mBackMemberCard.dart';
import '../a4mMemberCards.dart';

import 'dart:math';

class MemberFlipCardMain extends StatefulWidget {
  const MemberFlipCardMain({super.key});

  @override
  State<MemberFlipCardMain> createState() => _MemberFlipCardMainState();
}

class _MemberFlipCardMainState extends State<MemberFlipCardMain> with SingleTickerProviderStateMixin {
  bool isFront = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isFront = !isFront;
        });
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final rotate = Tween(begin: pi, end: 0.0).animate(animation);
          return AnimatedBuilder(
            animation: rotate,
            builder: (context, child) {
              final isUnder = (ValueKey(isFront) != child?.key);
              var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
              tilt *= isUnder ? -1.0 : 1.0; 
              return Transform(
                transform: Matrix4.rotationY(rotate.value)..setEntry(3, 0, tilt),
                alignment: Alignment.center,
                child: child,
              );
            },
            child: child,
          );
        },
        child: isFront
            ? const A4mMembersCard(key: ValueKey(true))
            : const A4mBackMemberCard(key: ValueKey(false)),
      ),
    );
  }
}
