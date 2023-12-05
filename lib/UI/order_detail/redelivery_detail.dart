import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gogoship/UI/homepage.dart';
import 'package:gogoship/shared/mcolors.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ReDeliveryDetail extends StatefulWidget {
  final String orderID;
  const ReDeliveryDetail({super.key, required this.orderID});

  @override
  State<ReDeliveryDetail> createState() => _ReDeliveryDetailState();
}

class _ReDeliveryDetailState extends State<ReDeliveryDetail> {
  bool isLoading = true;
  String time = "";
  String today = "";
  List<String> logVanChuyen = [];

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

  Future<void> confirmReDeliveryOrder() async {
    if (true) {
      onSaving();
      List changeStatusOrder = [widget.orderID];
      logVanChuyen.add("$time Đang giao hàng");
      try {
        await FirebaseFirestore.instance
            .collection("DeliverOrders")
            .doc(widget.orderID)
            .update({
          "ngayHenGiao": "",
          "lyDoHenGiao": "",
          "trangThaiDonHang": "Đang giao hàng",
          "logVanChuyen": FieldValue.arrayUnion(logVanChuyen),
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
                            mText("Mã đơn:", o.data!["id"]),
                            mText("Ngày đặt:", o.data!["ngayTaoDon"]),
                            mText("Trạng thái:", o.data!["trangThaiDonHang"]),
                            mText("Lý do:", "${o.data!["lyDoHenGiao"]}"),
                            mText(
                                "Ngày hẹn giao:", "${o.data!["ngayHenGiao"]}"),
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
                                "Tiền COD:",
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
                          color: MColors.yelow,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            mText("Khách hàng:", o.data!["nguoiNhan"]),
                            mText("Điện thoại:", o.data!["sdtNguoiNhan"]),
                            mText("Địa chỉ:", o.data!["dcNguoiNhan"]),
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
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () async => confirmReDeliveryOrder(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: MColors.white,
                        minimumSize: const Size.fromHeight(55),
                      ),
                      child: const Text(
                        "Sẵn sàng giao hàng",
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
