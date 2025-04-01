import 'package:flutter/material.dart';

class MySearchBar extends StatelessWidget {
  final TextEditingController textController;
  final String hintText;
  final Function(String)? onChanged;

  const MySearchBar(
      {required this.textController,
      required this.hintText,
      this.onChanged,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              offset: const Offset(12, 26),
              blurRadius: 50,
              spreadRadius: 0,
              color: Colors.grey.withOpacity(.1),
            ),
          ],
        ),
        child: TextField(
          controller: textController,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[500]!,
            ),
            filled: true,
            fillColor: Colors.white,
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w300,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 20.0,
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(45.0)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Color.fromARGB(255, 54, 54, 54),
                width: 1.0,
              ),
              borderRadius: BorderRadius.all(Radius.circular(45.0)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Color.fromARGB(255, 54, 54, 54),
                width: 1.5,
              ),
              borderRadius: BorderRadius.all(Radius.circular(45.0)),
            ),
          ),
        ),
      ),
    );
  }
}
