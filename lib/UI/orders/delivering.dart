import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gogoship/UI/order_detail/delivering_detail.dart';
import 'package:gogoship/shared/mcolors.dart';
import 'package:intl/intl.dart';

class DeliveringOrders extends StatefulWidget {
  const DeliveringOrders({super.key});

  @override
  State<DeliveringOrders> createState() => _DeliveringOrdersState();
}

class _DeliveringOrdersState extends State<DeliveringOrders> {
  Widget check(bool nguoiNhanTraShip) {
    return nguoiNhanTraShip == true
        ? const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "(Người nhận trả ship)",
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
            ],
          )
        : const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "(Người gửi trả ship)",
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đơn đang giao"),
        backgroundColor: MColors.lightBlue,
      ),
      backgroundColor: MColors.background,
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Shippers")
              .doc(FirebaseAuth.instance.currentUser!.email)
              .snapshots(),
          builder: (context, deliveringListSnap) {
            if (deliveringListSnap.hasData) {
              List<String> delivering =
                  List.from(deliveringListSnap.data!["deliveringOrders"]);
              return ListView.builder(
                shrinkWrap: true,
                itemCount: delivering.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: double.infinity,
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("DeliverOrders")
                          .doc(delivering[index])
                          .snapshots(),
                      builder: (context, o) {
                        if (o.hasData) {
                          return GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => DeliveringDetail(
                                          orderID: o.data!["id"],
                                          address: o.data!["dcNguoiNhan"],
                                        ))),
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
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        mText(
                                            "Mã đơn hàng:", "${o.data!["id"]}"),
                                        // mText("Ngày tạo:",
                                        //     "${o.data!["ngayTaoDon"]}"),
                                        mText("Người nhận:",
                                            "${o.data!["nguoiNhan"]}"),
                                        mText("Điện thoại:",
                                            "${o.data!["sdtNguoiNhan"]}"),
                                        mText("Địa chỉ:",
                                            "${o.data!["dcNguoiNhan"]}"),
                                        const SizedBox(
                                          height: 15,
                                          child: Divider(
                                            color: MColors.lightBlue2,
                                          ),
                                        ),
                                        mText("Giá trị hàng hóa:",
                                            "${NumberFormat("###,###", "vi-VN").format(o.data!["giaTriHangHoa"])}đ"),
                                        mText("Phí vận chuyển:",
                                            "${NumberFormat("###,###", "vi-VN").format(o.data!["phiVanChuyen"])}đ"),
                                        check(o.data!["nguoiNhanTraShip"]),
                                        mText("Tiền CoD:",
                                            "${NumberFormat("###,###", "vi-VN").format(o.data!["tienThuHo"])}đ"),
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
