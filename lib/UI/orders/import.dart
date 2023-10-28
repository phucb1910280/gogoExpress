import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gogoship/UI/homepage.dart';
import 'package:gogoship/models/orders.dart';
import 'package:gogoship/models/suppliers.dart';
import 'package:gogoship/shared/mcolors.dart';

class ImportOrders extends StatefulWidget {
  const ImportOrders({super.key});

  @override
  State<ImportOrders> createState() => _ImportOrdersState();
}

class _ImportOrdersState extends State<ImportOrders> {
  List<Orders> importOrdersDetail = [];
  List<Suppliers> supplierDetail = [];
  bool isLoading = true;

  @override
  void initState() {
    resetList();
    getImportData();
    getOrderData();
    Timer(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  resetList() {
    importOrdersDetail = [];
    supplierDetail = [];
  }

  getImportData() async {
    var todayData = await FirebaseFirestore.instance
        .collection("Shippers")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();
    HomePage.importOrders = List.from(todayData["importOrders"]);
  }

  getOrderData() async {
    for (var element in HomePage.importOrders) {
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
          order.supplierID = data["supplierID"];
        });
        importOrdersDetail.add(order);
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
      if (supplierDetail.length == HomePage.importOrders.length) {
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
        title: const Text("Chờ nhập kho"),
        backgroundColor: MColors.lightOrange,
        leading: IconButton(
          onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      backgroundColor: MColors.background,
      body: isLoading == false
          ? importOrdersDetail.isNotEmpty
              ? ListView.builder(
                  itemCount: importOrdersDetail.length,
                  itemBuilder: (context, index) {
                    return orderShortInfo(
                      importOrdersDetail[index].iD,
                      supplierDetail[index].brand,
                      importOrdersDetail[index].status,
                      index,
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

  Widget orderShortInfo(
      String orderID, String brand, String status, int index) {
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
                  mText("Tình trạng:", status),
                  const SizedBox(height: 10),
                  importButton(orderID, index),
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

  Widget importButton(String orderID, int index) {
    return ElevatedButton(
      onPressed: () async {
        setState(() {
          isLoading = true;
        });
        List changeStatusOrder = [orderID];
        try {
          importOrdersDetail.removeAt(index);
          supplierDetail.removeAt(index);
          await FirebaseFirestore.instance
              .collection("Orders")
              .doc(orderID)
              .update({
            "status": "Đã nhập kho",
          });
          await FirebaseFirestore.instance
              .collection("Shippers")
              .doc(FirebaseAuth.instance.currentUser!.email)
              .update({
            "importOrders": FieldValue.arrayRemove(changeStatusOrder),
          }).then((value) {
            setState(() {
              isLoading = false;
            });
          });
        } catch (e) {
          debugPrint(e.toString());
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: MColors.lightOrange,
        foregroundColor: MColors.white,
        minimumSize: const Size.fromHeight(55),
      ),
      child: const Text(
        "Nhập hàng",
        style: TextStyle(
          fontSize: 20,
        ),
      ),
    );
  }
}
