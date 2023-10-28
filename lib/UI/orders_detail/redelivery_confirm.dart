import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gogoship/UI/homepage.dart';
import 'package:gogoship/shared/mcolors.dart';
import 'package:intl/intl.dart';

class RedeliveryConfirmScreen extends StatefulWidget {
  final String orderID;
  const RedeliveryConfirmScreen({super.key, required this.orderID});

  @override
  State<RedeliveryConfirmScreen> createState() =>
      _RedeliveryConfirmScreenState();
}

class _RedeliveryConfirmScreenState extends State<RedeliveryConfirmScreen> {
  String redeliveryDate = "";
  bool responsibility = false;
  int choice = 1;
  String reason = 'Không liên hệ được với khách';
  bool isLoading = true;

  @override
  void initState() {
    var t = DateTime.now();
    String tommorrow = "${t.day + 1}/${t.month}/${t.year}";
    setState(() {
      redeliveryDate = tommorrow;
    });
    super.initState();
  }

  void showDTPicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2024),
    ).then((dateTime) {
      if (dateTime != null) {
        setState(() {
          redeliveryDate = DateFormat('dd/MM/yyyy').format(dateTime);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hoãn đơn ${widget.orderID}"),
        backgroundColor: MColors.yelow,
      ),
      backgroundColor: MColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: MColors.yelow,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Text(
                          "Lý do hoãn đơn:",
                          style: TextStyle(
                              fontSize: 22,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          reason = 'Không liên hệ được với khách';
                          choice = 1;
                        });
                      },
                      child: dalayReason('Không liên hệ được với khách', 1),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          reason = 'Khách hẹn ngày giao';
                          choice = 2;
                        });
                      },
                      child: dalayReason('Khách hẹn ngày giao', 2),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: MColors.yelow,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Thời gian giao lại:",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      redeliveryDate,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              child: choice == 2
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MColors.yelow,
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(55),
                      ),
                      onPressed: () => showDTPicker(context),
                      child: const Text(
                        "Chọn ngày giao",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 15),
            CheckboxListTile(
              title: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text:
                          'Tôi hoàn toàn chịu trách nhiệm về yêu cầu hoãn đơn hàng',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    TextSpan(
                      text: ' ${widget.orderID}.',
                      style: const TextStyle(
                        fontSize: 20,
                        color: MColors.darkBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              value: responsibility,
              activeColor: MColors.yelow,
              onChanged: (newValue) {
                setState(() {
                  responsibility = !responsibility;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            )
          ],
        ),
      ),
      bottomNavigationBar: delayConfirmButton(),
    );
  }

  Widget dalayReason(String content, int choiceIndex) {
    return ListTile(
      title: Text(
        content,
        style: const TextStyle(fontSize: 22),
      ),
      leading: Radio(
        value: choiceIndex,
        groupValue: choice,
        activeColor: MColors.yelow,
        onChanged: (value) {
          setState(() {
            choice = choiceIndex;
            reason = content;
          });
        },
      ),
    );
  }

  Widget delayConfirmButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: ElevatedButton(
        onPressed: () async => confirmDelay(),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              responsibility ? MColors.yelow : Colors.grey.withOpacity(.2),
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(55),
        ),
        child: const Text(
          "Xác nhận",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Future<void> confirmDelay() async {
    if (responsibility) {
      onSaving();
      try {
        await FirebaseFirestore.instance
            .collection("Orders")
            .doc(widget.orderID)
            .update({
          "redeliveryDate": redeliveryDate,
          "delayReason": reason,
          "status": "Tạm hoãn",
        });
        setState(() {
          HomePage.deliveringOrders = [];
        });
        List changeStatusOrder = [widget.orderID];
        await FirebaseFirestore.instance
            .collection("Shippers")
            .doc(FirebaseAuth.instance.currentUser!.email)
            .update({
          "redeliveryOrders": FieldValue.arrayUnion(changeStatusOrder),
          "deliveringOrders": FieldValue.arrayRemove(changeStatusOrder),
        }).then((value) {
          setState(() {
            isLoading = false;
          });
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        });
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  Future<void> onSaving() async {
    if (isLoading) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: const SizedBox(
              height: 100,
              width: 100,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          );
        },
      );
    }
  }
}
