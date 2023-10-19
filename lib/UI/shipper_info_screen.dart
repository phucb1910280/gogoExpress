import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gogoship/shared/mcolors.dart';

class ShipperInfoScreen extends StatefulWidget {
  const ShipperInfoScreen({super.key});

  @override
  State<ShipperInfoScreen> createState() => _ShipperInfoScreenState();
}

class _ShipperInfoScreenState extends State<ShipperInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MColors.background,
      appBar: AppBar(
        title: const Text("Thông tin của tôi"),
        backgroundColor: MColors.background,
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Shippers")
              .doc(FirebaseAuth.instance.currentUser!.email)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Center(
                        child: userAvt(snapshot.data["profileImg"]),
                      ),
                      const SizedBox(height: 30),
                      mText("Họ tên:", snapshot.data["fullName"]),
                      mText("Giới tính:", snapshot.data["gender"]),
                      mText("CCCD:", snapshot.data["cccd"]),
                      mText("Số điện thoại:", snapshot.data["phoneNumber"]),
                      mText("Email:", snapshot.data["email"]),
                      mText("Đ/c tạm trú:", snapshot.data["secondAddress"]),
                      mText("Đ/c thường trú:", snapshot.data["mainAddress"]),
                      mText("Bưu cục:", snapshot.data["postOffice"]),
                    ],
                  ),
                ),
              );
            } else {
              return const CircularProgressIndicator();
            }
          }),
    );
  }

  Widget userAvt(String imgUrl) {
    return Container(
      height: 200,
      width: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(imgUrl),
        ),
      ),
    );
  }

  Widget mText(String title, String content) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 20),
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
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }
}
