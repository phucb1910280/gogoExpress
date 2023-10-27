import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gogoship/UI/homepage.dart';
import 'package:gogoship/UI/orders_detail/taking_detail.dart';
import 'package:gogoship/models/orders.dart';
import 'package:gogoship/models/suppliers.dart';
import 'package:gogoship/shared/mcolors.dart';

class TakingOrdersScreen extends StatefulWidget {
  const TakingOrdersScreen({super.key});

  @override
  State<TakingOrdersScreen> createState() => _TakingOrdersScreenState();
}

class _TakingOrdersScreenState extends State<TakingOrdersScreen> {
  List<Orders> takingOrdersDetail = [];
  List<Suppliers> supplierDetail = [];
  bool isLoading = true;

  @override
  void initState() {
    getOrderData();
    if (HomePage.takingOrders.isEmpty) {
      setState(() {
        isLoading = false;
      });
    }
    super.initState();
  }

  getOrderData() async {
    for (var element in HomePage.takingOrders) {
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
        supplierID: "",
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
          order.supplierID = data["supplierID"];
        });
        takingOrdersDetail.add(order);
        getUserData(order.supplierID);
      }
    }
  }

  getUserData(String customersID) async {
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
        .doc(customersID)
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
      if (supplierDetail.length == HomePage.takingOrders.length) {
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
        title: const Text("Đang lấy"),
        backgroundColor: MColors.lightPink,
      ),
      backgroundColor: MColors.background,
      body: !isLoading
          ? ListView.builder(
              itemCount: HomePage.takingOrders.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TakingOrderDetailScreen(
                        order: takingOrdersDetail[index],
                        suppliers: supplierDetail[index],
                      ),
                    ),
                  ),
                  child: orderShortInfo(
                    takingOrdersDetail[index].iD,
                    supplierDetail[index].brand,
                    supplierDetail[index].phoneNumber,
                    supplierDetail[index].address,
                  ),
                );
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget orderShortInfo(
      String orderID, String brand, String phoneNumber, String address) {
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
                  mText("Cửa hàng:", brand),
                  const SizedBox(height: 10),
                  mText("Số ĐT", phoneNumber),
                  const SizedBox(height: 10),
                  mText("Địa chỉ:", address),
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
