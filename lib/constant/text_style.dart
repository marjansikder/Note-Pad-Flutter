import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

String FONT_NAME = 'Hind Siliguri';
String FONT_NAME2 = 'arial';

TextStyle getTextStyle1(double sized, FontWeight? weight, Color? color) {
  return GoogleFonts.hindSiliguri(
    fontSize: sized,
    fontWeight: weight ?? FontWeight.normal,
    color: color ?? Colors.black,
  );
}

TextStyle getTextStyleBarlow(double sized, FontWeight? weight, Color? color) {
  return GoogleFonts.barlow(
    fontSize: sized,
    fontWeight: weight ?? FontWeight.normal,
    color: color ?? Colors.black,
  );
}

TextStyle getTextStyleNotoSans(double sized, FontWeight? weight, Color? color) {
  return GoogleFonts.firaSans(
    fontSize: sized,
    fontWeight: weight ?? FontWeight.normal,
    color: color ?? Colors.black,
  );
}

TextStyle getTextStyle2(double sized, FontWeight? weight, Color? color) {
  return GoogleFonts.notoSans(
    fontSize: sized,
    fontWeight: weight ?? FontWeight.normal,
    color: color ?? Colors.black,
  );
}

TextStyle getTextStyleTab(double sized, FontWeight? weight) {
  return GoogleFonts.notoSans(
    fontSize: sized,
    fontWeight: weight ?? FontWeight.normal,
  );
}

TextStyle getTextStyle(double sized, FontWeight? weight, Color? color) {
  return TextStyle(
      fontFamily: FONT_NAME,
      fontSize: sized,
      fontWeight: weight ?? FontWeight.normal,
      color: color ?? Colors.black,
      height: 1.5);
}

BoxDecoration getBoxDecorations(Color color, double radius) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
      bottomLeft: Radius.circular(radius),
      bottomRight: Radius.circular(radius),
    ),
  );
}

class Dimen {
  Dimen._();

  static const double dateTextSize = 24;
  static const double dayTextSize = 11;
  static const double monthTextSize = 11;
}
