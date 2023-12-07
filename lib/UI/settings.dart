import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gogoship/UI/login_screen.dart';
import 'package:gogoship/shared/mcolors.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final _formKey = GlobalKey<FormState>();

  var currentPW = TextEditingController();
  var confNewPW = TextEditingController();
  var newPW = TextEditingController();

  bool hideCPW = true;
  bool hideNPW = true;
  bool hideCNPW = true;

  bool hideChangePW = true;

  @override
  void dispose() {
    currentPW.dispose();
    newPW.dispose();
    confNewPW.dispose();
    super.dispose();
  }

  resetControllers() {
    setState(() {
      currentPW.text = "";
      newPW.text = "";
      confNewPW.text = "";
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

  Future<void> showAlertDialog(String content, String actionName) async {
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
              onPressed: () async => signOut(),
              style: ElevatedButton.styleFrom(
                backgroundColor: MColors.darkBlue,
                foregroundColor: MColors.white,
                minimumSize: const Size.fromHeight(50),
              ),
              child: Text(
                actionName,
                style: const TextStyle(
                  fontSize: 17,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> showCautionDialog(
      String content, String action1, bool hasAction2) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
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
                    "assets/icons/caution.png",
                    color: MColors.darkBlue,
                    height: 150,
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: MColors.darkBlue,
                      backgroundColor: MColors.white,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: Text(
                      action1,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: hasAction2 ? 10 : 0,
                ),
                hasAction2
                    ? Expanded(
                        child: ElevatedButton(
                          onPressed: () async => await signOut(),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: MColors.white,
                            backgroundColor: MColors.darkBlue,
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: const Text(
                            "Đồng ý",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ],
        );
      },
    );
  }

  var currentUser = FirebaseAuth.instance.currentUser;

  Future<void> changePassword(String email, String oldP, String newP) async {
    try {
      var cred = EmailAuthProvider.credential(email: email, password: oldP);
      await currentUser!.reauthenticateWithCredential(cred).then((value) {
        currentUser!.updatePassword(newP);
      }).then((value) async =>
          await showAlertDialog("Đổi mật khẩu thành công", "Đăng nhập lại"));
    } catch (e) {
      debugPrint(e.toString());
      if (e.toString().contains("INVALID_LOGIN_CREDENTIALS")) {
        await showCautionDialog(
            "Mật khẩu cũ không chính xác", "Thử lại", false);
      } else {
        await showCautionDialog("Có lỗi xảy ra", "Thử lại", false);
      }
    }
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
          backgroundColor: MColors.background,
          title: const Text("Cài đặt"),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          hideChangePW = !hideChangePW;
                          resetControllers();
                        }),
                        child: Container(
                          decoration: BoxDecoration(
                              color: MColors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 20),
                            child: Text(
                              "Đổi mật khẩu",
                              style: TextStyle(
                                  fontSize: 18, color: MColors.darkBlue),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: hideChangePW == true ? 0 : 10,
                ),
                hideChangePW == false ? changePW() : const SizedBox(),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async => await showCautionDialog(
                            "Bạn muốn đăng xuất?", "Hủy", true),
                        child: Container(
                          decoration: BoxDecoration(
                              color: MColors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 20),
                            child: Text(
                              "Đăng xuất",
                              style: TextStyle(
                                  fontSize: 18, color: MColors.darkBlue),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget changePW() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: MColors.darkBlue,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                obscureText: hideCPW,
                style: const TextStyle(fontSize: 18, color: MColors.darkBlue),
                controller: currentPW,
                maxLength: 16,
                decoration: InputDecoration(
                  hintText: "Mật khẩu cũ",
                  counterText: "",
                  hintStyle: const TextStyle(
                    fontSize: 17,
                    color: MColors.darkBlue,
                  ),
                  prefixIcon: const Icon(
                    Icons.password,
                    color: MColors.darkBlue,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        hideCPW = !hideCPW;
                      });
                    },
                    child: Icon(
                      hideCPW ? Icons.visibility : Icons.visibility_off,
                      color: MColors.lightBlue,
                    ),
                  ),
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: MColors.darkBlue, width: 1.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: MColors.background),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: MColors.error),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: MColors.error),
                  ),
                  filled: true,
                  fillColor: MColors.white,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Hãy nhập mật khẩu cũ";
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                style: const TextStyle(fontSize: 18, color: MColors.darkBlue),
                controller: newPW,
                obscureText: hideNPW,
                maxLength: 16,
                decoration: InputDecoration(
                  hintText: "Mật khẩu mới",
                  counterText: "",
                  hintStyle: const TextStyle(
                    fontSize: 17,
                    color: MColors.darkBlue,
                  ),
                  prefixIcon: const Icon(
                    Icons.password,
                    color: MColors.darkBlue,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        hideNPW = !hideNPW;
                      });
                    },
                    child: Icon(
                      hideNPW ? Icons.visibility : Icons.visibility_off,
                      color: MColors.lightBlue,
                    ),
                  ),
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: MColors.darkBlue, width: 1.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: MColors.background),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: MColors.error),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: MColors.error),
                  ),
                  filled: true,
                  fillColor: MColors.white,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Hãy nhập mật khẩu mới";
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                style: const TextStyle(fontSize: 18, color: MColors.darkBlue),
                controller: confNewPW,
                maxLength: 16,
                obscureText: hideCNPW,
                decoration: InputDecoration(
                  hintText: "Xác nhận mật khẩu",
                  counterText: "",
                  hintStyle: const TextStyle(
                    fontSize: 17,
                    color: MColors.darkBlue,
                  ),
                  prefixIcon: const Icon(
                    Icons.password,
                    color: MColors.darkBlue,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        hideCNPW = !hideCNPW;
                      });
                    },
                    child: Icon(
                      hideCNPW ? Icons.visibility : Icons.visibility_off,
                      color: MColors.lightBlue,
                    ),
                  ),
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: MColors.darkBlue, width: 1.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: MColors.background),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: MColors.error),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: MColors.error),
                  ),
                  filled: true,
                  fillColor: MColors.white,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Hãy nhập lại mật khẩu";
                  }
                  if (value != newPW.text) {
                    return "Mật khẩu không trùng khớp";
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await changePassword(currentUser!.email.toString(),
                        currentPW.text, newPW.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MColors.darkBlue,
                  foregroundColor: MColors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  "Đổi mật khẩu",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
