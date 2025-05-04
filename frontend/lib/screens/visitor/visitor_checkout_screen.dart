import 'package:flutter/material.dart';
import 'package:kikao_homes/core/providers/visit_provider.dart';
import 'package:provider/provider.dart';

class VisitorCheckoutScreen extends StatefulWidget {
  const VisitorCheckoutScreen({super.key});

  @override
  State<VisitorCheckoutScreen> createState() => _VisitorCheckoutScreenState();
}

class _VisitorCheckoutScreenState extends State<VisitorCheckoutScreen> {
  final TextEditingController _nationalIdController = TextEditingController();
  bool _isLoading = false;

  Future<void> _completeCheckout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final visitProvider = Provider.of<VisitProvider>(context, listen: false);
      await visitProvider.checkoutVisit(_nationalIdController.text);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkout successful')),
      );
      
      // Navigate back after successful checkout
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout failed: ${e.toString()}')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nationalIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E0D8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Visitor Checkout',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A6B5D),
                ),
              ),
              const SizedBox(height: 30),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Please enter your National ID to complete checkout',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4A6B5D),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField('National ID', Icons.credit_card),
                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _completeCheckout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCC7357),
                            minimumSize: const Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Complete Checkout',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF4A6B5D)),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
