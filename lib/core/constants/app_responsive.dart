import 'package:flutter/material.dart';

class AppResponsive {
  AppResponsive._();

  static double getImageSize(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth * 0.26).clamp(90.0, 150.0);
  }

  static double getIconSize(BuildContext context, double imageSize) {
    return (imageSize * 0.3).clamp(20.0, 28.0);
  }

  static double getDialogWidth(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth * 0.9).clamp(300.0, 400.0);
  }

  static double getCardPadding(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return 12.0;
    } else if (screenWidth < 480) {
      return 16.0;
    } else {
      return 20.0;
    }
  }

  static double getButtonHeight(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight < 700) {
      return 44.0;
    } else if (screenHeight < 900) {
      return 48.0;
    } else {
      return 52.0;
    }
  }

  static double getFontScale(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return 0.9;
    } else if (screenWidth < 480) {
      return 1.0;
    } else {
      return 1.1;
    }
  }

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  static bool isMediumScreen(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return width >= 360 && width < 480;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 480;
  }
}

