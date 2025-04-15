import 'package:a4m/CommonComponents/buttons/CustomButton.dart';
import 'package:a4m/CommonComponents/inputFields/myDropDownMenu.dart';
import 'package:a4m/CommonComponents/inputFields/myTextFields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';
import 'dart:html' as html;
import 'dart:convert';

import '../../../Themes/Constants/myColors.dart';

class AdminCourseDetailsPopup extends StatefulWidget {
  final Map<String, dynamic> course;

  const AdminCourseDetailsPopup({super.key, required this.course});

  @override
  State<AdminCourseDetailsPopup> createState() =>
      _AdminCourseDetailsPopupState();
}

class _AdminCourseDetailsPopupState extends State<AdminCourseDetailsPopup> {
  late String currentStatus;
  late TextEditingController certificatePrice;
  late TextEditingController changePrice;
  late TextEditingController discountPrice;
  late TextEditingController bulkPurchaseCount;
  bool hasRoyalties = false;
  double royaltyPercentage = 0.0;
  int totalSales = 0;
  double totalRevenue = 0.0;
  Map<String, double> monthlyRevenue = {};
  List<Map<String, dynamic>> yearlySalesData = [];

  @override
  void initState() {
    super.initState();
    currentStatus = widget.course['status'] ?? 'approved';
    certificatePrice = TextEditingController(
        text: widget.course['certificatePrice']?.toString() ?? '');
    changePrice = TextEditingController(
        text: widget.course['coursePrice']?.toString() ?? '');
    discountPrice = TextEditingController();
    bulkPurchaseCount = TextEditingController(
        text: widget.course['bulkPurchaseCount']?.toString() ?? '');
    hasRoyalties = widget.course['hasRoyalties'] ?? false;
    royaltyPercentage = widget.course['royaltyPercentage']?.toDouble() ?? 0.0;
    _fetchSalesData();
  }

  Future<void> _fetchSalesData() async {
    try {
      // Get the list of students who purchased the course
      final courseDoc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.course['courseId'])
          .get();

      if (courseDoc.exists) {
        final students = courseDoc.data()?['students'] as List<dynamic>? ?? [];
        final coursePrice =
            double.tryParse(widget.course['coursePrice']?.toString() ?? '0') ??
                0.0;

        // Get purchase timestamps from the certificates collection
        final certificatesSnapshot = await FirebaseFirestore.instance
            .collection('certificates')
            .where('courseId', isEqualTo: widget.course['courseId'])
            .get();

        Map<String, double> monthRevenue = {};
        List<Map<String, dynamic>> yearSales = [];

        for (var cert in certificatesSnapshot.docs) {
          final data = cert.data();
          final purchaseDate = (data['purchaseDate'] as Timestamp).toDate();
          final monthKey =
              '${purchaseDate.year}-${purchaseDate.month.toString().padLeft(2, '0')}';

          monthRevenue[monthKey] = (monthRevenue[monthKey] ?? 0) + coursePrice;

          yearSales.add({
            'date': purchaseDate,
            'studentId': data['studentId'],
            'studentName': data['studentName'],
            'amount': coursePrice,
          });
        }

        setState(() {
          totalSales = students.length;
          totalRevenue = coursePrice * totalSales;
          monthlyRevenue = monthRevenue;
          yearlySalesData = yearSales;
        });
      }
    } catch (e) {
      print('Error fetching sales data: $e');
    }
  }

  Future<void> _downloadYearlyReport() async {
    try {
      // Group sales by month
      Map<String, List<Map<String, dynamic>>> salesByMonth = {};

      for (var sale in yearlySalesData) {
        final date = sale['date'] as DateTime;
        final monthKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}';

        if (!salesByMonth.containsKey(monthKey)) {
          salesByMonth[monthKey] = [];
        }
        salesByMonth[monthKey]!.add(sale);
      }

      // Generate CSV content
      String csvContent = 'Month,Total Sales,Total Revenue,Royalty Amount\n';

      // Sort months
      var sortedMonths = salesByMonth.keys.toList()..sort();

      for (var month in sortedMonths) {
        final sales = salesByMonth[month]!;
        final totalMonthRevenue = sales.fold<double>(
            0, (sum, sale) => sum + (sale['amount'] as double));
        final royaltyAmount = totalMonthRevenue * royaltyPercentage;

        csvContent +=
            '$month,${sales.length},R${totalMonthRevenue.toStringAsFixed(2)},R${royaltyAmount.toStringAsFixed(2)}\n';

        // Add individual sales
        csvContent += 'Date,Student Name,Amount\n';
        for (var sale in sales) {
          final date = (sale['date'] as DateTime).toString().split(' ')[0];
          csvContent += '$date,${sale['studentName']},R${sale['amount']}\n';
        }
        csvContent += '\n'; // Add spacing between months
      }

      // Create download link
      final bytes = utf8.encode(csvContent);
      final blob = html.Blob([bytes], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'yearly_sales_report.csv')
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print('Error generating report: $e');
    }
  }

  @override
  void dispose() {
    certificatePrice.dispose();
    changePrice.dispose();
    discountPrice.dispose();
    bulkPurchaseCount.dispose();
    super.dispose();
  }

  Widget _buildSalesSummary() {
    final currentMonthKey =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
    final currentMonthRevenue = monthlyRevenue[currentMonthKey] ?? 0.0;
    final currentMonthRoyalty = currentMonthRevenue * royaltyPercentage;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sales Summary',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              if (hasRoyalties)
                ElevatedButton.icon(
                  onPressed: _downloadYearlyReport,
                  icon: Icon(Icons.download, color: Colors.white),
                  label: Text(
                    'Download Yearly Report',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Mycolors().green,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Sales',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '$totalSales courses',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Mycolors().green,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Revenue',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'R ${totalRevenue.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Mycolors().green,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (hasRoyalties) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Mycolors().green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Month Revenue',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Mycolors().green,
                        ),
                      ),
                      Text(
                        'R ${currentMonthRevenue.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Mycolors().green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Month Royalty',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Mycolors().green,
                        ),
                      ),
                      Text(
                        'R ${currentMonthRoyalty.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Mycolors().green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 610,
      width: 800,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            width: 800,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: ImageNetwork(
                image: widget.course['courseImageUrl'] ??
                    'https://example.com/placeholder.png',
                height: 200,
                width: 800,
                fitWeb: BoxFitWeb.fill,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.course['courseName'] ?? 'Unknown',
                          style: GoogleFonts.kanit(fontSize: 25),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.course['courseDescription'] ??
                          'No description available.',
                      style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'R${widget.course['coursePrice']?.toString() ?? '0'}',
                      style: GoogleFonts.kanit(fontSize: 25),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        SizedBox(
                          width: 300,
                          child: MyTextFields(
                            inputController: changePrice,
                            headerText: 'Change Price',
                            keyboardType: 'number',
                          ),
                        ),
                        const SizedBox(width: 30),
                        SizedBox(
                          width: 300,
                          child: MyTextFields(
                            inputController: certificatePrice,
                            headerText: 'Certificate Price',
                            keyboardType: 'number',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        SizedBox(
                          width: 300,
                          child: MyTextFields(
                            inputController: bulkPurchaseCount,
                            headerText: 'Minimum Courses for Discount',
                            keyboardType: 'number',
                          ),
                        ),
                        const SizedBox(width: 30),
                        SizedBox(
                          width: 300,
                          child: MyDropDownMenu(
                            description: 'Bulk Purchase Discount',
                            customSize: 300,
                            items: ['5%', '10%', '15%', '20%', '25%', '30%'],
                            textfieldController: discountPrice,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: hasRoyalties,
                                onChanged: (value) {
                                  setState(() {
                                    hasRoyalties = value ?? false;
                                    if (!hasRoyalties) {
                                      royaltyPercentage = 0.0;
                                    }
                                  });
                                },
                                activeColor: Mycolors().green,
                              ),
                              Text(
                                'Enable Royalties',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${(royaltyPercentage * 100).toStringAsFixed(2)}%',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Mycolors().green,
                                ),
                              ),
                            ],
                          ),
                          if (hasRoyalties) ...[
                            const SizedBox(height: 10),
                            SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: Mycolors().green,
                                inactiveTrackColor: Colors.grey[300],
                                thumbColor: Mycolors().green,
                                overlayColor: Mycolors().green.withOpacity(0.2),
                                valueIndicatorColor: Mycolors().green,
                                valueIndicatorTextStyle:
                                    const TextStyle(color: Colors.white),
                              ),
                              child: Slider(
                                value: royaltyPercentage,
                                min: 0.0,
                                max: 0.20,
                                divisions: 80,
                                label:
                                    '${(royaltyPercentage * 100).toStringAsFixed(2)}%',
                                onChanged: hasRoyalties
                                    ? (value) {
                                        setState(() {
                                          royaltyPercentage = value;
                                        });
                                      }
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 15),
                            _buildSalesSummary(),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Image.asset('images/facebookIcon.png'),
                            onPressed: () {
                              // Handle Facebook share
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Image.asset('images/xIcon.png'),
                            onPressed: () {
                              // Handle X (Twitter) share
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Image.asset('images/instagramIcon.png'),
                            onPressed: () {
                              // Handle Instagram share
                            },
                          ),
                        ),
                        const SizedBox(width: 30),
                        CustomButton(
                          buttonText: 'Save',
                          buttonColor: Mycolors().green,
                          onPressed: () async {
                            String courseId = widget.course['courseId'];
                            String newPrice = changePrice.text.trim();
                            String bulkCount = bulkPurchaseCount.text.trim();

                            if (courseId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Error: Course ID not found')),
                              );
                              return;
                            }

                            if (newPrice.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Please fill in the course price')),
                              );
                              return;
                            }

                            try {
                              Map<String, dynamic> updateData = {
                                'coursePrice': newPrice,
                                'hasRoyalties': hasRoyalties,
                                'royaltyPercentage': royaltyPercentage,
                              };

                              if (certificatePrice.text.trim().isNotEmpty) {
                                updateData['certificatePrice'] =
                                    certificatePrice.text.trim();
                              }

                              if (bulkCount.isNotEmpty) {
                                updateData['bulkPurchaseCount'] =
                                    int.parse(bulkCount);
                              }

                              if (discountPrice.text.isNotEmpty) {
                                updateData['bulkDiscountPercentage'] =
                                    int.parse(
                                  discountPrice.text.replaceAll('%', ''),
                                );
                              }

                              await FirebaseFirestore.instance
                                  .collection('courses')
                                  .doc(courseId)
                                  .update(updateData);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Course updated successfully'),
                                  backgroundColor: Mycolors().green,
                                ),
                              );

                              Navigator.pop(context, true);
                            } catch (e) {
                              print("Error updating course: $e");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error updating course: $e'),
                                  backgroundColor: Mycolors().red,
                                ),
                              );
                            }
                          },
                          width: 120,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
