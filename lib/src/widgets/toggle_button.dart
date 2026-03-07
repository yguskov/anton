import 'package:flutter/material.dart';

class CustomToggleButton extends StatefulWidget {
  final String textOn;
  final String textOff;
  final IconData? iconOn;
  final IconData? iconOff;
  final Color? colorOn;
  final Color? colorOff;
  final Color? textColorOn;
  final Color? textColorOff;
  final double? width;
  final double? height;
  final Function(bool)? onToggle;

  const CustomToggleButton({
    Key? key,
    required this.textOn,
    required this.textOff,
    this.iconOn,
    this.iconOff,
    this.colorOn,
    this.colorOff,
    this.textColorOn,
    this.textColorOff,
    this.width,
    this.height,
    this.onToggle,
  }) : super(key: key);

  @override
  _CustomToggleButtonState createState() => _CustomToggleButtonState();
}

class _CustomToggleButtonState extends State<CustomToggleButton> {
  bool isPressed = false;

  void _handleTap() {
    setState(() {
      isPressed = !isPressed;
    });
    if (widget.onToggle != null) {
      widget.onToggle!(isPressed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        // width: widget.width ?? 180,
        height: widget.height ?? 60,
        decoration: BoxDecoration(
          color:
              isPressed ? (widget.colorOn ?? Colors.blue) : (widget.colorOff ?? Colors.grey[300]),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isPressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 10),
            if (isPressed && widget.iconOn != null) ...[
              Icon(widget.iconOn, size: 19, color: widget.textColorOn ?? Colors.white),
              SizedBox(width: 8),
            ],
            if (!isPressed && widget.iconOff != null) ...[
              Icon(widget.iconOff, size: 19, color: widget.textColorOff ?? Colors.black),
              SizedBox(width: 8),
            ],
            Text(
              isPressed ? widget.textOn : widget.textOff,
              style: TextStyle(
                color: isPressed
                    ? (widget.textColorOn ?? Colors.white)
                    : (widget.textColorOff ?? Colors.black),
                fontSize: 12,
                // fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
