import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewBillsScreen extends StatefulWidget {
  const ViewBillsScreen({super.key});

  @override
  State<ViewBillsScreen> createState() => _ViewBillsScreenState();
}

class _ViewBillsScreenState extends State<ViewBillsScreen> {
  String _searchEmployee = '';
  DateTime? _selectedDate;

  /// Card Expand
  final Set<String> _expandedBillIds = {};


  String formatDate(Timestamp timestamp) {
    final dt = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }

  bool _matchesFilter(Map<String, dynamic> data) {
    final empName = (data['employeeName'] ?? '').toString().toLowerCase();
    final matchesName = empName.contains(_searchEmployee.toLowerCase());

    if (_selectedDate == null) return matchesName;

    final billDate = (data['createdAt'] as Timestamp?)?.toDate();
    if (billDate == null) return false;

    return matchesName &&
        billDate.year == _selectedDate!.year &&
        billDate.month == _selectedDate!.month &&
        billDate.day == _selectedDate!.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Bill Reports",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bills')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading bills."));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allBills = snapshot.data!.docs;
          final filteredBills = allBills.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _matchesFilter(data);
          }).toList();

          // Summary
          final totalBills = filteredBills.length;
          final totalRevenue = filteredBills.fold<double>(0, (sum, doc) {
            final data = doc.data() as Map<String, dynamic>;
            return sum + (data['billTotal'] ?? 0);
          });

          return Column(
            children: [
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Search by employee name",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchEmployee = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: Colors.black,
                            ),
                            icon: const Icon(Icons.calendar_month),
                            label: Text(_selectedDate == null
                                ? "Filter by Date"
                                : DateFormat('dd MMM yyyy')
                                .format(_selectedDate!)),
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2023),
                                lastDate: DateTime.now(),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _selectedDate = pickedDate;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (_selectedDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _selectedDate = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Summary Box
              Container(
                margin:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("🧾 Total Bills: $totalBills"),
                    Text("💰 Revenue: ₹${totalRevenue.toStringAsFixed(0)}"),
                  ],
                ),
              ),

              // Bill List
              Expanded(
                child: filteredBills.isEmpty
                    ? const Center(child: Text("No matching bills found."))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filteredBills.length,
                  itemBuilder: (context, index) {
                    final doc = filteredBills[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final items =
                    List<Map<String, dynamic>>.from(data['items']);
                    final date = data['createdAt'] != null
                        ? formatDate(data['createdAt'])
                        : 'Unknown';


                    final isExpanded = _expandedBillIds.contains(doc.id);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedBillIds.remove(doc.id);
                          } else {
                            _expandedBillIds.add(doc.id);
                          }
                        });
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "👷 Employee: ${data['employeeName'] ?? 'N/A'}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text("🕒 Date: $date"),
                              if (isExpanded) ...[
                                const Divider(height: 20),
                                ...items.map(
                                      (item) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("${item['name']} x${item['quantity']}"),
                                        Text("₹${item['total']}"),
                                      ],
                                    ),
                                  ),
                                ),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Total",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "₹${data['billTotal']}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );

                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
