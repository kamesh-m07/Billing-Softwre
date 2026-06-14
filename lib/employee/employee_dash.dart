import 'package:billing_software/employee/EmployeeViewMyBillsScreen.dart';
import 'package:billing_software/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'employee_billing_screen.dart';

class EmployeeDashboardScreen extends StatelessWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("No"),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Yes"),
                        ),
                      ],
                    ),
              );

              if (confirm == true) {
                await FirebaseAuth.instance.signOut();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 5,
              child: ListTile(
                leading: const Icon(
                  Icons.receipt_long,
                  size: 40,
                  color: Colors.blue,
                ),
                title: const Text(
                  "Generate Bill",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("Create customer bills"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EmployeeBillingScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 5,
              child: ListTile(
                leading: const Icon(
                  Icons.history,
                  size: 40,
                  color: Colors.green,
                ),
                title: const Text(
                  "My Bills",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("View generated bills"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EmployeeViewMyBillsScreen(),
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
