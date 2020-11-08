import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dmzj/app/app_setting.dart';
import 'package:flutter_dmzj/app/config_helper.dart';
import 'package:flutter_dmzj/app/utils.dart';
import 'package:flutter_dmzj/sql/comic_down.dart';
import 'package:flutter_dmzj/sql/comic_history.dart';
import 'package:flutter_dmzj/views/comic/comic_home.dart';
import 'package:flutter_dmzj/views/settings/comic_reader_settings.dart';
import 'package:flutter_dmzj/views/settings/novel_reader_settings.dart';
import 'package:flutter_dmzj/views/user/login_page.dart';
import 'package:flutter_dmzj/views/news/news_home.dart';
import 'package:flutter_dmzj/views/novel/novel_home.dart';
import 'package:flutter_dmzj/views/setting_page.dart';
import 'package:flutter_dmzj/views/user/personal_page.dart';
import 'package:flutter_dmzj/views/user/user_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'app/app_theme.dart';
import 'app/user_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ConfigHelper.prefs = await SharedPreferences.getInstance();
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  }
  await initDatabase();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<AppTheme>(create: (_) => AppTheme(), lazy: false),
      ChangeNotifierProvider<AppUserInfo>(
          create: (_) => AppUserInfo(), lazy: false),
      ChangeNotifierProvider<AppSetting>(
          create: (_) => AppSetting(), lazy: false),
    ],
    child: MyApp(),
  ));
}

Future initDatabase() async {
  var databasesPath = await getDatabasesPath();
  // File(databasesPath+"/nsplayer.db").deleteSync();
  var db = await openDatabase(databasesPath + "/comic_history.db", version: 1,
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
$comicDownloadColumnChapterID integer primary key not null,
$comicDownloadColumnChapterName text not null,
$comicDownloadColumnComicID integer not null,
$comicDownloadColumnComicName text not null,
$comicDownloadColumnStatus integer not null,
$comicDownloadColumnVolume text not null,
$comicDownloadColumnPage integer ,
$comicDownloadColumnCount integer ,
$comicDownloadColumnSavePath text ,
$comicDownloadColumnUrls text )
''');
  });

  ComicHistoryProvider.db = db;
  ComicDownloadProvider.db = db;
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '动漫之家Flutter',
      theme: ThemeData(
        brightness: Provider.of<AppTheme>(context).isDark
            ? Brightness.dark
            : Brightness.light,
        primarySwatch: Provider.of<AppTheme>(context).themeColor,
        accentColor: Provider.of<AppTheme>(context).themeColor,
        toggleableActiveColor: Provider.of<AppTheme>(context).themeColor,
      ),
      darkTheme: (Provider.of<AppTheme>(context).sysDark)
          ? ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Provider.of<AppTheme>(context).themeColor,
              accentColor: Provider.of<AppTheme>(context).themeColor,
              toggleableActiveColor: Provider.of<AppTheme>(context).themeColor,
              textSelectionColor: Provider.of<AppTheme>(context).themeColor,
            )
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (decideView()) {
      case 0:
        return xsView();
        break;
      case 1:
        return smView();
        break;
      case 2:
        return mdView();
        break;
      case 3:
        return lgView();
        break;
      default:
        return mdView();
    }
  }

  void onNavigateTap(int index) {
    if (index == 1 && newsPage == null) {
      newsPage = NewsHomePage();
      pages[1] = newsPage;
    }
    if (index == 2 && novelPage == null) {
      novelPage = NovelHomePage();
      pages[2] = novelPage;
    }
    _index = index;
    return;
  }

  Widget drawerView() {
    return Drawer(
        child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: navLabel.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return DrawerHeader(
                  child: Center(
                    child: ImageIcon(
                      AssetImage("assets/icon_dmzj.png"),
                      size: kToolbarHeight,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                );
              } else {
                index = index - 1;
              }
              return ListTile(
                selected: index == _index,
                dense: true,
                leading: Icon(navIcon[index]),
                title: Text(navLabel[index]),
                onTap: () {
                  setState(() {
                    onNavigateTap(index);
                  });
                  //Navigator.pop(context);
                },
              );
            }));
  }

  Widget bodyView() {
    return Row(
      children: <Widget>[
        Expanded(
            child: IndexedStack(
          index: _index,
          children: pages,
        ))
      ],
    );
  }

  List<String> navLabel = ["漫画", "新闻", "小说", "我的"];
  List<IconData> navIcon = [
    Icons.library_books,
    Icons.whatshot,
    Icons.book,
    Icons.account_circle
  ];

  int decideView() {
    double width = MediaQuery.of(context).size.width;
    if (width < 1280) {
      if (width < 960) {
        if (width < 600) {
          return 0;
        } else {
          return 1;
        }
      } else {
        return 2;
      }
    } else {
      return 3;
    }
  }

  Widget xsView() {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _index,
            onTap: (index) {
              setState(() {
                onNavigateTap(index);
              });
            },
            items: List<BottomNavigationBarItem>.generate(
                navLabel.length,
                (index) => BottomNavigationBarItem(
                      label: navLabel[index],
                      icon: Icon(navIcon[index]),
                    ))),
        body: bodyView());
  }

  Widget smView() {
    return Scaffold(
      body: Row(
        children: [
          Container(
              width: kToolbarHeight,
              color: Theme.of(context).accentColor,
              child: ListView.builder(
                  itemExtent: kToolbarHeight,
                  padding: EdgeInsets.zero,
                  itemCount: navLabel.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: EdgeInsets.all(8),
                        child: ImageIcon(
                          AssetImage("assets/icon_dmzj.png"),
                        ),
                      );
                    }
                    return IconButton(
                      color: Colors.white,
                      icon: Icon(navIcon[index - 1]),
                      onPressed: () {
                        setState(() {
                          onNavigateTap(index - 1);
                        });
                      },
                    );
                  })),
          Expanded(
            child: bodyView(),
          ),
        ],
      ),
    );
  }

  Widget mdView() {
    return Scaffold(
      body: Row(
        children: [
          Container(width: 300, child: drawerView()),
          Expanded(
            child: bodyView(),
          ),
        ],
      ),
    );
  }

  Widget lgView() {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 300,
            child: drawerView(),
          ),
          Expanded(
            child: bodyView(),
          ),
          Expanded(
              child: Stack(
            children: [
              Container(
                color: Theme.of(context).accentColor,
                child: Center(
                  child: ImageIcon(
                    AssetImage("assets/icon_dmzj.png"),
                    size: kToolbarHeight,
                  ),
                ),
              ),
              Container()
            ],
          ))
        ],
      ),
    );
  }
}
