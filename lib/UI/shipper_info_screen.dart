import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gogoship/UI/login_screen.dart';
import 'package:gogoship/shared/mcolors.dart';

class ShipperInfoScreen extends StatefulWidget {
  const ShipperInfoScreen({super.key});

  @override
  State<ShipperInfoScreen> createState() => _ShipperInfoScreenState();
}

class _ShipperInfoScreenState extends State<ShipperInfoScreen> {
  signOut() async {
    await FirebaseAuth.instance.signOut();
    if (FirebaseAuth.instance.currentUser == null) {
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false,
        );
      }
    }
  }

  //shipperProfileImages
  UploadTask? uploadTask;
  PlatformFile? pickedFile;
  String filePath = "";

  Future updateProfileImg() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) {
      return;
    }
    setState(() {
      pickedFile = result.files.first;
      filePath = pickedFile!.path.toString();
    });
    final path =
        "shipperProfileImages/${FirebaseAuth.instance.currentUser!.email}";
    final file = File(pickedFile!.path!);
    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(file);
    final snapshot = await uploadTask!.whenComplete(() => null);
    var userAvtStr = await snapshot.ref.getDownloadURL();
    await FirebaseFirestore.instance
        .collection("Shippers")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .update(
      {
        "profileImg": userAvtStr,
      },
    );
  }

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
                    mText("Họ tên:", snapshot.data["fullName"]),
                    mText("Ngày sinh:", snapshot.data["dayOfBirth"]),
                    mText("Giới tính:", snapshot.data["gender"]),
                    mText("CCCD:", snapshot.data["cccd"]),
                    mText("Số điện thoại:", snapshot.data["phoneNumber"]),
                    mText("Email:", snapshot.data["email"]),
                    mText("Đ/c tạm trú:", snapshot.data["secondAddress"]),
                    mText("Đ/c thường trú:", snapshot.data["mainAddress"]),
                    mText("Bưu cục:", snapshot.data["postOffice"]),
                    mText("Ngày tham gia:", snapshot.data["joinDay"]),
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
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: MColors.white,
            backgroundColor: MColors.darkBlue,
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: signOut,
          child: const Text(
            "Đăng xuất",
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }

  Widget userAvt(String imgUrl) {
    return Stack(
      children: [
        Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(imgUrl),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: updateProfileImg,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  color: MColors.lightBlue.withOpacity(.5)),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.edit),
              ),
            ),
          ),
        ),
      ],
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
