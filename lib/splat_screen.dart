import 'package:flutter/material.dart';
import 'package:webview_play/webview_screen.dart';

class SplatScreen extends StatefulWidget {
  const SplatScreen({Key? key}) : super(key: key);

  @override
  _SplatScreenState createState() => _SplatScreenState();
}

class _SplatScreenState extends State<SplatScreen> {
  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(const Duration(milliseconds: 3000), () {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
            const WebviewScreen()), (route) => false);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child:  Center(child: Image.asset("assets/icons/ic_logo.png",width: 300,height: 200,)),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
    );
  }
}
