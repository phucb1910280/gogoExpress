import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gogoship/UI/homepage.dart';
import 'package:gogoship/UI/orders_detail/delivering_detail.dart';
import 'package:gogoship/models/customers.dart';
import 'package:gogoship/models/orders.dart';
import 'package:gogoship/shared/mcolors.dart';
import 'package:intl/intl.dart';

class DeliveringScreen extends StatefulWidget {
  const DeliveringScreen({super.key});
  static List<Orders> deliveringOrdersDetail = [];
  static List<Customers> customersDetail = [];

  @override
  State<DeliveringScreen> createState() => _DeliveringScreenState();
}

class _DeliveringScreenState extends State<DeliveringScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    resetList();
    if (HomePage.deliveringOrders.isEmpty) {
      setState(() {
        isLoading = false;
      });
    }
    getOrderData();
  }

  void resetList() {
    setState(() {
      DeliveringScreen.deliveringOrdersDetail = [];
      DeliveringScreen.customersDetail = [];
    });
  }

  Future<void> getOrderData() async {
    for (var element in HomePage.deliveringOrders) {
      var order = Orders(
        iD: "",
        customerID: "",
        deliverID: "",
        orderDay: "",
        status: "",
        totalAmount: "",
        transportFee: "",
        cancelReason: "",
        delayReason: "",
        redeliveryDate: "",
        deliveredImg: "",
        payments: "",
        paymentStatus: "",
        supplierID: '',
        deliveredDay: '',
        reTakingDay: '',
      );
      var data = await FirebaseFirestore.instance
          .collection("Orders")
          .doc(element)
          .get();
      if (data.exists) {
        setState(() {
          order.iD = data["id"];
          order.customerID = data["customerID"];
          order.deliverID = data["deliverID"];
          order.orderDay = data["orderDay"];
          order.deliveredDay = data["deliveredDay"];
          order.status = data["status"];
          order.totalAmount = data["totalAmount"].toString();
          order.transportFee = data["transportFee"].toString();
          order.cancelReason = data["cancelReason"];
          order.delayReason = data["delayReason"];
          order.redeliveryDate = data["redeliveryDate"];
          order.deliveredImg = data["deliveredImg"];
          order.reTakingDay = data["reTakingDay"];
          order.payments = data["payments"];
          order.paymentStatus = data["paymentStatus"];
          order.isNewOrder = data["isNewOrder"];
          order.supplierID = data["supplierID"];
        });
        DeliveringScreen.deliveringOrdersDetail.add(order);
        getUserData(order.customerID);
      }
    }
  }

  Future<void> markAsRead(int index) async {
    setState(() {
      DeliveringScreen.deliveringOrdersDetail[index].isNewOrder = false;
    });
    await FirebaseFirestore.instance
        .collection("Orders")
        .doc(DeliveringScreen.deliveringOrdersDetail[index].iD)
        .update({
      "isNewOrder": false,
    });
  }

  Future<void> getUserData(String customerID) async {
    var customer = Customers(
        id: "",
        fullName: "",
        email: "",
        address: "",
        phoneNumber: "",
        lat: 0,
        long: 0);
    var data = await FirebaseFirestore.instance
        .collection("Users")
        .doc(customerID)
        .get();
    if (data.exists) {
      setState(() {
        customer.id = data["id"];
        customer.fullName = data["fullName"];
        customer.email = data["email"];
        customer.address = data["address"];
        customer.phoneNumber = data["phoneNumber"];
        customer.lat = data["lat"];
        customer.long = data["long"];
      });
      DeliveringScreen.customersDetail.add(customer);
      if (DeliveringScreen.customersDetail.length ==
          HomePage.deliveringOrders.length) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đang giao"),
        backgroundColor: MColors.lightBlue,
      ),
      backgroundColor: MColors.background,
      body: !isLoading
          ? DeliveringScreen.deliveringOrdersDetail.isNotEmpty
              ? ListView.builder(
                  itemCount: HomePage.deliveringOrders.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        markAsRead(index).then(
                          (value) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeliveringDetailScreen(
                                order: DeliveringScreen
                                    .deliveringOrdersDetail[index],
                                customer:
                                    DeliveringScreen.customersDetail[index],
                              ),
                            ),
                          ),
                        );
                      },
                      child: orderShortInfo(
                        DeliveringScreen
                            .deliveringOrdersDetail[index].isNewOrder!,
                        DeliveringScreen.deliveringOrdersDetail[index].iD,
                        DeliveringScreen.customersDetail[index].fullName,
                        DeliveringScreen.customersDetail[index].address,
                        DeliveringScreen
                            .deliveringOrdersDetail[index].totalAmount,
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text(
                  "Danh sách rỗng",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ))
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget orderShortInfo(bool isNewOrder, String orderID, String customeName,
      String customerAddress, String totalAmount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: MColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.4),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: const Offset(0, 4),
                ),
              ],
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 1],
                colors: [
                  Colors.white,
                  Color.fromARGB(255, 237, 237, 237),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isNewOrder
                      ? const Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 20,
                              color: Colors.green,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Đơn mới",
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(),
                  SizedBox(height: isNewOrder ? 15 : 0),
                  mText("Mã đơn:", orderID),
                  const SizedBox(height: 10),
                  mText(
                      "Tổng tiền:",
                      NumberFormat.simpleCurrency(
                              locale: 'vi-VN', decimalDigits: 0)
                          .format(double.parse(totalAmount))),
                  const SizedBox(height: 10),
                  mText("Khách hàng:", customeName),
                  const SizedBox(height: 10),
                  mText("Địa chỉ:", customerAddress),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget mText(String title, String content) {
    return Row(
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
            style: const TextStyle(
              fontSize: 22,
              color: MColors.darkBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
