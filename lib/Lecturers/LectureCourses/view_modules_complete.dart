import 'package:a4m/CommonComponents/inputFields/myDropDownMenu.dart';
import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/Lecturers/LectureCourses/module_complete_list.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

class ViewModulesComplete extends StatefulWidget {
  final String courseId;
  final String moduleId;

  const ViewModulesComplete(
      {super.key, required this.courseId, required this.moduleId});

  @override
  State<ViewModulesComplete> createState() => _ViewModulesCompleteState();
}

class _ViewModulesCompleteState extends State<ViewModulesComplete> {
  @override
  Widget build(BuildContext context) {
    final oldNew = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        width: MyUtility(context).width - 320,
        height: MyUtility(context).height - 80,
        child: Material(
          color: Colors.white,
          child: DefaultTabController(
            length: 1, // Only one tab
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdown Menu
                  MyDropDownMenu(
                    description: 'Select',
                    customSize: 300,
                    items: [], // Populate dropdown items if needed
                    textfieldController: oldNew,
                  ),
                  const SizedBox(height: 20),

                  // Single TabBarView
                  Expanded(
                    child: TabBarView(
                      children: [
                        Container(
                          width: MyUtility(context).width - 320,
                          height: MyUtility(context).height - 80,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                            border: Border.all(
                              width: 2,
                              color: Colors.black,
                            ),
                          ),
                          child: ModuleCompleteList(
                            courseId: widget.courseId,
                            moduleId: widget.moduleId, // Pass the module ID
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
