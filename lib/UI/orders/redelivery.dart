import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gogoship/UI/homepage.dart';
import 'package:gogoship/UI/orders_detail/redelivery_detail.dart';
import 'package:gogoship/models/customers.dart';
import 'package:gogoship/models/orders.dart';
import 'package:gogoship/shared/mcolors.dart';
import 'package:intl/intl.dart';

class RedeliveryScreen extends StatefulWidget {
  const RedeliveryScreen({super.key});

  @override
  State<RedeliveryScreen> createState() => _RedeliveryScreenState();
}

class _RedeliveryScreenState extends State<RedeliveryScreen> {
  List<Orders> redeliveryOrdersDetail = [];
  List<Customers> customersDetail = [];
  bool isLoading = true;

  @override
  void initState() {
    if (HomePage.redeliveryOrders.isEmpty) {
      setState(() {
        isLoading = false;
      });
    }
    getOrderData();
    super.initState();
  }

  getOrderData() async {
    for (var element in HomePage.redeliveryOrders) {
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
          order.status = data["status"];
          order.totalAmount = data["totalAmount"].toString();
          order.transportFee = data["transportFee"].toString();
          order.cancelReason = data["cancelReason"];
          order.delayReason = data["delayReason"];
          order.redeliveryDate = data["redeliveryDate"];
          order.deliveredImg = data["deliveredImg"];
          order.payments = data["payments"];
          order.paymentStatus = data["paymentStatus"];
          order.isNewOrder = data["isNewOrder"];
          order.supplierID = data["supplierID"];
        });
        redeliveryOrdersDetail.add(order);
        getUserData(order.customerID);
      }
    }
  }

  getUserData(String customersID) async {
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
        .doc(customersID)
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
      customersDetail.add(customer);
      if (customersDetail.length == HomePage.redeliveryOrders.length) {
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
        title: const Text("Tạm hoãn"),
        backgroundColor: MColors.yelow,
      ),
      backgroundColor: MColors.background,
      body: !isLoading
          ? ListView.builder(
              itemCount: HomePage.redeliveryOrders.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RedeliveryDetailScreen(
                        order: redeliveryOrdersDetail[index],
                        customer: customersDetail[index],
                      ),
                    ),
                  ),
                  child: orderShortInfo(
                    redeliveryOrdersDetail[index].iD,
                    customersDetail[index].fullName,
                    redeliveryOrdersDetail[index].status,
                    redeliveryOrdersDetail[index].delayReason!,
                    redeliveryOrdersDetail[index].totalAmount,
                    redeliveryOrdersDetail[index].redeliveryDate!,
                  ),
                );
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget orderShortInfo(String orderID, String customeName, String status,
      String delayReason, String totalAmount, String redeliveryDate) {
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
                  mText("Trạng thái:", status),
                  const SizedBox(height: 10),
                  mText("Lý do:", delayReason),
                  const SizedBox(height: 10),
                  mText("Ngày giao lại:", redeliveryDate),
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