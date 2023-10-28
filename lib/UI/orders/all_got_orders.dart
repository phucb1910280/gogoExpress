import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gogoship/shared/mcolors.dart';

class AllGotOrders extends StatefulWidget {
  const AllGotOrders({super.key});

  @override
  State<AllGotOrders> createState() => _AllGotOrdersState();
}

class _AllGotOrdersState extends State<AllGotOrders> {
  int allGotNumber = 0;
  List<String> allOrders = [];

  @override
  void initState() {
    getAllGotOrders();
    super.initState();
  }

  getAllGotOrders() async {
    var data = await FirebaseFirestore.instance
        .collection("Shippers")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection("History")
        .get();
    int got = 0;
    for (var i = 0; i < data.docs.length; i++) {
      // var tempGot = data.docs[i]["allGotOrders"];
      List<String> gotList = List.from(data.docs[i]["allGotOrders"]);
      // allOrders.addAll(iterable);
      for (var element in gotList) {
        allOrders.add(element);
      }
      got += gotList.length;
      // print(gotList);
    }
    setState(() {
      allGotNumber = got;
    });
    // print(allOrders);
    // print(allGotNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lấy hàng thành công"),
        backgroundColor: MColors.pink,
      ),
      backgroundColor: MColors.background,
      body: allOrders.isNotEmpty
          ? SizedBox(
              child: ListView.builder(
                itemCount: allGotNumber,
                itemBuilder: (context, index) {
                  if (allOrders.isNotEmpty) {
                    return customListTiles(allOrders[index]);
                  } else {
                    return const Text("Danh sách rỗng");
                  }
                },
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget customListTiles(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Container(
        decoration: const BoxDecoration(
          color: MColors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: const Icon(
              Icons.check,
              color: MColors.green,
              size: 25,
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                color: MColors.darkBlue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
