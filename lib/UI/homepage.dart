import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gogoship/UI/login_screen.dart';
import 'package:gogoship/shared/mcolors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> deliveringOrders = <String>[];
  List<String> delayedOrders = <String>[];
  List<String> cancelledOrders = <String>[];
  List<String> delivered = <String>[];

  @override
  void initState() {
    getOrderData();
    super.initState();
  }

  getOrderData() async {
    var delivering = await FirebaseFirestore.instance
        .collection("Shippers")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();
    setState(() {
      deliveringOrders = List.from(delivering["deliveringOrders"]);
      cancelledOrders = List.from(delivering["cancelledOrders"]);
      delayedOrders = List.from(delivering["delayedOrders"]);
      delivered = List.from(delivering["delivered"]);
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MColors.background,
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Shippers")
              .doc(FirebaseAuth.instance.currentUser!.email)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.0, 1],
                            colors: [
                              Color.fromARGB(255, 230, 230, 230),
                              Colors.white,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          leading: shipperAvt(snapshot.data["profileImg"]),
                          title: Text(
                            snapshot.data["fullName"],
                            style: const TextStyle(
                                fontSize: 20, color: MColors.darkBlue),
                          ),
                          subtitle: const Text(
                            "Xem chi tiết",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: MColors.darkBlue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        children: [
                          orderGridItems("Đã giao", delivered.length.toString(),
                              MColors.lightGreen, MColors.green, MColors.white),
                          const SizedBox(width: 10),
                          orderGridItems(
                              "Đang giao",
                              deliveringOrders.length.toString(),
                              MColors.lightBlue,
                              MColors.blue,
                              MColors.white),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          orderGridItems(
                              "Tạm hoãn",
                              delayedOrders.length.toString(),
                              MColors.yelow,
                              MColors.orange,
                              MColors.white),
                          const SizedBox(width: 10),
                          orderGridItems(
                              "Đã hủy",
                              cancelledOrders.length.toString(),
                              MColors.lightRed,
                              MColors.red,
                              MColors.white),
                        ],
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
      ),
    );
  }

  Widget orderGridItems(String title, String content, Color color1,
      Color color2, Color textColor) {
    return Expanded(
      flex: 1,
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 1],
            colors: [
              color1,
              color2,
            ],
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                content,
                style: TextStyle(
                    fontSize: 50,
                    color: textColor,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget shipperAvt(String imgUrl) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(imgUrl),
        ),
      ),
    );
  }
}
