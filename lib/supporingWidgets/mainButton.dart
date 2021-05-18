import 'package:flutter/material.dart';
import 'package:my_chat_app/res/color.dart';

class MainButton extends StatelessWidget {
  final String title;
  final GestureTapCallback onTap;
  final bool loading;
  final Color color;
  final Color titleColor;
  final Color loadingColor;
  final double borderRadius;
  final double elevation;
  final double minWidth;
  final double height;
  final double fontSize;
  final Widget child;

  const MainButton({
    Key key,
    @required this.title,
    @required this.onTap,
    this.loading = false,
    this.color = secondaryColor,
    this.titleColor = primaryColor,
    this.loadingColor = Colors.white,
    this.borderRadius = 30,
    this.elevation,
    this.minWidth = double.infinity,
    this.height = 55,
    this.fontSize = 16,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onTap,
      color: color,
      elevation: elevation,
      height: height,
      minWidth: minWidth,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: loading
          ? Container(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
              ),
            )
          : child != null
              ? child
              : Text(
                  "$title",
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .9,
                    fontSize: fontSize,
                  ),
                ),
    );
  }
}
