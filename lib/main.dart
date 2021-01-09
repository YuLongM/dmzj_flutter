import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dmzj/provider/reader_config_provider.dart';
import 'package:flutter_dmzj/helper/config_helper.dart';
import 'package:flutter_dmzj/database/comic_history.dart';
import 'package:flutter_dmzj/views/comic/comic_home.dart';
import 'package:flutter_dmzj/views/download/download_models.dart';
import 'package:flutter_dmzj/views/settings/comic_reader_settings.dart';
import 'package:flutter_dmzj/views/settings/novel_reader_settings.dart';
import 'package:flutter_dmzj/views/user/login_page.dart';
import 'package:flutter_dmzj/views/news/news_home.dart';
import 'package:flutter_dmzj/views/novel/novel_home.dart';
import 'package:flutter_dmzj/views/setting_page.dart';
import 'package:flutter_dmzj/views/user/personal_page.dart';
import 'package:flutter_dmzj/views/user/user_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'database/app_theme_provider.dart';
import 'provider/user_info_provider.dart';
import 'helper/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ConfigHelper.prefs = await SharedPreferences.getInstance();
  await initDatabase();
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String appDocPath = appDocDir.absolute.path;
  print(appDocPath);
  var directory =
      await new Directory("$appDocPath/downloads").create(recursive: true);

  assert(await directory.exists() == true);
  //输出绝对路径
  print("Path: ${directory.absolute.path}");

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<AppThemeProvider>(
          create: (_) => AppThemeProvider(), lazy: false),
      ChangeNotifierProvider<AppUserInfoProvider>(
          create: (_) => AppUserInfoProvider(), lazy: false),
      ChangeNotifierProvider<ReaderConfigProvider>(
          create: (_) => ReaderConfigProvider(), lazy: false),
      ChangeNotifierProvider(
        create: (_) => ComicHistoryProvider(),
        lazy: false,
      ),
      ChangeNotifierProvider(
        create: (_) => Downloader(),
        lazy: false,
      )
    ],
    child: ExcludeSemantics(
      child: MyApp(),
    ),
  ));
  if (Platform.isAndroid) {
    //设置Android头部的导航栏透明
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, //全局设置透明
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
      //light:黑色图标 dark：白色图标
      //在此处设置statusBarIconBrightness为全局设置
    );
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

Future initDatabase() async {
  var databasesPath = await getDatabasesPath();
  // File(databasesPath+"/nsplayer.db").deleteSync();
  var db = await openDatabase(databasesPath + "/app.db", version: 1,
      onCreate: (Database _db, int version) async {
    await _db.execute('''
create table $comicHistoryTable ( 
  $comicHistoryColumnComicID integer primary key not null, 
  $comicHistoryColumnChapterID integer not null,
  $comicHistoryColumnPage double not null,
  $comicHistoryMode integer not null)
''');

    await _db.execute('''
create table $comicDownloadTableName (
$comicDownloadColumnChapterId integer primary key not null,
$comicDownloadColumnChapterName text not null,
$comicDownloadColumnComicId integer not null,
$comicDownloadColumnComicName text not null,
$comicDownloadColumnStatus integer not null,
$comicDownloadColumnVolume integer not null)''');
  });

  ComicHistoryHelper.db = db;
  DownloadHelper.db = db;
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'dmzj dev',
      theme: Provider.of<AppThemeProvider>(context).isDark
          ? Provider.of<AppThemeProvider>(context).darkTheme
          : Provider.of<AppThemeProvider>(context).appTheme,
      darkTheme: (Provider.of<AppThemeProvider>(context).sysDark)
          ? Provider.of<AppThemeProvider>(context).darkTheme
          : null,
      home: MyHomePage(),
      initialRoute: "/",
      routes: {
        "/Setting": (_) => SettingPage(),
        "/Login": (_) => LoginPage(),
        "/User": (_) => UserPage(),
        "/ComicReaderSettings": (_) => ComicReaderSettings(),
        "/NovelReaderSettings": (_) => NovelReaderSettings(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  static NewsHomePage newsPage;
  static NovelHomePage novelPage;
  List<Widget> pages = [
    ComicHomePage(),
    Container(),
    Container(),
    PersonalPage()
  ];
  int _index = 0;
  int _preindex = 0;

  @override
  void initState() {
    super.initState();
    final QuickActions quickActions = QuickActions();
    quickActions.initialize((String shortcutType) {
      int type = int.parse(shortcutType);
      if (!Provider.of<AppUserInfoProvider>(context, listen: false).isLogin)
        type = 0;
      print(type);
      switch (type) {
        case 1:
          Utils.openSubscribePage(context);
          break;
        case 2:
          Utils.openHistoryPage(context);
          break;
        default:
          Fluttertoast.showToast(msg: "没有登陆");
          Navigator.pushNamed(context, "/Login");
      }
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      // NOTE: This first action icon will only work on iOS.
      // In a real world project keep the same file name for both platforms.
      const ShortcutItem(
        type: '1',
        localizedTitle: '我的订阅',
        icon: 'ic_fav',
      ),
      // NOTE: This second action icon will only work on Android.
      // In a real world project keep the same file name for both platforms.
      const ShortcutItem(type: '2', localizedTitle: '浏览记录', icon: 'ic_history'),
    ]);
    //checkUpdate();
  }

  // void checkUpdate() async {
  //   var newVer = await Utils.checkVersion();
  //   if (newVer == null) {
  //     return;
  //   }
  //   if (await Utils.showAlertDialogAsync(
  //       context, Text('有新版本可以更新'), Text(newVer.message))) {
  //     if (Platform.isAndroid) {
  //       launch(newVer.android_url);
  //     } else {
  //       launch(newVer.ios_url);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (_index != 0) {
          setState(() {
            _index = 0;
          });
          return Future.value(false);
        }
        return doubleClickBack();
      },
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          currentIndex: _index,
          unselectedItemColor: Theme.of(context).buttonColor.withOpacity(0.5),
          selectedItemColor: Theme.of(context).buttonColor,
          onTap: (index) {
            setState(() {
              _preindex = _index;
              if (index == 1 && newsPage == null) {
                newsPage = NewsHomePage();
                pages[1] = newsPage;
              }
              if (index == 2 && novelPage == null) {
                novelPage = NovelHomePage();
                pages[2] = novelPage;
              }
              _index = index;
            });
          },
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              backgroundColor: Theme.of(context).bottomAppBarColor,
              label: "漫画",
              icon: Icon(Icons.photo_album),
            ),
            BottomNavigationBarItem(
              backgroundColor: Theme.of(context).bottomAppBarColor,
              label: "新闻",
              icon: Icon(Icons.article),
            ),
            BottomNavigationBarItem(
              backgroundColor: Theme.of(context).bottomAppBarColor,
              label: "轻小说",
              icon: Icon(Icons.book),
            ),
            BottomNavigationBarItem(
              backgroundColor: Theme.of(context).bottomAppBarColor,
              label: "我的",
              icon: Icon(Icons.account_circle),
            ),
          ],
        ),
        body: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 300),
          reverse: _preindex > _index,
          transitionBuilder: (
            Widget child,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return SharedAxisTransition(
              child: child,
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
            );
          },
          child: pages[_index],
        ),
      ),
    );
  }

  int last = 0;

  Future<bool> doubleClickBack() {
    int now = DateTime.now().millisecondsSinceEpoch;
    if (now - last > 1000) {
      last = DateTime.now().millisecondsSinceEpoch;
      Fluttertoast.showToast(msg: '双击返回退出');
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
