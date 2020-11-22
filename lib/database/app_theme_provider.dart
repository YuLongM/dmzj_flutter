import 'package:flutter/material.dart';
import 'package:flutter_dmzj/helper/config_helper.dart';

class AppThemeProvider with ChangeNotifier {
  AppThemeProvider() {
    changeDark(ConfigHelper.getOpenDarkMode());
    changeSysDark(ConfigHelper.getSysDarkMode());
    changeThemeColor(ConfigHelper.getAppTheme());
  }

  static Map<String, Color> themeColors = {
    "胖次蓝": Colors.blue,
    "姨妈红": Colors.red,
    "咸蛋黄": Colors.yellow,
    "早苗绿": Colors.green,
    "少女粉": Colors.pink,
    "基佬紫": Colors.purple,
    "朴素灰": Colors.blueGrey
  };

  void showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return new SimpleDialog(
          title: new Text('切换主题'),
          children: _createThemeWidget(context),
        );
      },
    );
  }

  List<Widget> _createThemeWidget(BuildContext context) {
    List<Widget> widgets = List<Widget>();
    for (var item in AppThemeProvider.themeColors.keys) {
      widgets.add(RadioListTile(
        groupValue: item,
        value: _themeColorName,
        title: new Text(
          item,
          style: TextStyle(color: AppThemeProvider.themeColors[item]),
        ),
        onChanged: (value) {
          changeThemeColor(AppThemeProvider.themeColors.keys.toList().indexOf(item));
          Navigator.of(context).pop();
        },
      ));
    }
    return widgets;
  }

  bool _isDark;
  bool _sysDark;
  Color _themeColor;
  String _themeColorName;
  void changeDark(bool value) {
    _isDark = value;

    notifyListeners();
    ConfigHelper.setOpenDarkMode(value);
  }

  void changeSysDark(bool value) {
    _sysDark = value;

    notifyListeners();
    ConfigHelper.setSysDarkMode(value);
  }

  get isDark => _isDark;
  get sysDark => _sysDark;

  void changeThemeColor(int index) {
    _themeColor = AppThemeProvider.themeColors.values.toList()[index];
    _themeColorName = AppThemeProvider.themeColors.keys.toList()[index];
    notifyListeners();
    ConfigHelper.setAppTheme(index);
  }

  get themeColor => _themeColor;
  get themeColorName => _themeColorName;
}
