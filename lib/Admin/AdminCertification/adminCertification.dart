import 'package:a4m/Admin/AdminCertification/table/certificationTable.dart';
import 'package:a4m/CommonComponents/inputFields/myDropDownMenu.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

class AdminCertification extends StatefulWidget {
  const AdminCertification({super.key});

  @override
  State<AdminCertification> createState() => _AdminCertificationState();
}

class _AdminCertificationState extends State<AdminCertification> {
  @override
  Widget build(BuildContext context) {
    final newOld = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyDropDownMenu(
              customSize: 300,
              items: ['Newest', 'Oldest'],
              textfieldController: newOld),
          const SizedBox(
            height: 20,
          ),
          Container(
            height: MyUtility(context).height * 0.75 - 30,
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
            child: CertificationTable(),
          ),
        ],
      ),
    );
  }
}
