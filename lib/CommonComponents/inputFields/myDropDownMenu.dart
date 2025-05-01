import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyDropDownMenu extends StatefulWidget {
  double customSize;
  String? description;
  final bool? focusTap;
  List items;
  final bool? enableSearch;
  final bool? isBold;
  final TextEditingController textfieldController;
  final Function? onChanged;
  MyDropDownMenu(
      {super.key,
      required this.customSize,
      this.description,
      required this.items,
      required this.textfieldController,
      this.isBold,
      this.onChanged,
      this.enableSearch,
      this.focusTap});

  @override
  State<MyDropDownMenu> createState() => _MyDropDownMenuState();
}

class _MyDropDownMenuState extends State<MyDropDownMenu> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: widget.description == null ? false : true,
            child: Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Text(
                widget.description == null ? '' : widget.description!,
                style: GoogleFonts.lato(
                  fontWeight: widget.isBold == null
                      ? FontWeight.w500
                      : FontWeight.normal,
                  fontSize: 16,
                  letterSpacing: -0.5,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Transform.scale(
            scale: 0.9,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
              ),
              child: DropdownMenu<String>(
                hintText: 'Select',
                textStyle: GoogleFonts.inter(
                  color: const Color.fromARGB(255, 7, 7, 7),
                ),
                trailingIcon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.black,
                  size: 35,
                ),
                selectedTrailingIcon: const Icon(
                  Icons.keyboard_arrow_up,
                  color: Colors.black,
                  size: 35,
                ),
                enableFilter: false,
                enableSearch: widget.enableSearch ?? true,
                width: widget.customSize,
                controller: widget.textfieldController,
                requestFocusOnTap: widget.focusTap ?? true,
                label: const Text(''),
                onSelected: (value) {
                  if (value != null) {
                    setState(() {
                      widget.textfieldController.text = value;
                    });
                    if (widget.onChanged != null) {
                      widget.onChanged!(value);
                    }
                  }
                },
                dropdownMenuEntries:
                    widget.items.map<DropdownMenuEntry<String>>((value) {
                  return DropdownMenuEntry<String>(
                    value: value.toString(),
                    label: value.toString(),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
