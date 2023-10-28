import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gogoship/UI/homepage.dart';
import 'package:gogoship/UI/orders_detail/re_taking_detail.dart';
import 'package:gogoship/models/orders.dart';
import 'package:gogoship/models/suppliers.dart';
import 'package:gogoship/shared/mcolors.dart';

class ReTakingScreen extends StatefulWidget {
  const ReTakingScreen({super.key});

  @override
  State<ReTakingScreen> createState() => _ReTakingScreenState();
}

class _ReTakingScreenState extends State<ReTakingScreen> {
  List<Orders> reTakingOrdersDetail = [];
  List<Suppliers> supplierDetail = [];
  bool isLoading = true;

  @override
  void initState() {
    if (HomePage.reTakingOrders.isEmpty) {
      setState(() {
        isLoading = false;
      });
    }
    getOrderData();
    super.initState();
  }

  getOrderData() async {
    for (var element in HomePage.reTakingOrders) {
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
          order.reTakingDay = data["reTakingDay"];
          order.deliveredDay = data["deliveredDay"];
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
        reTakingOrdersDetail.add(order);
        getUserData(order.supplierID);
      }
    }
  }

  getUserData(String supplierID) async {
    var supplier = Suppliers(
        id: "",
        brand: "",
        email: "",
        address: "",
        phoneNumber: "",
        long: 0,
        lat: 0);
    var data = await FirebaseFirestore.instance
        .collection("Suppliers")
        .doc(supplierID)
        .get();
    if (data.exists) {
      setState(() {
        supplier.id = data["id"];
        supplier.brand = data["brand"];
        supplier.email = data["email"];
        supplier.address = data["address"];
        supplier.phoneNumber = data["phoneNumber"];
        supplier.lat = data["lat"];
        supplier.long = data["long"];
      });
      supplierDetail.add(supplier);
      if (supplierDetail.length == HomePage.reTakingOrders.length) {
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
        title: const Text("Đơn hẹn lấy"),
        backgroundColor: MColors.lightBlue2,
      ),
      backgroundColor: MColors.background,
      body: !isLoading
          ? reTakingOrdersDetail.isNotEmpty
              ? ListView.builder(
                  itemCount: HomePage.reTakingOrders.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RetakingDetailScreen(
                              order: reTakingOrdersDetail[index],
                              supplier: supplierDetail[index],
                            ),
                          ),
                        );
                      },
                      child: orderShortInfo(
                        reTakingOrdersDetail[index].iD,
                        supplierDetail[index].brand,
                        reTakingOrdersDetail[index].status,
                        reTakingOrdersDetail[index].delayReason!,
                        reTakingOrdersDetail[index].reTakingDay,
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

  Widget orderShortInfo(String orderID, String supplier, String status,
      String delayReason, String reTakingDay) {
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
                  mText("Cửa hàng:", supplier),
                  const SizedBox(height: 10),
                  mText("Trạng thái:", status),
                  const SizedBox(height: 10),
                  mText("Lý do:", delayReason),
                  const SizedBox(height: 10),
                  mText("Ngày hẹn lấy:", reTakingDay),
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
