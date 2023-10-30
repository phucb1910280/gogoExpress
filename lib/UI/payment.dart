import 'package:flutter/material.dart';
import 'package:gogoship/shared/mcolors.dart';

class PaymentScreen extends StatefulWidget {
  final double total;
  const PaymentScreen({super.key, required this.total});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thanh toán khoảng thu"),
        backgroundColor: MColors.lightBlue,
      ),
      backgroundColor: MColors.background,
      body: Column(
        children: [
          Text("Data"),
        ],
      ),
    );
  }
}
