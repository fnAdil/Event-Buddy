import 'package:flutter/material.dart';

class ProfileItem extends StatelessWidget {
  const ProfileItem({
    Key? key,
    required this.title,
    this.icon,
    required this.info,
  }) : super(key: key);
  final String info;

  final String title;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2.5),
      child: Container(
          decoration: (BoxDecoration(
              color: Colors.white,
              border: Border.all(width: 2, color: Colors.white),
              borderRadius: BorderRadius.circular(40),
              gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.purple,
                    Colors.blue,
                  ]))),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Row(
                    children: [
                      Text(
                        title + ": ",
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        info,
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 25),
                  child: Icon(icon),
                )
              ],
            ),
          )),
    );
  }
}
