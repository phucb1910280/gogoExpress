import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gogoship/UI/orders/cancelled.dart';
import 'package:gogoship/UI/orders/delayed.dart';
import 'package:gogoship/UI/orders/delivered.dart';
import 'package:gogoship/UI/orders/delivering.dart';
import 'package:gogoship/UI/shipper_info_screen.dart';
import 'package:gogoship/shared/mcolors.dart';

class HomePage extends StatefulWidget {
  static List<String> deliveringOrders = <String>[];
  static List<String> delayedOrders = <String>[];
  static List<String> cancelledOrders = <String>[];
  static List<String> delivered = <String>[];
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String today = "";

  @override
  void initState() {
    var day = DateTime.now();
    setState(() {
      today = "${day.day}-${day.month}-${day.year}";
    });
    getOrderData();
    super.initState();
  }

  getOrderData() async {
    var delivering = await FirebaseFirestore.instance
        .collection("Shippers")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();
    setState(() {
      HomePage.deliveringOrders = List.from(delivering["deliveringOrders"]);
      HomePage.cancelledOrders = List.from(delivering["cancelledOrders"]);
      HomePage.delayedOrders = List.from(delivering["delayedOrders"]);
      HomePage.delivered = List.from(delivering["delivered"]);
    });
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
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ShipperInfoScreen(),
                          ),
                        ),
                        child: Container(
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 3,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListTile(
                            isThreeLine: true,
                            leading: shipperAvt(snapshot.data["profileImg"]),
                            title: Text(
                              snapshot.data["fullName"],
                              style: const TextStyle(
                                  fontSize: 25, color: MColors.darkBlue),
                            ),
                            subtitle: const Text(
                              "Xem chi tiết",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 15,
                                color: MColors.darkBlue,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Text(
                            "Hôm nay, $today",
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: MColors.darkBlue),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          orderGridItems(
                            "Đã giao",
                            HomePage.delivered.length.toString(),
                            MColors.lightGreen,
                            MColors.green,
                            MColors.white,
                            const DeliveredScreen(),
                          ),
                          const SizedBox(width: 15),
                          orderGridItems(
                            "Đang giao",
                            HomePage.deliveringOrders.length.toString(),
                            MColors.lightBlue,
                            MColors.blue,
                            MColors.white,
                            const DeliveringScreen(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          orderGridItems(
                            "Tạm hoãn",
                            HomePage.delayedOrders.length.toString(),
                            MColors.yelow,
                            MColors.orange,
                            MColors.white,
                            const DelayedScreen(),
                          ),
                          const SizedBox(width: 15),
                          orderGridItems(
                            "Đã hủy",
                            HomePage.cancelledOrders.length.toString(),
                            MColors.lightRed,
                            MColors.red,
                            MColors.white,
                            const CancelledScreen(),
                          ),
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
      Color color2, Color textColor, Widget widget) {
    return Expanded(
      flex: 1,
      child: GestureDetector(
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (content) => widget)),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 3),
              ),
            ],
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    color: textColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  content,
                  style: TextStyle(
                      fontSize: 50,
                      color: textColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 40,
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
