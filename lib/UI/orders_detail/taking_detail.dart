import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gogoship/UI/homepage.dart';
import 'package:gogoship/UI/orders_detail/mymapview.dart';
import 'package:gogoship/models/suppliers.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:gogoship/models/orders.dart';
import 'package:gogoship/shared/mcolors.dart';
import 'package:image_picker/image_picker.dart';

class TakingOrderDetailScreen extends StatefulWidget {
  final Orders order;
  final Suppliers suppliers;
  const TakingOrderDetailScreen(
      {super.key, required this.order, required this.suppliers});

  @override
  State<TakingOrderDetailScreen> createState() =>
      _TakingOrderDetailScreenState();
}

class _TakingOrderDetailScreenState extends State<TakingOrderDetailScreen> {
  XFile? file;
  String path = "";
  bool tookImg = false;
  bool isLoading = true;
  bool hideDelayRequest = true;

  int delayChoice = 1;
  String delayReason = 'NCC chưa có hàng';
  bool responsibility = false;
  String reTakingDay = "";

  @override
  void initState() {
    path = "getOrderConfirmImgs/${widget.order.iD}";
    var t = DateTime.now();
    String tommorrow = "${t.day + 1}/${t.month}/${t.year}";
    setState(() {
      reTakingDay = tommorrow;
    });
    super.initState();
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
          reTakingDay = DateFormat('dd/MM/yyyy').format(dateTime);
        });
      }
    });
  }

  makingPhoneCall(String phoneNumber) async {
    var url = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> confirmDelay() async {
    if (responsibility) {
      onSaving();
      try {
        await FirebaseFirestore.instance
            .collection("Orders")
            .doc(widget.order.iD)
            .update({
          "reTakingDay": reTakingDay,
          "delayReason": delayReason,
          "status": "Delay lấy hàng",
        });
        setState(() {
          HomePage.takingOrders = [];
        });
        List changeStatusOrder = [widget.order.iD];
        await FirebaseFirestore.instance
            .collection("Shippers")
            .doc(FirebaseAuth.instance.currentUser!.email)
            .update({
          "reTakingOrders": FieldValue.arrayUnion(changeStatusOrder),
          "takingOrders": FieldValue.arrayRemove(changeStatusOrder),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MColors.background,
      appBar: AppBar(
        title: const Text("Chi tiết đơn hàng"),
        backgroundColor: MColors.background,
      ),
      body: SingleChildScrollView(
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
                      mText("Trạng thái ĐH:", widget.order.status, bold: true),
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
                      mText("Cửa hàng:", widget.suppliers.brand, bold: true),
                      mText("Số ĐT:", widget.suppliers.phoneNumber),
                      mText("Địa chỉ:", widget.suppliers.address),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MyMapView(
                                      coordinates: LatLng(
                                        widget.suppliers.lat,
                                        widget.suppliers.long,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MColors.blue,
                                foregroundColor: MColors.background,
                                minimumSize: const Size.fromHeight(50),
                              ),
                              icon: const Icon(Icons.roundabout_left_rounded),
                              label: const Text(
                                "Đường đi",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 1,
                            child: ElevatedButton.icon(
                              onPressed: () async =>
                                  makingPhoneCall(widget.suppliers.phoneNumber),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: MColors.background,
                                minimumSize: const Size.fromHeight(50),
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
                        padding: const EdgeInsets.symmetric(horizontal: 5),
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
                onPressed: () async =>
                    tookImg ? confirmGetOrder() : takePhoto(),
                style: ElevatedButton.styleFrom(
                  foregroundColor: MColors.background,
                  backgroundColor: Colors.teal,
                  minimumSize: const Size.fromHeight(55),
                ),
                child: Text(
                  !tookImg ? "Chụp ảnh lấy hàng" : "Xác nhận lấy hàng",
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
                                delayReason = 'NCC chưa có hàng';
                                delayChoice = 1;
                              });
                            },
                            child: dalayReason('NCC chưa có hàng', 1),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                delayReason = 'NCC hẹn ngày lấy';
                                delayChoice = 2;
                              });
                            },
                            child: dalayReason('NCC hẹn ngày lấy', 2),
                          ),
                          const SizedBox(height: 10),
                          mText("Ngày lấy:", reTakingDay,
                              bold: true, fontSize: 24),
                          const SizedBox(height: 15),
                          SizedBox(
                            child: delayChoice == 2
                                ? ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.yellow[100],
                                      foregroundColor: Colors.black,
                                      minimumSize: const Size.fromHeight(55),
                                    ),
                                    onPressed: () => showDTPicker(context),
                                    child: const Text(
                                      "Chọn ngày lấy",
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
                                    text: ' ${widget.order.iD}',
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
                            controlAffinity: ListTileControlAffinity.leading,
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
                  hideDelayRequest ? "Yêu cầu hoãn đơn" : "Hoãn đơn",
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 15),
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

  Future<void> confirmGetOrder() async {
    if (tookImg) {
      onSaving();
      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.putFile(File(file!.path));
      String imgUrl = await ref.getDownloadURL();
      List changeStatusOrder = [widget.order.iD];
      var d = DateTime.now();
      String docID = "${d.year}_${d.month}_orders";
      try {
        await FirebaseFirestore.instance
            .collection("Orders")
            .doc(widget.order.iD)
            .update({
          "getOrderImg": imgUrl,
          "status": "Đã lấy hàng",
        });
        await FirebaseFirestore.instance
            .collection("Shippers")
            .doc(FirebaseAuth.instance.currentUser!.email)
            .collection("History")
            .doc(docID)
            .update({
          "allGotOrders": FieldValue.arrayUnion(changeStatusOrder),
        });
        setState(() {
          HomePage.takingOrders = [];
        });
        await FirebaseFirestore.instance
            .collection("Shippers")
            .doc(FirebaseAuth.instance.currentUser!.email)
            .update({
          "takingOrders": FieldValue.arrayRemove(changeStatusOrder),
          "importOrders": FieldValue.arrayUnion(changeStatusOrder),
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
            delayReason = content;
          });
        },
      ),
    );
  }
}
