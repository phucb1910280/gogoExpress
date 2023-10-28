import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gogoship/UI/homepage.dart';
import 'package:gogoship/UI/orders_detail/delivered_detail.dart';
import 'package:gogoship/models/customers.dart';
import 'package:gogoship/models/orders.dart';
import 'package:gogoship/shared/mcolors.dart';
import 'package:intl/intl.dart';

class DeliveredScreen extends StatefulWidget {
  const DeliveredScreen({super.key});

  @override
  State<DeliveredScreen> createState() => _DeliveredScreenState();
}

class _DeliveredScreenState extends State<DeliveredScreen> {
  List<Orders> deliveredOrdersDetail = [];
  List<Customers> customersDetail = [];
  bool isLoading = true;
  String thisMonth = "";

  @override
  void initState() {
    var t = DateTime.now();
    setState(() {
      thisMonth = t.month.toString();
    });
    if (HomePage.deliveredOrders.isEmpty) {
      setState(() {
        isLoading = false;
      });
    }
    getOrderData();
    super.initState();
  }

  getOrderData() async {
    for (var element in HomePage.deliveredOrders) {
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
          order.reTakingDay = data["reTakingDay"];
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
        deliveredOrdersDetail.add(order);
        getUserData(order.customerID);
      }
    }
  }

  getUserData(String customerID) async {
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
      customersDetail.add(customer);
      if (customersDetail.length == HomePage.deliveredOrders.length) {
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
        title: Text("Đã giao trong tháng $thisMonth"),
        backgroundColor: MColors.lightGreen2,
      ),
      backgroundColor: MColors.background,
      body: !isLoading
          ? deliveredOrdersDetail.isNotEmpty
              ? ListView.builder(
                  itemCount: HomePage.deliveredOrders.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeliveredDetailScreen(
                            order: deliveredOrdersDetail[index],
                            customer: customersDetail[index],
                          ),
                        ),
                      ),
                      child: orderShortInfo(
                          deliveredOrdersDetail[index].iD,
                          deliveredOrdersDetail[index].totalAmount,
                          customersDetail[index].fullName,
                          deliveredOrdersDetail[index].status,
                          deliveredOrdersDetail[index].deliveredDay!),
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

  Widget orderShortInfo(String orderID, String totalAmount, String customerName,
      String status, String deliveredDay) {
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
                  mText("Mã đơn:", orderID, bold: true),
                  const SizedBox(height: 10),
                  mText(
                      "Tổng tiền:",
                      NumberFormat.simpleCurrency(
                              locale: 'vi-VN', decimalDigits: 0)
                          .format(double.parse(totalAmount)),
                      bold: true),
                  const SizedBox(height: 10),
                  mText("Khách hàng:", customerName),
                  const SizedBox(height: 10),
                  mText("Trạng thái:", status, bold: true),
                  const SizedBox(height: 10),
                  mText("Ngày giao:", deliveredDay),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget mText(String title, String content, {bool bold = false}) {
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
            style: TextStyle(
              fontSize: 22,
              color: MColors.darkBlue,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
