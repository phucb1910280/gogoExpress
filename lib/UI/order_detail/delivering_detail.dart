import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gogoship/UI/homepage.dart';
import 'package:gogoship/UI/map_view.dart';
import 'package:gogoship/shared/mcolors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveringDetail extends StatefulWidget {
  final String orderID;
  final String customerID;
  const DeliveringDetail(
      {super.key, required this.orderID, required this.customerID});

  @override
  State<DeliveringDetail> createState() => _DeliveringDetailState();
}

class _DeliveringDetailState extends State<DeliveringDetail> {
  XFile? file;
  String path = "";
  bool tookImg = false;
  bool isLoading = true;
  bool hideDelayRequest = true;

  int delayChoice = 1;
  String delayDeliveryReason = 'Khách hẹn ngày giao';
  bool responsibility = false;
  String reDeliveryDay = "";
  String today = "";
  String time = "";

  List<String> deliveryHistory = [];

  @override
  void initState() {
    path = "successfulDeliveryImgs/${widget.orderID}";
    var t = DateTime.now();
    String tommorrow = "${t.day + 1}/${t.month}/${t.year}";
    setState(() {
      reDeliveryDay = tommorrow;
      time = "${t.day}/${t.month}: ";
      today = "${t.hour}:${t.minute}, ${t.day}/${t.month}/${t.year}";
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

  Future<void> takePhoto() async {
    var ip = ImagePicker();
    file = await ip.pickImage(source: ImageSource.camera);
    if (file != null) {
      setState(() {
        tookImg = true;
        hideDelayRequest = true;
      });
    }
  }

  void showDTPicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2024),
    ).then((dateTime) {
      if (dateTime != null) {
        setState(() {
          reDeliveryDay = DateFormat('dd/MM/yyyy').format(dateTime);
        });
      }
    });
  }

  Future<void> confirmSuccessfulDeliveryOrder(double total) async {
    if (tookImg) {
      onSaving();
      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.putFile(File(file!.path));
      String imgUrl = await ref.getDownloadURL();
      List changeStatusOrder = [widget.orderID];
      deliveryHistory.add("$timeĐã giao hàng");
      try {
        await FirebaseFirestore.instance
            .collection("Orders")
            .doc(widget.orderID)
            .update({
          "reDeliveryDay": "",
          "delayDeliveryReason": "",
          "suscessfullDeliveryImg": imgUrl,
          "suscessfullDeliveryDay": today,
          "status": "Đã giao hàng",
          "paymentStatus": "Đã thanh toán",
          "deliveryHistory": FieldValue.arrayUnion(deliveryHistory),
        });
        await FirebaseFirestore.instance
            .collection("Shippers")
            .doc(FirebaseAuth.instance.currentUser!.email)
            .update({
          "deliveringOrders": FieldValue.arrayRemove(changeStatusOrder),
          "successfulDeliveryOrders": FieldValue.arrayUnion(changeStatusOrder),
          "totalReceivedToday": HomePage.totalReceivedToday + total,
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

  Future<void> confirmDelay() async {
    if (responsibility) {
      onSaving();
      try {
        deliveryHistory.add("${time}Delay giao hàng vì $delayDeliveryReason");
        await FirebaseFirestore.instance
            .collection("Orders")
            .doc(widget.orderID)
            .update({
          "rePickupDay": reDeliveryDay,
          "delayPickupReason": delayDeliveryReason,
          "status": "Delay giao hàng",
          "deliveryHistory": FieldValue.arrayUnion(deliveryHistory),
        });
        List changeStatusOrder = [widget.orderID];
        await FirebaseFirestore.instance
            .collection("Shippers")
            .doc(FirebaseAuth.instance.currentUser!.email)
            .update({
          "redeliveryOrders": FieldValue.arrayUnion(changeStatusOrder),
          "deliveringOrders": FieldValue.arrayRemove(changeStatusOrder),
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
                                color: MColors.darkBlue,
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
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "THÔNG TIN THANH TOÁN",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: MColors.darkBlue,
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
                                      color: MColors.darkBlue.withOpacity(.3),
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
                                color: MColors.darkBlue,
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
                          SizedBox(
                            height: 40,
                            child: Divider(
                              color: MColors.darkBlue.withOpacity(.3),
                            ),
                          ),
                          SizedBox(
                            child: tookImg
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: Column(
                                      children: [
                                        const Row(
                                          children: [
                                            Text(
                                              "Ảnh lấy hàng",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: MColors.darkBlue,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Image.file(
                                          File(file!.path),
                                        ),
                                      ],
                                    ),
                                  )
                                : null,
                          ),
                          SizedBox(height: tookImg ? 15 : 0),
                          ElevatedButton(
                            onPressed: () async => tookImg
                                ? confirmSuccessfulDeliveryOrder(
                                    orderSnap.data!["total"])
                                : takePhoto(),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: MColors.background,
                              backgroundColor: Colors.teal,
                              minimumSize: const Size.fromHeight(55),
                            ),
                            child: Text(
                              !tookImg
                                  ? "Chụp ảnh giao hàng"
                                  : "Xác nhận giao hàng",
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            child: tookImg == false && !hideDelayRequest
                                ? Column(
                                    children: [
                                      const SizedBox(height: 15),
                                      const Row(
                                        children: [
                                          Text(
                                            "Lý do hoãn đơn:",
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 15),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            delayDeliveryReason =
                                                'Không liên lạc được với khách hàng';
                                            delayChoice = 1;
                                          });
                                        },
                                        child: dalayReason(
                                            'Không liên lạc được với khách hàng',
                                            1),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            delayDeliveryReason =
                                                'Khách hẹn ngày giao';
                                            delayChoice = 2;
                                          });
                                        },
                                        child: dalayReason(
                                            'Khách hẹn ngày giao', 2),
                                      ),
                                      const SizedBox(height: 10),
                                      mText("Ngày giao:", reDeliveryDay),
                                      const SizedBox(height: 15),
                                      SizedBox(
                                        child: delayChoice == 2
                                            ? ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.yellow[100],
                                                  foregroundColor: Colors.black,
                                                  minimumSize:
                                                      const Size.fromHeight(55),
                                                ),
                                                onPressed: () =>
                                                    showDTPicker(context),
                                                child: const Text(
                                                  "Chọn ngày giao",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(height: 15),
                                      CheckboxListTile(
                                        title: Text.rich(
                                          TextSpan(
                                            children: [
                                              const TextSpan(
                                                text:
                                                    'Tôi hoàn toàn chịu trách nhiệm về yêu cầu hoãn đơn hàng',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                              TextSpan(
                                                text: ' ${widget.orderID}',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  color: MColors.darkBlue,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        value: responsibility,
                                        activeColor: MColors.yelow,
                                        onChanged: (newValue) {
                                          setState(() {
                                            responsibility = !responsibility;
                                          });
                                        },
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                      ),
                                      const SizedBox(height: 15),
                                    ],
                                  )
                                : const SizedBox(),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              hideDelayRequest
                                  ? setState(() {
                                      hideDelayRequest = false;
                                    })
                                  : responsibility
                                      ? confirmDelay()
                                      : null;
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: MColors.yelow,
                              minimumSize: const Size.fromHeight(55),
                            ),
                            child: Text(
                              hideDelayRequest
                                  ? "Yêu cầu hoãn đơn"
                                  : "Hoãn đơn",
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
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

  Widget dalayReason(String content, int choiceIndex) {
    return ListTile(
      title: Text(
        content,
        style: const TextStyle(fontSize: 22),
      ),
      leading: Radio(
        value: choiceIndex,
        groupValue: delayChoice,
        activeColor: MColors.yelow,
        onChanged: (value) {
          setState(() {
            delayChoice = choiceIndex;
            delayDeliveryReason = content;
          });
        },
      ),
    );
  }
}
