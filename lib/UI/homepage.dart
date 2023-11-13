import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:gogoship/UI/orders/delivering.dart';
import 'package:gogoship/UI/orders/picking.dart';
import 'package:gogoship/UI/orders/redelivery.dart';
import 'package:gogoship/UI/orders/repickup.dart';
import 'package:gogoship/UI/shipper_info_screen.dart';
import 'package:gogoship/shared/mcolors.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class HomePage extends StatefulWidget {
  static var myLocation = const LatLng(0, 0);
  static double totalReceivedToday = 0;
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> deliveringOrders = <String>[];

  String today = "";
  int allGotLength = 0;
  int allDeliveredLength = 0;
  double total = 0;

  @override
  void initState() {
    refresh();
    super.initState();
  }

  void refresh() async {
    setState(() {
      today = "";
    });
    await checkPermission();
    await getCurrentPosition();
    var day = DateTime.now();
    setState(() {
      today = "${day.day}-${day.month}-${day.year}";
    });
    await getTodayOrderData();
  }

  checkPermission() async {
    final location = Location();
    final hasPermissions = await location.hasPermission();
    if (hasPermissions != PermissionStatus.granted) {
      await location.requestPermission().then((value) => getCurrentPosition());
    }
  }

  getCurrentPosition() async {
    geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high);
    HomePage.myLocation = LatLng(position.latitude, position.longitude);
  }

  getTodayOrderData() async {
    var todayData = await FirebaseFirestore.instance
        .collection("Shippers")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();
    HomePage.totalReceivedToday =
        double.parse(todayData["totalReceivedToday"].toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("Shippers")
                        .doc(FirebaseAuth.instance.currentUser!.email)
                        .snapshots(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return GestureDetector(
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
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Hôm nay, $today",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: MColors.darkBlue,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: MColors.darkBlue,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(13),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Text(
                              "Số tiền đã thu trong ngày:",
                              style: TextStyle(
                                fontSize: 20,
                                color: MColors.darkBlue,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              NumberFormat.simpleCurrency(
                                      locale: 'vi-VN', decimalDigits: 0)
                                  .format(HomePage.totalReceivedToday),
                              style: const TextStyle(
                                fontSize: 25,
                                color: MColors.darkBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.payments_rounded,
                                color: MColors.darkBlue,
                                size: 35,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection("Shippers")
                                .doc(FirebaseAuth.instance.currentUser!.email)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                List<String> delivering = List.from(
                                    snapshot.data!["deliveringOrders"]);
                                return orderGridItems(
                                  "Đang\ngiao hàng",
                                  delivering.length.toString(),
                                  MColors.pink,
                                  MColors.darkBlue3,
                                  const DeliveringOrders(),
                                );
                              } else {
                                return const Text("Error");
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection("Shippers")
                                .doc(FirebaseAuth.instance.currentUser!.email)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                List<String> delivering =
                                    List.from(snapshot.data!["takingOrders"]);
                                return orderGridItems(
                                  "Đang\nlấy hàng",
                                  delivering.length.toString(),
                                  MColors.lightPink,
                                  MColors.darkBlue2,
                                  const PickingOrders(),
                                );
                              } else {
                                return const Text("Error");
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection("Shippers")
                                .doc(FirebaseAuth.instance.currentUser!.email)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                List<String> delivering = List.from(
                                    snapshot.data!["redeliveryOrders"]);
                                return orderGridItems(
                                  "Delay\ngiao hàng",
                                  delivering.length.toString(),
                                  MColors.yelow,
                                  MColors.orange,
                                  const ReDeliveryOrders(),
                                );
                              } else {
                                return const Text("Error");
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection("Shippers")
                                .doc(FirebaseAuth.instance.currentUser!.email)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                List<String> delivering =
                                    List.from(snapshot.data!["reTakingOrders"]);
                                return orderGridItems(
                                  "Delay\nlấy hàng",
                                  delivering.length.toString(),
                                  MColors.lightOrange,
                                  MColors.lightRed,
                                  const RePickupOrders(),
                                );
                              } else {
                                return const Text("Error");
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection("Shippers")
                                .doc(FirebaseAuth.instance.currentUser!.email)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                List<String> delivering = List.from(
                                    snapshot.data!["successfulDeliveryOrders"]);
                                return orderGridItems(
                                  "Đã\ngiao hàng",
                                  delivering.length.toString(),
                                  MColors.lightGreen,
                                  MColors.green,
                                  const DeliveringOrders(),
                                );
                              } else {
                                return const Text("Error");
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection("Shippers")
                                .doc(FirebaseAuth.instance.currentUser!.email)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                List<String> delivering =
                                    List.from(snapshot.data!["importOrders"]);
                                return orderGridItems(
                                  "Đã\nlấy hàng",
                                  delivering.length.toString(),
                                  MColors.pink,
                                  MColors.darkPink,
                                  const DeliveringOrders(),
                                );
                              } else {
                                return const Text("Error");
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => refresh(),
        child: const Icon(
          Icons.refresh,
          color: MColors.darkBlue,
        ),
      ),
    );
  }

  Widget orderGridItems(
      String title, String content, Color color1, Color color2, Widget widget) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => widget));
      },
      child: Container(
        height: 190,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  color: MColors.white,
                ),
              ),
            ),
            Text(
              content,
              style: const TextStyle(
                  fontSize: 50,
                  color: MColors.white,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 1),
            const SizedBox(height: 1),
          ],
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
