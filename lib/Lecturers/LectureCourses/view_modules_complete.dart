import 'package:a4m/CommonComponents/inputFields/myDropDownMenu.dart';
import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/Lecturers/LectureCourses/module_complete_list.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewModulesComplete extends StatefulWidget {
  final String courseId;
  final String moduleId;

  const ViewModulesComplete({
    super.key,
    required this.courseId,
    required this.moduleId,
  });

  @override
  State<ViewModulesComplete> createState() => _ViewModulesCompleteState();
}

class _ViewModulesCompleteState extends State<ViewModulesComplete> {
  List<Map<String, dynamic>> modules = []; // Changed to store both id and name
  String selectedModuleId = '';
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    selectedModuleId = widget.moduleId;
    if (widget.courseId.isNotEmpty) {
      fetchModules();
    } else {
      setState(() {
        isLoading = false;
        errorMessage = 'No course selected';
      });
    }
  }

  Future<void> fetchModules() async {
    try {
      print("Fetching modules for course: ${widget.courseId}");
      if (widget.courseId.isEmpty) {
        throw Exception("Course ID cannot be empty");
      }

      final modulesSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .get();

      List<Map<String, dynamic>> tempModules = [];
      for (var doc in modulesSnapshot.docs) {
        tempModules.add({
          'id': doc.id,
          'name': doc.data()['moduleName'] as String? ?? 'Unnamed Module'
        });
      }

      setState(() {
        modules = tempModules;
        isLoading = false;
        if (modules.isEmpty) {
          errorMessage = 'No modules found for this course';
        } else {
          errorMessage = '';
        }
      });
      print("Found ${modules.length} modules");
    } catch (e) {
      print("Error fetching modules: $e");
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading modules: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final moduleController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SizedBox(
        width: MyUtility(context).width - 320,
        height: MyUtility(context).height - 80,
        child: Material(
          color: Colors.white,
          child: DefaultTabController(
            length: 1,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (errorMessage.isNotEmpty)
                    Center(
                      child: Text(
                        errorMessage,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    )
                  else
                    MyDropDownMenu(
                      description: 'Select Module',
                      customSize: 300,
                      items: modules.map((m) => m['name'] as String).toList(),
                      textfieldController: moduleController,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          final selectedModule = modules.firstWhere(
                            (m) => m['name'] == newValue,
                            orElse: () => {'id': widget.moduleId},
                          );
                          setState(() {
                            selectedModuleId = selectedModule['id'] as String;
                          });
                        }
                      },
                    ),
                  const SizedBox(height: 20),
                  if (!isLoading && errorMessage.isEmpty)
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
                              moduleId: selectedModuleId,
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
