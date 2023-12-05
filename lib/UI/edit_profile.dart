import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gogoship/UI/homepage.dart';
import 'package:gogoship/shared/mcolors.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    var s = await FirebaseFirestore.instance
        .collection("Shippers")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();
    setState(() {
      name.text = s["fullName"];
      phone.text = s["phoneNumber"];
      secondAddress.text = s["secondAddress"];
    });
  }

  Future<void> updateData() async {
    try {
      await FirebaseFirestore.instance
          .collection("Shippers")
          .doc(FirebaseAuth.instance.currentUser!.email)
          .update({
        "fullName": name.text,
        "phoneNumber": phone.text,
        "secondAddress": secondAddress.text,
      }).then((value) => showAlertDialog("Cập nhật thành công"));
    } catch (e) {
      debugPrint(e.toString());
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

  final _formKey = GlobalKey<FormState>();

  var name = TextEditingController();
  var phone = TextEditingController();
  var secondAddress = TextEditingController();

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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: MColors.background,
        appBar: AppBar(
          title: const Text("Chỉnh sửa hồ sơ"),
          backgroundColor: MColors.background,
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Shippers")
              .doc(FirebaseAuth.instance.currentUser!.email)
              .snapshots(),
          builder: (context, s) {
            if (s.hasData) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      Center(
                        child: userAvt(s.data!["profileImg"]),
                      ),
                      const SizedBox(height: 30),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              style: const TextStyle(
                                  fontSize: 18, color: MColors.darkBlue),
                              controller: name,
                              maxLength: 100,
                              decoration: InputDecoration(
                                hintText: "Họ tên",
                                counterText: "",
                                hintStyle: const TextStyle(
                                  fontSize: 17,
                                  color: MColors.darkBlue,
                                ),
                                prefixIcon: const Icon(
                                  Icons.person,
                                  color: MColors.darkBlue,
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      name.text = "";
                                    });
                                  },
                                  child: const Icon(
                                    Icons.clear,
                                    color: MColors.lightBlue,
                                  ),
                                ),
                                border: InputBorder.none,
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: MColors.darkBlue),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: MColors.background),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide:
                                      const BorderSide(color: MColors.error),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide:
                                      const BorderSide(color: MColors.error),
                                ),
                                filled: true,
                                fillColor: MColors.white,
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Vui lòng nhập họ tên";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              style: const TextStyle(
                                  fontSize: 18, color: MColors.darkBlue),
                              controller: phone,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              decoration: InputDecoration(
                                hintText: "Số điện thoại",
                                counterText: "",
                                hintStyle: const TextStyle(
                                  fontSize: 17,
                                  color: MColors.darkBlue,
                                ),
                                prefixIcon: const Icon(
                                  Icons.phone,
                                  color: MColors.darkBlue,
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      phone.text = "";
                                    });
                                  },
                                  child: const Icon(
                                    Icons.clear,
                                    color: MColors.lightBlue,
                                  ),
                                ),
                                border: InputBorder.none,
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: MColors.darkBlue),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: MColors.background),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide:
                                      const BorderSide(color: MColors.error),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide:
                                      const BorderSide(color: MColors.error),
                                ),
                                filled: true,
                                fillColor: MColors.white,
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Vui lòng nhập số điện thoại";
                                }
                                if (!value.startsWith("0") ||
                                    value.length != 10) {
                                  return "Số điện thoại không hợp lệ";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              style: const TextStyle(
                                fontSize: 18,
                                color: MColors.darkBlue,
                              ),
                              controller: secondAddress,
                              keyboardType: TextInputType.text,
                              textAlignVertical: TextAlignVertical.bottom,
                              maxLength: 200,
                              maxLines: 2,
                              decoration: InputDecoration(
                                hintText: "Địa chỉ tạm trú",
                                counterText: "",
                                hintStyle: const TextStyle(
                                  fontSize: 17,
                                  color: MColors.darkBlue,
                                ),
                                prefixIcon: const Icon(
                                  Icons.map,
                                  color: MColors.darkBlue,
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      secondAddress.text = "";
                                    });
                                  },
                                  child: const Icon(
                                    Icons.clear,
                                    color: MColors.lightBlue,
                                  ),
                                ),
                                border: InputBorder.none,
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: MColors.darkBlue),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: MColors.background),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide:
                                      const BorderSide(color: MColors.error),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide:
                                      const BorderSide(color: MColors.error),
                                ),
                                filled: true,
                                fillColor: MColors.white,
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Vui lòng nhập địa chỉ";
                                }
                                return null;
                              },
                            ),
                          ],
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
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MColors.white,
                    foregroundColor: MColors.darkBlue,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text(
                    "Hủy",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await updateData();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MColors.darkBlue,
                    foregroundColor: MColors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text(
                    "Lưu",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
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
}
