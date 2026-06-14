import 'package:billing_software/admin/product_list_screen.dart';
import 'package:billing_software/admin/view_bill_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../login_screen.dart';
import 'add_employee_screen.dart';
import 'add_product_screen.dart';
import 'employee_list_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _slideAnimations = List.generate(5, (index) {
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            0.1 * index,
            0.6 + 0.1 * index,
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    _fadeAnimations = List.generate(5, (index) {
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(0.1 * index, 0.6 + 0.1 * index, curve: Curves.easeIn),
      );
    });

    _controller.forward();
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _buildAnimatedEntry({required int index, required Widget child}) {
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(position: _slideAnimations[index], child: child),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDashboardButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.black),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD4AF37), // Gold
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
      onPressed: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4AF37),
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      backgroundColor: Colors.white,
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _logout(context);
                          },
                          child: const Text(
                            'Yes',
                            style: TextStyle(color: Color(0xFFD4AF37)),
                          ),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildAnimatedEntry(
              index: 0,
              child: Text(
                "Welcome Admin\n${user?.email ?? ''}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildAnimatedEntry(
              index: 1,
              child: _buildDashboardButton(
                icon: Icons.person_add,
                label: "Add User Screen",
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddUserScreen()),
                    ),
              ),
            ),
            const SizedBox(height: 20),
            _buildAnimatedEntry(
              index: 2,
              child: _buildDashboardButton(
                icon: Icons.add_box,
                label: "Add Product",
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddProductScreen(),
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 20),
            _buildAnimatedEntry(
              index: 3,
              child: _buildDashboardButton(
                icon: Icons.receipt_long,
                label: "View Bills Report",
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ViewBillsScreen(),
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 20),
            _buildAnimatedEntry(
              index: 4,
              child: _buildDashboardButton(
                icon: Icons.list_alt,
                label: "Product List",
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProductListScreen(),
                      ),
                    ),
              ),
            ),

            const SizedBox(height: 20),
            _buildAnimatedEntry(
              index: 4,
              child: _buildDashboardButton(
                icon: Icons.list_alt,
                label: "Employee List",
                onTap:
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EmployeeListScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
