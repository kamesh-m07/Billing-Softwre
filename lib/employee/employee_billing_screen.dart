import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'bill_pdf.dart';

class EmployeeBillingScreen extends StatefulWidget {
  const EmployeeBillingScreen({super.key});

  @override
  State<EmployeeBillingScreen> createState() => _EmployeeBillingScreenState();
}

class _EmployeeBillingScreenState extends State<EmployeeBillingScreen> {
  Map<String, int> quantities = {}; // productId -> quantity
  bool isLoading = false;
  String message = '';

  Future<Map<String, dynamic>?> _generateBill(
    List<DocumentSnapshot> products,
  ) async {
    final selectedItems =
        products
            .where(
              (doc) => quantities[doc.id] != null && quantities[doc.id]! > 0,
            )
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final qty = quantities[doc.id]!;
              final price = data['price'] ?? 0;
              return {
                'productId': doc.id,
                'name': data['name'],
                'price': price,
                'quantity': qty,
                'total': price * qty,
              };
            })
            .toList();

    if (selectedItems.isEmpty) {
      setState(() => message = "Select at least one product.");
      return null;
    }

    // final total = selectedItems.fold(
    //   0,
    //   (sum, item) => sum + (item['total'] as int),
    // );
    final total = selectedItems.fold<int>(
  0,
  (sum, item) => sum + ((item['total'] as num).toInt()),
);
    final user = FirebaseAuth.instance.currentUser;
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
    final employeeName = userDoc.data()?['name'] ?? 'Employee';

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('bills').add({
        'employeeId': user.uid,
        'employeeName': employeeName,
        'items': selectedItems,
        'billTotal': total,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        message = "Bill created successfully!";
        quantities.clear();
      });

      return {'items': selectedItems, 'total': total};
    } catch (e) {
      setState(() => message = "Error: $e");
      return null;
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Employee Home")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading products"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final id = docs[index].id;

                    return ListTile(
                      title: Text(data['name']),
                      subtitle: Text("₹${data['price']}"),
                      trailing: SizedBox(
                        width: 120,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  quantities[id] = (quantities[id] ?? 0) - 1;
                                  if (quantities[id]! <= 0)
                                    quantities.remove(id);
                                });
                              },
                            ),
                            Text('${quantities[id] ?? 0}'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  quantities[id] = (quantities[id] ?? 0) + 1;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                message,
                style: TextStyle(
                  color:
                      message.contains("success") ? Colors.green : Colors.red,
                ),
              ),
            ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: CircularProgressIndicator(),
            )
          else
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final snapshot =
                        await FirebaseFirestore.instance
                            .collection('products')
                            .get();
                    final billData = await _generateBill(snapshot.docs);

                    if (billData != null) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => BillPdfPreviewScreen(
                                items: billData['items'],
                                total: billData['total'],
                              ),
                        ),
                      );
                    }
                  } catch (e, stackTrace) {
                    print("ERROR $e");
                    print(stackTrace);
                  }
                },

                child: const Text("Generate Bill"),
              ),
            ),
        ],
      ),
    );
  }
}
