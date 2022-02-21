import 'package:flutter/material.dart';

class ItemNavigation extends StatelessWidget {
  const ItemNavigation({Key? key, required this.iconData, required this.title,this.callBack})
      : super(key: key);

  final IconData iconData;
  final String title;
  final Function? callBack;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          if(callBack != null){
            callBack!();
          }
        },
        child: Column(
          children: [
            Icon(iconData,color: Colors.black,),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(color: Colors.black),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
        ));
  }
}
