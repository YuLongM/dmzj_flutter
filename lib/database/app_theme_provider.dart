import 'package:flutter/material.dart';
import 'package:flutter_dmzj/helper/config_helper.dart';

class AppThemeProvider with ChangeNotifier {
  AppThemeProvider() {
    changeDark(ConfigHelper.getOpenDarkMode());
    changeSysDark(ConfigHelper.getSysDarkMode());
    changeTheme(ConfigHelper.getAppTheme());
  }

  ThemeData createThemeData(List<Color> color, bool isdark) {
    if (color.length > 1) {
      return ThemeData(
        brightness: isdark ? Brightness.dark : Brightness.light,
        primarySwatch: color[0],
        accentColor: color[1],
        toggleableActiveColor: color[2],
        bottomAppBarColor: color[3],
        buttonColor: color[0],
      );
    } else {
      return ThemeData(
        brightness: isdark ? Brightness.dark : Brightness.light,
        primarySwatch: color[0],
        accentColor: color[0],
        buttonColor: color[0],
        toggleableActiveColor: color[0],
      );
    }
  }

  static Map<String, List<Color>> localThemes = {
    "胖次蓝": List.filled(1, Colors.blue),
    "姨妈红": List.filled(1, Colors.red),
    "咸蛋黄": List.filled(1, Colors.yellow),
    "早苗绿": List.filled(1, Colors.green),
    "少女粉": List.filled(1, Colors.pink),
    "基佬紫": List.filled(1, Colors.purple),
    "朴素灰": List.filled(1, Colors.blueGrey),
    "赛博朋克": [Colors.pink, Colors.cyan, Colors.amber, Color(0xffebe105)]
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
    for (var item in AppThemeProvider.localThemes.keys) {
      widgets.add(RadioListTile(
        groupValue: item,
        value: _appThemeName,
        title: new Text(
          item,
          style: TextStyle(color: AppThemeProvider.localThemes[item][0]),
        ),
        onChanged: (value) {
          changeTheme(AppThemeProvider.localThemes.keys.toList().indexOf(item));
          Navigator.of(context).pop();
        },
      ));
    }
    return widgets;
  }

  bool _isDark;
  bool _sysDark;
  ThemeData _appTheme;
  ThemeData _darkTheme;
  String _appThemeName;
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

  void changeTheme(int index) {
    _appTheme = createThemeData(
        AppThemeProvider.localThemes.values.toList()[index], false);
    _darkTheme = createThemeData(
        AppThemeProvider.localThemes.values.toList()[index], true);
    _appThemeName = AppThemeProvider.localThemes.keys.toList()[index];
    notifyListeners();
    ConfigHelper.setAppTheme(index);
  }

  get appTheme => _appTheme;
  get darkTheme => _darkTheme;
  get appThemeName => _appThemeName;
}
