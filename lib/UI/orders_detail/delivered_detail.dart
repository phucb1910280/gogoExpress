import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gogoship/models/customers.dart';
import 'package:gogoship/models/orders.dart';
import 'package:gogoship/shared/mcolors.dart';
import 'package:intl/intl.dart';

class DeliveredDetailScreen extends StatefulWidget {
  final Orders order;
  final Customers customer;
  const DeliveredDetailScreen(
      {super.key, required this.order, required this.customer});

  @override
  State<DeliveredDetailScreen> createState() => _DeliveredDetailScreenState();
}

class _DeliveredDetailScreenState extends State<DeliveredDetailScreen> {
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
                            mText(
                              "Ngày giao hàng:",
                              widget.order.deliveredDay.toString(),
                            )
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
                    const SizedBox(
                      height: 20,
                    ),
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
                    SizedBox(
                      height: 40,
                      child: Divider(
                        color: MColors.darkBlue.withOpacity(.3),
                      ),
                    ),
                    const Row(
                      children: [
                        Text(
                          "* Hình ảnh giao hàng",
                          style: TextStyle(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Image.network(
                      widget.order.deliveredImg.toString(),
                    ),
                    const SizedBox(height: 10),
                  ],
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
}
