import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:gogoship/UI/homepage.dart';
import 'package:gogoship/UI/map_view.dart';
import 'package:gogoship/shared/mcolors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class PickingDetail extends StatefulWidget {
  final String orderID;
  final String address;
  const PickingDetail(
      {super.key, required this.orderID, required this.address});

  @override
  State<PickingDetail> createState() => _PickingDetailState();
}

class _PickingDetailState extends State<PickingDetail> {
  XFile? file;
  String path = "";
  bool tookImg = false;
  bool isLoading = true;
  bool hideDelayRequest = true;

  int delayChoice = 1;
  String lyDoHenLay = 'Người gửi chưa có hàng';
  bool responsibility = false;
  String ngayHenLay = "";
  String time = "";

  List<String> logVanChuyen = [];
  List<Location> senderCoordinates = [];
  var latLong = const LatLng(0, 0);

  @override
  void initState() {
    getCoordinates();
    path = "anhLayHang/${widget.orderID}";
    var t = DateTime.now();
    String tommorrow = "${t.day + 1}/${t.month}/${t.year}";
    setState(() {
      ngayHenLay = tommorrow;
      time = "${t.day}/${t.month}:";
    });
    super.initState();
  }

  getCoordinates() async {
    senderCoordinates = await locationFromAddress(widget.address);
    setState(() {
      latLong =
          LatLng(senderCoordinates[0].latitude, senderCoordinates[0].longitude);
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
          ngayHenLay = DateFormat('dd/MM/yyyy').format(dateTime);
        });
      }
    });
  }

  Future<void> confirmPickup(double phiShip) async {
    if (tookImg) {
      onSaving();
      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.putFile(File(file!.path));
      String imgUrl = await ref.getDownloadURL();
      List changeStatusOrder = [widget.orderID];
      setState(() {
        logVanChuyen.add("$time Đã lấy hàng");
      });
      try {
        await FirebaseFirestore.instance
            .collection("DeliverOrders")
            .doc(widget.orderID)
            .update({
          "ngayHenLay": "",
          "lyDoHenLay": "",
          "anhLayHang": imgUrl,
          "trangThaiDonHang": "Đã lấy hàng",
          "logVanChuyen": FieldValue.arrayUnion(logVanChuyen),
        });
        await FirebaseFirestore.instance
            .collection("Shippers")
            .doc(FirebaseAuth.instance.currentUser!.email)
            .update({
          "takingOrders": FieldValue.arrayRemove(changeStatusOrder),
          "importOrders": FieldValue.arrayUnion(changeStatusOrder),
          "totalReceivedToday": HomePage.totalReceivedToday + phiShip,
        }).then((value) {
          setState(() {
            isLoading = false;
          });
          showAlertDialog("Lấy hàng thành công");
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
        setState(() {
          logVanChuyen.add("$time Delay lấy hàng vì $lyDoHenLay");
        });
        await FirebaseFirestore.instance
            .collection("DeliverOrders")
            .doc(widget.orderID)
            .update({
          "ngayHenLay": ngayHenLay,
          "lyDoHenLay": lyDoHenLay,
          "trangThaiDonHang": "Delay lấy hàng",
          "logVanChuyen": FieldValue.arrayUnion(logVanChuyen),
        });
        List changeStatusOrder = [widget.orderID];
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
          showAlertDialog("Delay thành công");
        });
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  Future<void> showAlertDialog(String content) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Image.asset(
                    "assets/icons/success.png",
                    height: 100,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Text(
                      content,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MColors.darkBlue,
                foregroundColor: MColors.white,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                "OK",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
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
              .collection("DeliverOrders")
              .doc(widget.orderID)
              .snapshots(),
          builder: (context, orderSnap) {
            if (orderSnap.hasData) {
              logVanChuyen = List.from(orderSnap.data!["logVanChuyen"]);
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            mText("Mã đơn:", orderSnap.data!["id"]),
                            mText("Ngày đặt:", orderSnap.data!["ngayTaoDon"]),
                            mText("Trạng thái:",
                                orderSnap.data!["trangThaiDonHang"]),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "THÔNG TIN NGƯỜI GỬI",
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
                            mText("Người gửi:", orderSnap.data!["nguoiGui"]),
                            mText(
                                "Điện thoại:", orderSnap.data!["sdtNguoiGui"]),
                            mText("Địa chỉ:", orderSnap.data!["dcNguoiGui"]),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: ElevatedButton.icon(
                                    onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => MyMapView(
                                                coordinates: latLong))),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: MColors.blue,
                                      foregroundColor: MColors.background,
                                      minimumSize: const Size.fromHeight(50),
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
                                    onPressed: () async => makingPhoneCall(
                                        orderSnap.data!["sdtNguoiGui"]),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
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
                      onPressed: () async {
                        if (orderSnap.data!["nguoiNhanTraShip"] == false) {
                          double t = orderSnap.data!["phiVanChuyen"];
                          tookImg ? confirmPickup(t) : takePhoto();
                        }
                        tookImg ? confirmPickup(0) : takePhoto();
                      },
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
                                      lyDoHenLay = 'Người gửi chưa có hàng';
                                      delayChoice = 1;
                                    });
                                  },
                                  child:
                                      dalayReason('Người gửi chưa có hàng', 1),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      lyDoHenLay = 'Người gửi hẹn ngày lấy';
                                      delayChoice = 2;
                                    });
                                  },
                                  child:
                                      dalayReason('Người gửi hẹn ngày lấy', 2),
                                ),
                                const SizedBox(height: 10),
                                mText("Ngày lấy", ngayHenLay),
                                const SizedBox(height: 15),
                                SizedBox(
                                  child: delayChoice == 2
                                      ? ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.yellow[100],
                                            foregroundColor: Colors.black,
                                            minimumSize:
                                                const Size.fromHeight(55),
                                          ),
                                          onPressed: () =>
                                              showDTPicker(context),
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
                      onPressed: () async {
                        hideDelayRequest
                            ? setState(() {
                                hideDelayRequest = false;
                              })
                            : responsibility
                                ? await confirmDelay()
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
                  ],
                ),
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
            lyDoHenLay = content;
          });
        },
      ),
    );
  }
}
