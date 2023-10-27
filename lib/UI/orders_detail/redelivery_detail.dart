import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gogoship/UI/homepage.dart';
import 'package:gogoship/UI/orders/delivering.dart';
import 'package:gogoship/models/customers.dart';
import 'package:gogoship/models/orders.dart';
import 'package:gogoship/shared/mcolors.dart';
import 'package:intl/intl.dart';

class RedeliveryDetailScreen extends StatefulWidget {
  final Orders order;
  final Customers customer;
  const RedeliveryDetailScreen(
      {super.key, required this.order, required this.customer});

  @override
  State<RedeliveryDetailScreen> createState() => _RedeliveryDetailScreenState();
}

class _RedeliveryDetailScreenState extends State<RedeliveryDetailScreen> {
  double s = 0;
  double t = 0;
  bool isLoading = true;

  @override
  void initState() {
    s = double.parse(widget.order.transportFee);
    t = double.parse(widget.order.totalAmount);
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MColors.background,
      appBar: AppBar(
        title: const Text("Chi tiết đơn hàng"),
        backgroundColor: MColors.background,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: MColors.blue,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            mText("Mã đơn", widget.order.iD, bold: true),
                            mText("Ngày đặt hàng:", widget.order.orderDay),
                            mText("Trạng thái ĐH:", widget.order.status,
                                bold: true),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: MColors.blue,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            mText("Người nhận:", widget.customer.fullName,
                                bold: true),
                            mText("Số ĐT:", widget.customer.phoneNumber),
                            mText("Địa chỉ:", widget.customer.address),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: MColors.blue,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(2),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    size: 10,
                                    color: MColors.darkBlue,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    widget.order.payments,
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    size: 10,
                                    color: MColors.darkBlue,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    widget.order.paymentStatus,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: MColors.darkBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: MColors.blue,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Lý do tạm hoãn:",
                              style: TextStyle(
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.order.delayReason.toString(),
                              style: const TextStyle(
                                fontSize: 22,
                                color: MColors.darkBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            mText(
                              "Ngày giao lại:",
                              widget.order.redeliveryDate.toString(),
                              bold: true,
                              fontSize: 24,
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    mText(
                      "Tạm tính:",
                      NumberFormat.simpleCurrency(
                              locale: 'vi-VN', decimalDigits: 0)
                          .format(
                        double.parse(widget.order.totalAmount),
                      ),
                      fontSize: 25,
                    ),
                    mText(
                      "Phí vận chuyển:",
                      NumberFormat.simpleCurrency(
                              locale: 'vi-VN', decimalDigits: 0)
                          .format(
                        double.parse(widget.order.transportFee),
                      ),
                      fontSize: 25,
                    ),
                    mText(
                      "Tổng cộng:",
                      NumberFormat.simpleCurrency(
                              locale: 'vi-VN', decimalDigits: 0)
                          .format(s + t),
                      fontSize: 25,
                      bold: true,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: ElevatedButton(
          onPressed: () async => change2Delivering(),
          style: ElevatedButton.styleFrom(
            backgroundColor: MColors.blue,
            foregroundColor: MColors.white,
            minimumSize: const Size.fromHeight(55),
          ),
          child: const Text(
            "Giao lại",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget mText(String title, String content,
      {bool bold = false, double fontSize = 20}) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Flexible(
            child: Text(
              content,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: fontSize,
                color: MColors.darkBlue,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> change2Delivering() async {
    onSaving();
    try {
      await FirebaseFirestore.instance
          .collection("Orders")
          .doc(widget.order.iD)
          .update({
        "status": "Đang giao hàng",
        "redeliveryDate": "",
      });
      setState(() {
        HomePage.deliveringOrders = [];
        DeliveringScreen.customersDetail = [];
        DeliveringScreen.deliveringOrdersDetail = [];
      });
      List changeStatusOrder = [widget.order.iD];
      await FirebaseFirestore.instance
          .collection("Shippers")
          .doc(FirebaseAuth.instance.currentUser!.email)
          .update({
        "redeliveryOrders": FieldValue.arrayRemove(changeStatusOrder),
        "deliveringOrders": FieldValue.arrayUnion(changeStatusOrder),
      }).then((value) {
        setState(() {
          isLoading = false;
        });
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> onSaving() async {
    if (isLoading) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: const SizedBox(
              height: 100,
              width: 100,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          );
        },
      );
    }
  }
}
