import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gogoship/UI/order_detail/repickup_detail.dart';
import 'package:gogoship/shared/mcolors.dart';

class RePickupOrders extends StatefulWidget {
  const RePickupOrders({super.key});

  @override
  State<RePickupOrders> createState() => _RePickupOrdersState();
}

class _RePickupOrdersState extends State<RePickupOrders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đơn delay lấy hàng"),
        backgroundColor: MColors.lightOrange,
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
              List<String> repickup =
                  List.from(deliveringListSnap.data!["reTakingOrders"]);
              return ListView.builder(
                shrinkWrap: true,
                itemCount: repickup.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: double.infinity,
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("DeliverOrders")
                          .doc(repickup[index])
                          .snapshots(),
                      builder: (context, o) {
                        if (o.hasData) {
                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => RePickupDetail(
                                          orderID: o.data!["id"]))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${o.data!["ngayTaoDon"]}",
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
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          mText("Mã đơn:", "${o.data!["id"]}"),
                                          mText("Người gửi:",
                                              "${o.data!["nguoiGui"]}"),
                                          mText("Điện thoại:",
                                              "${o.data!["sdtNguoiGui"]}"),
                                          mText("Địa chỉ:",
                                              "${o.data!["dcNguoiGui"]}"),
                                          SizedBox(
                                            height: 20,
                                            child: Divider(
                                              color: MColors.darkBlue
                                                  .withOpacity(.2),
                                              thickness: 1,
                                            ),
                                          ),
                                          mText("Lý do:",
                                              "${o.data!["lyDoHenLay"]}"),
                                          mText("Ngày hẹn:",
                                              "${o.data!["ngayHenLay"]}"),
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
