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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
                          .collection("Orders")
                          .doc(repickup[index])
                          .snapshots(),
                      builder: (context, orderSnap) {
                        if (orderSnap.hasData) {
                          return StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection("Suppliers")
                                .doc(orderSnap.data!["supplierID"])
                                .snapshots(),
                            builder: (context, supplierSnap) {
                              if (supplierSnap.hasData) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RePickupDetail(
                                            orderID: repickup[index],
                                            supplierID:
                                                supplierSnap.data!["id"],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
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
                                            mText("Mã đơn hàng:",
                                                "${orderSnap.data!["orderID"]}"),
                                            mText("Khách hàng:",
                                                "${supplierSnap.data!["brand"]}"),
                                            mText("Điện thoại:",
                                                "${supplierSnap.data!["phoneNumber"]}"),
                                            mText("Địa chỉ:",
                                                "${supplierSnap.data!["address"]}"),
                                            SizedBox(
                                              height: 20,
                                              child: Divider(
                                                color: MColors.darkBlue
                                                    .withOpacity(.2),
                                                thickness: 1,
                                              ),
                                            ),
                                            mText("Lý do:",
                                                "${orderSnap.data!["delayPickupReason"]}"),
                                            mText("Ngày hẹn:",
                                                "${orderSnap.data!["rePickupDay"]}"),
                                          ],
                                        ),
                                      ),
                                    ),
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
