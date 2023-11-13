import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gogoship/UI/homepage.dart';
import 'package:gogoship/UI/map_view.dart';
import 'package:gogoship/shared/mcolors.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class ReDeliveryDetail extends StatefulWidget {
  final String orderID;
  final String customerID;
  const ReDeliveryDetail(
      {super.key, required this.orderID, required this.customerID});

  @override
  State<ReDeliveryDetail> createState() => _ReDeliveryDetailState();
}

class _ReDeliveryDetailState extends State<ReDeliveryDetail> {
  bool isLoading = true;
  String time = "";
  String today = "";
  List<String> deliveryHistory = [];

  @override
  void initState() {
    var t = DateTime.now();
    setState(() {
      today = "${t.day}/${t.month}/${t.year}";
      time = "${t.day}/${t.month}: ";
    });
    super.initState();
  }

  makingPhoneCall(String phoneNumber) async {
    var url = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> confirmReDeliveryOrder() async {
    if (true) {
      onSaving();
      List changeStatusOrder = [widget.orderID];
      deliveryHistory.add("$timeĐang giao hàng");
      try {
        await FirebaseFirestore.instance
            .collection("Orders")
            .doc(widget.orderID)
            .update({
          "reDeliveryDay": "",
          "delayDeliveryReason": "",
          "status": "Đang giao hàng",
          "deliveryHistory": FieldValue.arrayUnion(deliveryHistory),
        });
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
              (route) => false);
        });
      } catch (e) {
        debugPrint(e.toString());
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Đơn hàng ${widget.orderID}"),
        backgroundColor: MColors.white,
      ),
      backgroundColor: MColors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Orders")
              .doc(widget.orderID)
              .snapshots(),
          builder: (context, orderSnap) {
            if (orderSnap.hasData) {
              deliveryHistory = List.from(orderSnap.data!["deliveryHistory"]);
              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("Users")
                    .doc(widget.customerID)
                    .snapshots(),
                builder: (context, customer) {
                  if (customer.hasData) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "THÔNG TIN ĐƠN HÀNG",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: MColors.yelow,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  mText("Mã đơn:", orderSnap.data!["orderID"]),
                                  mText(
                                      "Ngày đặt:", orderSnap.data!["orderDay"]),
                                  mText(
                                      "Trạng thái:", orderSnap.data!["status"]),
                                  mText("Lý do:",
                                      "${orderSnap.data!["delayDeliveryReason"]}"),
                                  mText("Ngày hẹn giao:",
                                      "${orderSnap.data!["reDeliveryDay"]}"),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: MColors.yelow,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  mText("Hình thức:",
                                      orderSnap.data!["payments"]),
                                  mText("Thanh toán:",
                                      orderSnap.data!["paymentStatus"]),
                                  mText(
                                      "Trạng thái:", orderSnap.data!["status"]),
                                  SizedBox(
                                    height: 20,
                                    child: Divider(
                                      color: MColors.yelow.withOpacity(.3),
                                    ),
                                  ),
                                  mText(
                                      "Tiền hàng:",
                                      NumberFormat.simpleCurrency(
                                              locale: 'vi-VN', decimalDigits: 0)
                                          .format(
                                              orderSnap.data!["orderTotal"])),
                                  mText(
                                      "Phí ship:",
                                      NumberFormat.simpleCurrency(
                                              locale: 'vi-VN', decimalDigits: 0)
                                          .format(
                                              orderSnap.data!["transportFee"])),
                                  mText(
                                      "Tổng cộng:",
                                      NumberFormat.simpleCurrency(
                                              locale: 'vi-VN', decimalDigits: 0)
                                          .format(orderSnap.data!["total"])),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "THÔNG TIN KHÁCH HÀNG",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: MColors.yelow,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  mText("Khách hàng:",
                                      customer.data!["fullName"]),
                                  mText("Điện thoại:",
                                      customer.data!["phoneNumber"]),
                                  mText("Địa chỉ:", customer.data!["address"]),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => MyMapView(
                                                  coordinates: LatLng(
                                                    customer.data!["lat"],
                                                    customer.data!["long"],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: MColors.blue,
                                            foregroundColor: MColors.background,
                                            minimumSize:
                                                const Size.fromHeight(50),
                                          ),
                                          icon: const Icon(
                                              Icons.roundabout_left_rounded),
                                          label: const Text(
                                            "Đường đi",
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        flex: 1,
                                        child: ElevatedButton.icon(
                                          onPressed: () async =>
                                              makingPhoneCall(customer
                                                  .data!["phoneNumber"]),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green[600],
                                            foregroundColor: MColors.background,
                                            minimumSize:
                                                const Size.fromHeight(50),
                                          ),
                                          icon: const Icon(Icons.phone),
                                          label: const Text(
                                            "Gọi",
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: () async => confirmReDeliveryOrder(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: MColors.white,
                              minimumSize: const Size.fromHeight(55),
                            ),
                            child: const Text(
                              "Chuẩn bị giao hàng",
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    );
                  } else {
                    return const Text("");
                  }
                },
              );
            } else {
              return const Text("");
            }
          },
        ),
      ),
    );
  }

  Widget mText(String title, String content) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
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
              style: const TextStyle(
                fontSize: 20,
                color: MColors.darkBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
