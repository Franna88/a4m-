import 'package:a4m/Admin/CurriculumVitae/Table/cvTable.dart';
import 'package:flutter/material.dart';

import '../../myutility.dart';

class CirriculumVitae extends StatefulWidget {
  const CirriculumVitae({super.key});

  @override
  State<CirriculumVitae> createState() => _CirriculumVitaeState();
}

class _CirriculumVitaeState extends State<CirriculumVitae> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Container(
          height: MyUtility(context).height  - 95,
          width: MyUtility(context).width - 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border.all(
              width: 2,
              color: Colors.black,
            ),
          ),
          child: CvTable()),
    );
  }
}
