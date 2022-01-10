import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  const InputField({
    Key? key,
    required this.controller,
    required this.hint,
    this.isObscure,
  }) : super(key: key);

  final TextEditingController controller;
  final String hint;
  final bool? isObscure;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: TextField(
          obscureText: isObscure == null ? false : true,
          inputFormatters: const [
            // FilteringTextInputFormatter(RegExp(r"^[a-zA-Z0-9ğüşöçİĞÜŞÖÇ]+$"),
            //     allow: true)
          ],
          controller: controller,
          cursorColor: Colors.white,
          decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.purple,
                ),
                borderRadius: BorderRadius.circular(40.0),
              )),
        ),
      ),
    );
  }
}
