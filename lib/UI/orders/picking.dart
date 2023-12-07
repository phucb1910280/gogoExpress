import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gogoship/UI/order_detail/picking_detail.dart';
import 'package:gogoship/shared/mcolors.dart';
import 'package:intl/intl.dart';

class PickingOrders extends StatefulWidget {
  const PickingOrders({super.key});

  @override
  State<PickingOrders> createState() => _PickingOrdersState();
}

class _PickingOrdersState extends State<PickingOrders> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đơn đang lấy"),
        backgroundColor: MColors.lightPink,
      ),
      backgroundColor: MColors.background,
      body: SizedBox(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Shippers")
              .doc(FirebaseAuth.instance.currentUser!.email)
              .snapshots(),
          builder: (context, deliveringListSnap) {
            if (deliveringListSnap.hasData) {
              List<String> delivering =
                  List.from(deliveringListSnap.data!["takingOrders"]);
              return ListView.builder(
                shrinkWrap: true,
                itemCount: delivering.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: double.infinity,
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("DeliverOrders")
                          .doc(delivering[index])
                          .snapshots(),
                      builder: (context, orderSnap) {
                        if (orderSnap.hasData) {
                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => PickingDetail(
                                            orderID: orderSnap.data!["id"],
                                            address:
                                                orderSnap.data!["dcNguoiGui"],
                                          ))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${orderSnap.data!["ngayTaoDon"]}",
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.4),
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                      gradient: const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        stops: [0.0, 1],
                                        colors: [
                                          Colors.white,
                                          Color.fromARGB(255, 228, 228, 228),
                                        ],
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          mText("Mã đơn:",
                                              "${orderSnap.data!["id"]}"),
                                          // mText("Ngày tạo:",
                                          //     "${orderSnap.data!["ngayTaoDon"]}"),
                                          mText("Người gửi:",
                                              "${orderSnap.data!["nguoiGui"]}"),
                                          mText("Điện thoại:",
                                              "${orderSnap.data!["sdtNguoiGui"]}"),
                                          mText("Địa chỉ:",
                                              "${orderSnap.data!["dcNguoiGui"]}"),
                                          const SizedBox(
                                            height: 15,
                                            child: Divider(
                                              color: MColors.lightBlue2,
                                            ),
                                          ),
                                          orderSnap.data!["nguoiNhanTraShip"] ==
                                                  false
                                              ? mText("Thu người gửi:",
                                                  "${NumberFormat("###,###", "vi-VN").format(orderSnap.data!["phiVanChuyen"])}đ")
                                              : const SizedBox(),
                                          check(orderSnap
                                              .data!["nguoiNhanTraShip"]),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return const Text("");
                        }
                      },
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
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
