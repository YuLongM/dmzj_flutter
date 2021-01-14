import 'package:flutter/material.dart';
import 'package:flutter_dmzj/database/app_theme_provider.dart';
import 'package:flutter_dmzj/provider/user_info_provider.dart';
import 'package:flutter_dmzj/helper/utils.dart';
import 'package:flutter_dmzj/views/download/download_list_view.dart';
import 'package:flutter_dmzj/views/download/local_comic.dart';
import 'package:flutter_dmzj/widgets/collapse_header.dart';
// import 'package:flutter_dmzj/views/download/local_comic.dart';
import 'package:provider/provider.dart';

class PersonalPage extends StatefulWidget {
  PersonalPage({Key key}) : super(key: key);

  @override
  _PersonalPageState createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  bool isCollapsed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    //为了避免内存泄露，需要调用_controller.dispose
    super.dispose();
  }

  double getSafebar() {
    return MediaQuery.of(context).padding.top;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverPersistentHeader(
                pinned: true,
                delegate: CollapseHeaderDelegate(
                    avatar: InkWell(
                      onTap: onTapAvatar,
                      child: Provider.of<AppUserInfoProvider>(context).isLogin
                          ? null
                          : Icon(Icons.account_circle),
                    ),
                    label: InkWell(
                      onTap: onTapAvatar,
                      child: Text(
                        Provider.of<AppUserInfoProvider>(context).isLogin
                            ? Provider.of<AppUserInfoProvider>(context)
                                .loginInfo
                                .nickname
                            : '登录',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    maxHeight: MediaQuery.of(context).size.shortestSide * 0.68,
                    minHeight: kToolbarHeight,
                    safeOffset: getSafebar(),
                    image: Provider.of<AppUserInfoProvider>(context).isLogin
                        ? Utils.createCachedImageProvider(
                            Provider.of<AppUserInfoProvider>(context)
                                .loginInfo
                                .photo)
                        : null),
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
                      //
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        DownloadList()),
                              );
                            },
                          ),
                          ListTile(
                            title: Text("本地漫画"),
                            trailing:
                                Icon(Icons.chevron_right, color: Colors.grey),
                            leading: Icon(Icons.file_download),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        LocalComicPage()),
                              );
                            },
                          )
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 12,
                    ),

                    Material(
                      //
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

  void onTapAvatar() {
    if (Provider.of<AppUserInfoProvider>(context, listen: false).isLogin) {
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
                      Provider.of<AppUserInfoProvider>(context, listen: false)
                          .logout();
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ));
    } else {
      Navigator.pushNamed(context, "/Login");
    }
  }
}
