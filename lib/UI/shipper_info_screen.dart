import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gogoship/UI/edit_profile.dart';
import 'package:gogoship/UI/settings.dart';
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
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Center(
                      child: userAvt(snapshot.data["profileImg"]),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      decoration: BoxDecoration(
                        color: MColors.lightBlue.withOpacity(.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Column(
                          children: [
                            mText("Họ tên:", snapshot.data["fullName"]),
                            mText("Ngày sinh:", snapshot.data["dayOfBirth"]),
                            mText("Giới tính:", snapshot.data["gender"]),
                            mText("CCCD:", snapshot.data["cccd"]),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        color: MColors.lightBlue.withOpacity(.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Column(
                          children: [
                            mText(
                                "Số điện thoại:", snapshot.data["phoneNumber"]),
                            mText("Email:", snapshot.data["email"]),
                            mText(
                                "Đ/c tạm trú:", snapshot.data["secondAddress"]),
                            mText("Đ/c thường trú:",
                                snapshot.data["mainAddress"]),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        color: MColors.lightBlue.withOpacity(.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Column(
                          children: [
                            // mText("Bưu cục:", snapshot.data["postOffice"]),
                            mText("Ngày tham gia:", snapshot.data["joinDay"]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                child: IconButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const EditProfile())),
                  style: IconButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: MColors.lightBlue),
                  icon: const Icon(Icons.edit),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: SizedBox(
                child: IconButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SettingScreen())),
                  style: IconButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: MColors.lightBlue),
                  icon: const Icon(Icons.settings),
                ),
              ),
            ),
          ],
        ),
      ),
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
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
        ),
      ],
    );
  }
}
