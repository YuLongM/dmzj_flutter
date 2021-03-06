import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dmzj/helper/utils.dart';
import 'package:flutter_dmzj/views/comic/comic_category.dart';
import 'package:flutter_dmzj/views/comic/comic_rank.dart';
import 'package:flutter_dmzj/views/comic/comic_recommend_v2.dart';
import 'package:flutter_dmzj/views/comic/comic_search.dart';
import 'package:flutter_dmzj/views/comic/comic_special.dart';
import 'package:flutter_dmzj/views/comic/comic_update.dart';

class ComicHomePage extends StatefulWidget {
  @override
  _ComicHomePageState createState() => _ComicHomePageState();
}

class _ComicHomePageState extends State<ComicHomePage>
    with TickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    Utils.changeComicHomeTabIndex.on<int>().listen((e) {
      _tabController.animateTo(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kTextTabBarHeight),
        child: Container(
          color: Theme.of(context).primaryColor,
          child: SafeArea(
            child: TabBar(
              controller: _tabController,
              tabs: <Widget>[
                Tab(child: Text("推荐")),
                Tab(child: Text("更新")),
                Tab(child: Text("分类")),
                Tab(child: Text("排行")),
                Tab(child: Text("专题")),
              ],
              labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              labelColor: Theme.of(context).indicatorColor,
              indicatorSize: TabBarIndicatorSize.label,
            ),
          ),
        ),
      ),
      floatingActionButton: OpenContainer(
        transitionType: ContainerTransitionType.fade,
        openBuilder: (BuildContext context, VoidCallback _) {
          return ComicSearchPage();
        },
        closedElevation: 6.0,
        closedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(56.0 / 2),
          ),
        ),
        closedColor: Theme.of(context).colorScheme.secondary,
        closedBuilder: (BuildContext context, VoidCallback openContainer) {
          return SizedBox(
            height: 56.0,
            width: 56.0,
            child: Center(
              child: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          );
        },
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          ComicRecommend(),
          ComicUpdatePage(),
          ComicCategoryPage(),
          ComicRankPage(),
          ComicSpecialPage(),
        ],
      ),
    );
  }
}
