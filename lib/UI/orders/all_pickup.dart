import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gogoship/shared/mcolors.dart';
import 'package:intl/intl.dart';

class AllPickUp extends StatefulWidget {
  const AllPickUp({super.key});

  @override
  State<AllPickUp> createState() => _AllPickUpState();
}

class _AllPickUpState extends State<AllPickUp> {
  List<dynamic> list = [];

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    var t = await FirebaseFirestore.instance
        .collection("Shippers")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();
    var s = List.from(t["importOrders"]);
    setState(() {
      list = s;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đơn hàng đã lấy"),
      ),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          return SizedBox(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("DeliverOrders")
                  .doc(list[index])
                  .snapshots(),
              builder: (context, o) {
                if (o.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(15.0),
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
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                mText("Mã đơn hàng:", "${o.data!["id"]}"),
                                mText("Người gửi:", "${o.data!["nguoiGui"]}"),
                                mText(
                                    "Điện thoại:", "${o.data!["sdtNguoiGui"]}"),
                                o.data!["nguoiNhanTraShip"] == false
                                    ? mText(
                                        "Đã thu:",
                                        NumberFormat.simpleCurrency(
                                                locale: 'vi-VN',
                                                decimalDigits: 0)
                                            .format(o.data!["phiVanChuyen"]))
                                    : const SizedBox(),
                              ],
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
          );
        },
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
