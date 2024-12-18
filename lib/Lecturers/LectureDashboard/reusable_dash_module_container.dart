import 'package:a4m/Constants/myColors.dart';
import 'package:flutter/material.dart';

class ReusableDashModuleContainer extends StatelessWidget {
  final String name;
  final String moduleName;
  final String moduleNumber;
  final String moduleType;
  final VoidCallback onTap;

  const ReusableDashModuleContainer({
    Key? key,
    required this.name,
    required this.moduleName,
    required this.moduleNumber,
    required this.moduleType,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  moduleName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  moduleNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  moduleType,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 38, // Set desired height
            width: 85, // Set desired width
            child: ElevatedButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                backgroundColor: Mycolors().blue,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8), // Set smaller border radius
                ),
              ),
              child: const Text(
                'View',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
