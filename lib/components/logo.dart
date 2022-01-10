import 'package:flutter/cupertino.dart';

class Logo extends StatelessWidget {
  const Logo({
    Key? key,
    required this.flex,
  }) : super(key: key);
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
        child: const Image(
          image: AssetImage("assets/images/b.png"),
        ),
      ),
    );
  }
}
