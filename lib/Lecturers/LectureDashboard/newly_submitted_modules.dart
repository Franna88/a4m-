import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/Lecturers/LectureDashboard/reusable_dash_module_container.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

class NewlySubmitedModules extends StatelessWidget {
  const NewlySubmitedModules({
    Key? key,
  }) : super(key: key);

  // Mock data for now; replace with dynamic data in the future
  final List<Map<String, String>> moduleData = const [
    {
      'name': 'Kurt Ownes',
      'moduleName': 'Manufacturing Level 1',
      'moduleNumber': 'Module 1',
      'moduleType': 'Assessment',
    },
    {
      'name': 'Tami Dixon',
      'moduleName': 'Manufacturing Level 1',
      'moduleNumber': 'Module 1',
      'moduleType': 'Task',
    },
    {
      'name': 'Sarah Collins',
      'moduleName': 'Engineering Level 2',
      'moduleNumber': 'Module 3',
      'moduleType': 'Project',
    },
    // Add more entries as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MyUtility(context).width * 0.52,
        height: MyUtility(context).height * 0.32,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 2.0,
              spreadRadius: 2.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Newly Submitted',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: ListView.builder(
                itemCount: moduleData.length,
                itemBuilder: (context, index) {
                  final module = moduleData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ReusableDashModuleContainer(
                      name: module['name']!,
                      moduleName: module['moduleName']!,
                      moduleNumber: module['moduleNumber']!,
                      moduleType: module['moduleType']!,
                      onTap: () {
                        // Handle tap event
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
