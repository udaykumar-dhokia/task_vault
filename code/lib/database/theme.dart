import 'dart:ui';

class uiTheme {
  Color? themeColor;
  bool? switchValue;

  uiTheme({this.switchValue, this.themeColor});

  Map<String, dynamic> toMap() {
    return {"themeColor": themeColor, "switchValue": switchValue};
  }
}
