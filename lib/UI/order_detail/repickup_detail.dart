import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gogoship/UI/homepage.dart';
import 'package:gogoship/shared/mcolors.dart';
import 'package:url_launcher/url_launcher.dart';

class RePickupDetail extends StatefulWidget {
  final String orderID;
  const RePickupDetail({super.key, required this.orderID});

  @override
  State<RePickupDetail> createState() => _RePickupDetailState();
}

class _RePickupDetailState extends State<RePickupDetail> {
  bool isLoading = true;
  String time = "";
  String today = "";
  List<String> logVanChuyen = [];
  List<String> logVanChuyenReversed = [];

  @override
  void initState() {
    var t = DateTime.now();
    setState(() {
      today = "${t.day}/${t.month}/${t.year}";
      time = "${t.day}/${t.month}:";
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

  Future<void> confirmRePickupOrder() async {
    if (true) {
      onSaving();
      try {
        List changeStatusOrder = [widget.orderID];
        setState(() {
          logVanChuyen.add("$time Đang lấy hàng");
        });

        await FirebaseFirestore.instance
            .collection("DeliverOrders")
            .doc(widget.orderID)
            .update({
          "ngayHenLay": "",
          "lyDoHenLay": "",
          "trangThaiDonHang": "Đang lấy hàng",
          "logVanChuyen": FieldValue.arrayUnion(logVanChuyen),
        });
        await FirebaseFirestore.instance
            .collection("Shippers")
            .doc(FirebaseAuth.instance.currentUser!.email)
            .update({
          "reTakingOrders": FieldValue.arrayRemove(changeStatusOrder),
          "takingOrders": FieldValue.arrayUnion(changeStatusOrder),
        }).then((value) {
          setState(() {
            isLoading = false;
          });
          showAlertDialog("Xác nhận thành công");
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
              logVanChuyenReversed = logVanChuyen.reversed.toList();
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            mText("Mã đơn:", o.data!["id"]),
                            mText("Ngày đặt:", o.data!["ngayTaoDon"]),
                            mText("Trạng thái:", o.data!["trangThaiDonHang"]),
                            mText("Lý do:", "${o.data!["lyDoHenLay"]}"),
                            mText("Ngày hẹn lấy:", "${o.data!["ngayHenLay"]}"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
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
                          color: MColors.yelow,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            mText("Người gửi:", o.data!["nguoiGui"]),
                            mText("Điện thoại:", o.data!["sdtNguoiGui"]),
                            mText("Địa chỉ:", o.data!["dcNguoiGui"]),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: ElevatedButton.icon(
                                    onPressed: () {},
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
                                    onPressed: () async =>
                                        makingPhoneCall(o.data!["sdtNguoiGui"]),
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
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "LỊCH SỬ VẬN CHUYỂN",
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
                        child: SizedBox(
                          height: 150,
                          child: ListView.builder(
                            itemCount: logVanChuyen.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.circle,
                                      size: 10,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Flexible(
                                      child: Text(
                                        logVanChuyenReversed[index],
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async => await confirmRePickupOrder(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MColors.yelow,
                        foregroundColor: MColors.black,
                        minimumSize: const Size.fromHeight(55),
                      ),
                      child: const Text(
                        "Sẵn sàng lấy hàng",
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
