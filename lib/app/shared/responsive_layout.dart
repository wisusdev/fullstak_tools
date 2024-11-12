import 'package:flutter/material.dart';

class Responsive {

    static containerMaxWidthSize(BuildContext context, BoxConstraints constraints, {double mobile = 1, double tablet = 1, double desktop = 1}) {
        if (isMobile(context)) {
            return constraints.maxWidth * mobile;
        } else if (isTablet(context)) {
            return constraints.maxWidth * tablet;
        } else if (isDesktop(context)) {
            return constraints.maxWidth * desktop;
        }
    }

    static bool isMobile(BuildContext context) {
        return MediaQuery.of(context).size.width < 600;
    }

    static bool isTablet(BuildContext context) {
        return MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;
    }

    static bool isDesktop(BuildContext context) {
        return MediaQuery.of(context).size.width >= 1200;
    }
}