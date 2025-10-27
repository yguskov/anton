import 'package:flutter/material.dart';

class TextBar extends StatelessWidget {
  final String label;

  TextBar(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      decoration: BoxDecoration(
        color: Color.fromRGBO(37, 46, 63, 1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(3),
          topRight: Radius.circular(3),
          bottomLeft: Radius.circular(1),
          bottomRight: Radius.circular(1),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          // fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );
  }
}
