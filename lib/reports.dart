import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Reports'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('animal_alerts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No reports found.'));
          }

          final reports = snapshot.data!.docs;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('S. No')),
                DataColumn(label: Text('Date & Time')),
                DataColumn(label: Text('Location')),
                DataColumn(label: Text('Urgency Level')),
                DataColumn(label: Text('Status')),
              ],
              rows: List<DataRow>.generate(
                reports.length,
                (index) {
                  var reportData = reports[index];
                  var dateTime = (reportData['timestamp'] as Timestamp).toDate();
                  var formattedDateTime = DateFormat('dd-MM-yyyy hh:mm a').format(dateTime);

                  return DataRow(cells: [
                    DataCell(Text((index + 1).toString())), // Serial number
                    DataCell(Text(formattedDateTime)), // Date & time posted
                    DataCell(Text((reportData.data() as Map<String, dynamic>).containsKey('location') ? reportData['location'] : reportData['locationName'] ?? 'N/A')), // Location
                    DataCell(Text(reportData['urgencyLevel'] ?? 'Unknown')), // Urgency level
                    DataCell(const Text('Pending')), // Status (default)
                  ]);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
