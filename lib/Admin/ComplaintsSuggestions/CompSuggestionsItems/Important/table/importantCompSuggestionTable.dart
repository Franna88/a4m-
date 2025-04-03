import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../services/complaints_suggestions_service.dart';
import '../../../../../Themes/Constants/myColors.dart';
import '../../../../../../TableWidgets/tableStructure.dart';
import '../../new/table/ui/compSuggestionStatus.dart';
import '../../../../../CommonComponents/buttons/slimButtons.dart';

class ImportantCompSuggestionTable extends StatefulWidget {
  const ImportantCompSuggestionTable({super.key});

  @override
  State<ImportantCompSuggestionTable> createState() =>
      _ImportantCompSuggestionTableState();
}

class _ImportantCompSuggestionTableState
    extends State<ImportantCompSuggestionTable> {
  final ComplaintsSuggestionsService _service = ComplaintsSuggestionsService();

  void _showDetailsDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Details',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow('From', item['submitterName'] ?? 'Unknown'),
              _buildDetailRow('Type', item['type'] ?? 'Unknown'),
              _buildDetailRow(
                  'Date', _formatDate(item['dateAdded'] as Timestamp)),
              _buildDetailRow('Status', item['status'] ?? 'pending'),
              const SizedBox(height: 10),
              Text(
                'Title:',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item['title'] ?? 'No title provided',
                  style: GoogleFonts.poppins(),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Description:',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item['description'] ?? 'No description provided',
                  style: GoogleFonts.poppins(),
                ),
              ),
              if (item['adminResponse'] != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Admin Response:',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item['adminResponse'],
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (item['status'] != 'resolved')
                    TextButton(
                      onPressed: () async {
                        await _service.addAdminResponseToComplaint(
                          item['id'],
                          'Marked as resolved',
                        );
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Marked as resolved',
                                style: GoogleFonts.poppins(),
                              ),
                              backgroundColor: Mycolors().green,
                            ),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Mycolors().green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        'Mark as Resolved',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Close',
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _service.getComplaints(importantOnly: true),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading important complaints: ${snapshot.error}',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!.docs;

        if (items.isEmpty) {
          return Center(
            child: Text(
              'No important complaints found',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          );
        }

        return Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                color: Mycolors().green,
                border: const Border(
                  bottom: BorderSide(color: Colors.black),
                ),
              ),
              children: [
                TableStructure(
                  child: TableCell(
                    child: Text(
                      'From',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                TableStructure(
                  child: TableCell(
                    child: Text(
                      'Date',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                TableStructure(
                  child: TableCell(
                    child: Text(
                      'Type',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                TableStructure(
                  child: TableCell(
                    child: Text(
                      'Status',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                TableStructure(
                  child: TableCell(
                    child: Text(
                      'Details',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ...items.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id; // Add document ID to the data

              return TableRow(
                decoration: BoxDecoration(
                  color: items.indexOf(doc) % 2 == 1
                      ? Colors.white
                      : const Color.fromRGBO(209, 210, 146, 0.50),
                  border: const Border(
                    bottom: BorderSide(width: 1, color: Colors.black),
                  ),
                ),
                children: [
                  TableStructure(
                    child: TableCell(
                      child: Text(
                        data['submitterName'] ?? 'Unknown',
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  TableStructure(
                    child: TableCell(
                      child: Text(
                        _formatDate(data['dateAdded'] as Timestamp),
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  TableStructure(
                    child: TableCell(
                      child: Text(
                        data['type'] ?? 'Unknown',
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  TableStructure(
                    child: TableCell(
                      child: CompSuggestionStatus(
                        isResolved: data['status'] == 'resolved',
                      ),
                    ),
                  ),
                  TableStructure(
                    child: TableCell(
                      child: SlimButtons(
                        buttonText: 'View',
                        buttonColor: Mycolors().peach,
                        onPressed: () => _showDetailsDialog(data),
                        customWidth: 80,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        );
      },
    );
  }
}
