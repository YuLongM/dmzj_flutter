import 'package:flutter/material.dart';
import 'package:flutter_dmzj/database/app_theme_provider.dart';
import 'package:flutter_dmzj/provider/user_info_provider.dart';
import 'package:flutter_dmzj/helper/utils.dart';
import 'package:flutter_dmzj/views/download/download_list_view.dart';
import 'package:flutter_dmzj/views/download/local_comic.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:flutter_dmzj/views/download/local_comic.dart';
import 'package:provider/provider.dart';

class PersonalPage extends StatefulWidget {
  PersonalPage({Key key}) : super(key: key);

  @override
  _PersonalPageState createState() => _PersonalPageState();
}

const myExpandedHeight = 240.0;

class _PersonalPageState extends State<PersonalPage> {
  ScrollController _scrollController;
  bool isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController();
    _scrollController.addListener(() {
      setState(() {
        isCollapsed = _isCollapsed;
      });
    });
  }

  @override
  void dispose() {
    //为了避免内存泄露，需要调用_controller.dispose
    _scrollController.dispose();
    super.dispose();
  }

  double getSafebar() {
    return MediaQuery.of(context).padding.top;
  }

  bool get _isCollapsed {
    return _scrollController.hasClients &&
        _scrollController.offset >=
            myExpandedHeight - kToolbarHeight - getSafebar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                pinned: true,
                leading: Offstage(
                    offstage: !isCollapsed,
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: _getAvatarSmall(),
                    )),
                expandedHeight: myExpandedHeight - getSafebar(),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Stack(
                    children: <Widget>[
                      Image.asset(
                        "assets/img_ucenter_def_bac.jpg",
                        fit: BoxFit.cover,
                        height: myExpandedHeight,
                        width: MediaQuery.of(context).size.width,
                      ),
                      Positioned(
                          child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: myExpandedHeight,
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Theme.of(context).cardColor.withOpacity(1),
                              Theme.of(context).cardColor.withOpacity(0.3)
                            ],
                          ),
                        ),
                        child: _getAvatar(),
                      ))
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: Builder(builder: (context) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Material(
                      color: Theme.of(context).cardColor,
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            title: Text("我的订阅"),
                            leading: Icon(Icons.favorite),
                            trailing:
                                Icon(Icons.chevron_right, color: Colors.grey),
                            onTap: () => Utils.openSubscribePage(context),
                          ),
                          ListTile(
                            title: Text("浏览记录"),
                            leading: Icon(Icons.history),
                            trailing:
                                Icon(Icons.chevron_right, color: Colors.grey),
                            onTap: () => Utils.openHistoryPage(context),
                          ),
                          ListTile(
                            title: Text("我的评论"),
                            leading: Icon(Icons.comment),
                            trailing:
                                Icon(Icons.chevron_right, color: Colors.grey),
                            onTap: () => Utils.openMyCommentPage(context),
                          ),
                          ListTile(
                            title: Text("我的下载"),
                            trailing:
                                Icon(Icons.chevron_right, color: Colors.grey),
                            leading: Icon(Icons.file_download),
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (BuildContext context) =>
                              //         LocalComicPage(),
                              //   ),
                              // )
                              bool inDebugMode = false;
                              assert(inDebugMode = true);
                              if (inDebugMode) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          DownloadListView()),
                                );
                              }
                              Fluttertoast.showToast(msg: '敬请期待');
                            },
                          ),
                          ListTile(
                            title: Text("本地漫画"),
                            trailing:
                                Icon(Icons.chevron_right, color: Colors.grey),
                            leading: Icon(Icons.file_download),
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (BuildContext context) =>
                              //         LocalComicPage(),
                              //   ),
                              // )
                              bool inDebugMode = false;
                              assert(inDebugMode = true);
                              if (inDebugMode) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          LocalComicPage()),
                                );
                              }
                              Fluttertoast.showToast(msg: '敬请期待');
                            },
                          )
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 12,
                    ),

                    Material(
                      color: Theme.of(context).cardColor,
                      child: SwitchListTile(
                        onChanged: (value) {
                          Provider.of<AppThemeProvider>(context, listen: false)
                              .changeSysDark(value);
                          if (!value) {
                            Provider.of<AppThemeProvider>(context,
                                    listen: false)
                                .changeDark(value);
                          }
                        },
                        secondary: Icon(Icons.brightness_4),
                        title: Text("夜间模式跟随系统"),
                        value: Provider.of<AppThemeProvider>(context).sysDark,
                      ),
                    ),
                    Offstage(
                      offstage: Provider.of<AppThemeProvider>(context).sysDark,
                      child: Material(
                        color: Theme.of(context).cardColor,
                        child: SwitchListTile(
                          onChanged: (value) {
                            Provider.of<AppThemeProvider>(context,
                                    listen: false)
                                .changeDark(value);
                          },
                          secondary: Icon(Icons.brightness_4),
                          title: Text("夜间模式"),
                          value: Provider.of<AppThemeProvider>(context).isDark,
                        ),
                      ),
                    ),
                    //主题设置
                    Material(
                      color: Theme.of(context).cardColor,
                      child: ListTile(
                        title: Text("主题切换"),
                        leading: Icon(Icons.color_lens),
                        trailing: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            Provider.of<AppThemeProvider>(context).appThemeName,
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 14.0),
                          ),
                        ),
                        onTap: () => Provider.of<AppThemeProvider>(context,
                                listen: false)
                            .showThemeDialog(
                                context), //Provider.of<AppThemeData>(context).changeThemeColor(3),
                      ),
                    ),

                    SizedBox(
                      height: 12,
                    ),
                    Material(
                      color: Theme.of(context).cardColor,
                      child: Column(children: <Widget>[
                        ListTile(
                          title: Text("设置"),
                          leading: Icon(Icons.settings),
                          trailing:
                              Icon(Icons.chevron_right, color: Colors.grey),
                          onTap: () {
                            Navigator.pushNamed(context, "/Setting");
                          },
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _getAvatar() {
    return Provider.of<AppUserInfoProvider>(context).isLogin
        ? InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: Text("退出登录"),
                        content: Text("确定要退出登录吗?"),
                        actions: <Widget>[
                          new FlatButton(
                            child: new Text("取消"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          new FlatButton(
                            child: new Text("确定"),
                            onPressed: () {
                              Provider.of<AppUserInfoProvider>(context,
                                      listen: false)
                                  .logout();
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      ));
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 64,
                  height: 64,
                  child: CircleAvatar(
                    radius: 32,
                    backgroundImage: Utils.createCachedImageProvider(
                        Provider.of<AppUserInfoProvider>(context)
                            .loginInfo
                            .photo),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  Provider.of<AppUserInfoProvider>(context).loginInfo.nickname,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  Provider.of<AppUserInfoProvider>(context)
                          .userProfile
                          ?.description ??
                      "",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          )
        : InkWell(
            onTap: () => Navigator.pushNamed(context, "/Login"),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 64,
                  height: 64,
                  child: CircleAvatar(
                    child: Icon(Icons.account_circle),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  "点击登录",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
  }

  Widget _getAvatarSmall() {
    return Padding(
      padding: EdgeInsets.all(4),
      child: InkWell(
        onTap: () {
          Provider.of<AppUserInfoProvider>(context).isLogin
              ? showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: Text("退出登录"),
                        content: Text("确定要退出登录吗?"),
                        actions: <Widget>[
                          new FlatButton(
                            child: new Text("取消"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          new FlatButton(
                            child: new Text("确定"),
                            onPressed: () {
                              Provider.of<AppUserInfoProvider>(context,
                                      listen: false)
                                  .logout();
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      ))
              : Navigator.pushNamed(context, "/Login");
        },
        child: Provider.of<AppUserInfoProvider>(context).isLogin
            ? CircleAvatar(
                radius: 32,
                backgroundImage: Utils.createCachedImageProvider(
                    Provider.of<AppUserInfoProvider>(context).loginInfo.photo),
              )
            : CircleAvatar(
                child: Icon(Icons.account_circle),
              ),
      ),
    );
  }
}
