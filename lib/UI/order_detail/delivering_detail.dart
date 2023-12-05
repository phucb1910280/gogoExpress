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

class DeliveringDetail extends StatefulWidget {
  final String orderID;
  final String address;
  const DeliveringDetail(
      {super.key, required this.orderID, required this.address});

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
  String lyDoHenGiao = 'Người nhận hẹn ngày giao';
  bool responsibility = false;
  String ngayHenGiao = "";
  String today = "";
  String time = "";

  List<String> logVanChuyen = [];
  List<Location> receiverCoordinates = [];
  var latLong = const LatLng(0, 0);

  @override
  void initState() {
    getCoordinates();
    path = "anhGiaoHang/${widget.orderID}";
    var t = DateTime.now();
    String tommorrow = "${t.day + 1}/${t.month}/${t.year}";
    setState(() {
      ngayHenGiao = tommorrow;
      time = "${t.day}/${t.month}:";
      today = "${t.hour}:${t.minute}, ${t.day}/${t.month}/${t.year}";
    });
    super.initState();
  }

  getCoordinates() async {
    receiverCoordinates = await locationFromAddress(widget.address);
    setState(() {
      latLong = LatLng(
          receiverCoordinates[0].latitude, receiverCoordinates[0].longitude);
    });
  }

  Widget check(bool nguoiNhanTraShip) {
    return nguoiNhanTraShip == true
        ? const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "(Người nhận trả ship)",
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
            ],
          )
        : const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "(Người gửi trả ship)",
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
            ],
          );
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
          ngayHenGiao = DateFormat('dd/MM/yyyy').format(dateTime);
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
      logVanChuyen.add("$timeĐã giao hàng");
      try {
        await FirebaseFirestore.instance
            .collection("DeliverOrders")
            .doc(widget.orderID)
            .update({
          "ngayHenGiao": "",
          "lyDoHenGiao": "",
          "anhGiaoHang": imgUrl,
          "ngayGiaoHang": today,
          "trangThaiDonHang": "Đã giao hàng",
          "logVanChuyen": FieldValue.arrayUnion(logVanChuyen),
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
          showAlertDialog("Giao hàng thành công");
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
        logVanChuyen.add("$time Delay giao hàng vì $lyDoHenGiao");
        await FirebaseFirestore.instance
            .collection("DeliverOrders")
            .doc(widget.orderID)
            .update({
          "ngayHenGiao": ngayHenGiao,
          "lyDoHenGiao": lyDoHenGiao,
          "trangThaiDonHang": "Delay giao hàng",
          "logVanChuyen": FieldValue.arrayUnion(logVanChuyen),
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
          builder: (context, o) {
            if (o.hasData) {
              logVanChuyen = List.from(o.data!["logVanChuyen"]);
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
                            mText("Mã đơn:", o.data!["id"]),
                            mText("Ngày đặt:", o.data!["ngayTaoDon"]),
                            mText("Trạng thái:", o.data!["trangThaiDonHang"]),
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
                            mText(
                                "Giá trị hàng hóa:",
                                NumberFormat.simpleCurrency(
                                        locale: 'vi-VN', decimalDigits: 0)
                                    .format(o.data!["giaTriHangHoa"])),
                            mText(
                                "Phí vận chuyển:",
                                NumberFormat.simpleCurrency(
                                        locale: 'vi-VN', decimalDigits: 0)
                                    .format(o.data!["phiVanChuyen"])),
                            check(o.data!["nguoiNhanTraShip"]),
                            mText(
                                "Tiền CoD:",
                                NumberFormat.simpleCurrency(
                                        locale: 'vi-VN', decimalDigits: 0)
                                    .format(o.data!["tienThuHo"])),
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
                            mText("Người nhận:", o.data!["nguoiNhan"]),
                            mText("Điện thoại:", o.data!["sdtNguoiNhan"]),
                            mText("Địa chỉ:", o.data!["dcNguoiNhan"]),
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
                                        o.data!["sdtNguoiNhan"]),
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
                      onPressed: () async => tookImg
                          ? await confirmSuccessfulDeliveryOrder(
                              o.data!["tienThuHo"])
                          : await takePhoto(),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: MColors.background,
                        backgroundColor: Colors.teal,
                        minimumSize: const Size.fromHeight(55),
                      ),
                      child: Text(
                        !tookImg ? "Chụp ảnh giao hàng" : "Xác nhận giao hàng",
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
                                      lyDoHenGiao =
                                          'Không liên lạc được với khách hàng';
                                      delayChoice = 1;
                                    });
                                  },
                                  child: dalayReason(
                                      'Không liên lạc được với khách hàng', 1),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      lyDoHenGiao = 'Khách hẹn ngày giao';
                                      delayChoice = 2;
                                    });
                                  },
                                  child: dalayReason('Khách hẹn ngày giao', 2),
                                ),
                                const SizedBox(height: 10),
                                mText("Ngày giao:", ngayHenGiao),
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
                        hideDelayRequest ? "Yêu cầu hoãn đơn" : "Hoãn đơn",
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
            lyDoHenGiao = content;
          });
        },
      ),
    );
  }
}
