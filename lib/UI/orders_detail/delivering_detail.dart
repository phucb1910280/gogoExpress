import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gogoship/UI/orders/delivering.dart';
import 'package:gogoship/UI/homepage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:gogoship/models/customers.dart';
import 'package:gogoship/models/orders.dart';
import 'package:gogoship/shared/mcolors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class DeliveringDetailScreen extends StatefulWidget {
  final Orders order;
  final Customers customer;
  const DeliveringDetailScreen(
      {super.key, required this.order, required this.customer});

  @override
  State<DeliveringDetailScreen> createState() => _DeliveringDetailScreenState();
}

class _DeliveringDetailScreenState extends State<DeliveringDetailScreen> {
  double s = 0;
  double t = 0;
  XFile? file;
  String path = "";
  bool takeImg = false;
  bool isLoading = true;

  @override
  void initState() {
    s = double.parse(widget.order.transportFee);
    t = double.parse(widget.order.totalAmount);
    path = "deliveredConfirmImg/${widget.order.iD}";
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
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                      mText("Người nhận:", widget.customer.fullName,
                          bold: true),
                      mText("Số ĐT:", widget.customer.phoneNumber),
                      mText("Địa chỉ:", widget.customer.address),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MColors.darkBlue,
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
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MColors.darkBlue,
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
                NumberFormat.simpleCurrency(locale: 'vi-VN', decimalDigits: 0)
                    .format(double.parse(widget.order.totalAmount)),
                fontSize: 25,
              ),
              mText(
                "Phí vận chuyển:",
                NumberFormat.simpleCurrency(locale: 'vi-VN', decimalDigits: 0)
                    .format(double.parse(widget.order.transportFee)),
                fontSize: 25,
              ),
              mText(
                "Tổng cộng:",
                NumberFormat.simpleCurrency(locale: 'vi-VN', decimalDigits: 0)
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
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async =>
                    takeImg ? confirmDelivered() : takePhoto(),
                style: ElevatedButton.styleFrom(
                  foregroundColor: MColors.background,
                  backgroundColor: MColors.darkBlue,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text(
                  !takeImg ? "Chụp ảnh giao hàng" : "Xác nhận đã giao",
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(
                child: takeImg
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 5),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Text(
                                  "Ảnh giao hàng",
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
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  foregroundColor: MColors.darkBlue,
                  backgroundColor: MColors.background,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  "Yêu cầu hoãn đơn",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  foregroundColor: MColors.darkBlue,
                  backgroundColor: MColors.background,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  "Yêu cầu hủy đơn",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
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
              fontSize: 19,
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
        takeImg = true;
      });
    }
  }

  Future<void> confirmDelivered() async {
    if (takeImg) {
      onSaving();
      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.putFile(File(file!.path));
      String imgUrl = await ref.getDownloadURL();
      try {
        await FirebaseFirestore.instance
            .collection("Orders")
            .doc(widget.order.iD)
            .update({
          "deliveredImg": imgUrl,
          "status": "Đã giao hàng",
          "paymentStatus": "Đã thanh toán",
        });
        HomePage.deliveringOrders.removeWhere(
          (element) => element == widget.order.iD,
        );
        HomePage.delivered.add(widget.order.iD);
        DeliveringScreen.customersDetail.removeWhere(
          (element) => element.id == widget.customer.id,
        );
        DeliveringScreen.deliveringOrdersDetail.removeWhere(
          (element) => element.iD == widget.order.iD,
        );
        List removeItem = [widget.order.iD];
        await FirebaseFirestore.instance
            .collection("Shippers")
            .doc(FirebaseAuth.instance.currentUser!.email)
            .update({
          "delivered": FieldValue.arrayUnion(HomePage.delivered),
          "deliveringOrders": FieldValue.arrayRemove(removeItem),
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
}
