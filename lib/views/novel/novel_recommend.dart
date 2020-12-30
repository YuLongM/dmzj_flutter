import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dmzj/helper/api.dart';
import 'package:flutter_dmzj/helper/utils.dart';
import 'package:flutter_dmzj/models/comic/comic_home_banner_item.dart';
import 'package:flutter_dmzj/models/comic/comic_home_comic_item.dart';
import 'package:flutter_dmzj/widgets/app_banner.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:http/http.dart' as http;

class NovelRecommend extends StatefulWidget {
  NovelRecommend({Key key}) : super(key: key);

  NovelRecommendState createState() => NovelRecommendState();
}

class NovelRecommendState extends State<NovelRecommend>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<ComicHomeBannerItem> _banners = [];
  List<ComicHomeComicItem> _new = [];
  List<ComicHomeComicItem> _animeIng = [];
  List<ComicHomeComicItem> _anime = [];
  List<ComicHomeComicItem> _hot = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  double getRatio() {
    var width = MediaQuery.of(context).size.shortestSide;
    double s_width = (width - 24) / 3 - 32;

    double s_ratio = s_width / ((s_width * (360 / 270)) + 36);

    return s_ratio;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double widthMax = MediaQuery.of(context).size.width /
        (1 + MediaQuery.of(context).orientation.index);
    return Scaffold(
      // floatingActionButton: MediaQuery.of(context).size.width > 600
      body: EasyRefresh.custom(
        header: MaterialHeader(),
        footer: MaterialFooter(),
        onRefresh: refreshData,
        slivers: [
          MediaQuery.of(context).orientation == Orientation.landscape
              ? SliverToBoxAdapter(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Container(
                        width: widthMax,
                        child: AppBanner(
                            items: _banners
                                .map<Widget>((i) => BannerImageItem(
                                      pic: i.cover,
                                      title: i.title,
                                      onTaped: () => Utils.openPage(
                                          context, i.id, i.type,
                                          url: i.url, title: i.title),
                                    ))
                                .toList()),
                      ),
                      _getItem("最近更新", _new,
                          icon: Icon(Icons.chevron_right, color: Colors.grey),
                          needSubTitle: false,
                          ratio: getRatio(),
                          ontap: () => Utils.changeNovelHomeTabIndex.fire(1)),
                      _getItem(
                        "动画进行时",
                        _animeIng,
                        ratio: getRatio(),
                      ),
                      _getItem(
                        "即将动画化",
                        _anime,
                        ratio: getRatio(),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: _getItem("经典必看", _hot,
                            ratio: getRatio(),
                            count: 6 ~/
                                (2 - MediaQuery.of(context).orientation.index)),
                      ),
                      Container(
                        width: double.infinity,
                        height: kToolbarHeight,
                        //padding: EdgeInsets.all(12),
                        child: Center(
                          child: Text(
                            '没有下面了',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : SliverList(
                  delegate: SliverChildListDelegate([
                  AppBanner(
                      items: _banners
                          .map<Widget>((i) => BannerImageItem(
                                pic: i.cover,
                                title: i.title,
                                onTaped: () => Utils.openPage(
                                    context, i.id, i.type,
                                    url: i.url, title: i.title),
                              ))
                          .toList()),
                  _getItem("最近更新", _new,
                      icon: Icon(Icons.chevron_right, color: Colors.grey),
                      needSubTitle: false,
                      ratio: getRatio(),
                      ontap: () => Utils.changeNovelHomeTabIndex.fire(1)),
                  _getItem(
                    "动画进行时",
                    _animeIng,
                    ratio: getRatio(),
                  ),
                  _getItem("即将动画化", _anime, ratio: getRatio()),
                  _getItem(
                    "经典必看",
                    _hot,
                    ratio: getRatio(),
                  ),
                  Container(
                    width: double.infinity,
                    height: kToolbarHeight,
                    //padding: EdgeInsets.all(12),
                    child: Center(
                      child: Text(
                        '没有下面了',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ])),
        ],
      ),
    );
  }

  Widget _getItem(String title, List items,
      {Icon icon,
      Function ontap,
      bool needSubTitle = true,
      int count = 3,
      double ratio = 3 / 5.2,
      double imgWidth = 270,
      double imgHeight = 360}) {
    double widthMax = MediaQuery.of(context).size.width /
            (1 + MediaQuery.of(context).orientation.index) -
        16;
    return Offstage(
      offstage: items == null || items.length == 0,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          constraints: BoxConstraints(maxWidth: widthMax),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _getTitle(title, icon: icon, ontap: ontap),
              SizedBox(
                height: 4.0,
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: count,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                    childAspectRatio: ratio),
                itemBuilder: (context, i) => Utils.createCoverWidget(
                    items[i].id,
                    items[i].type,
                    items[i].cover,
                    items[i].title,
                    context,
                    author: needSubTitle ? items[i].sub_title : "",
                    width: imgWidth,
                    height: imgHeight),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getTitle(String title, {Icon icon, Function ontap}) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
              padding: EdgeInsets.fromLTRB(8, 4, 4, 4),
              child: Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )),
        ),
        Offstage(
          offstage: icon == null,
          child: Material(
              child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: ontap,
            child: Padding(
                padding: EdgeInsets.all(4),
                child: icon ??
                    Icon(
                      Icons.refresh,
                      color: Colors.grey,
                    )),
          )),
        )
      ],
    );
  }

  Future refreshData() async {
    await loadData();
  }

  bool _loading = false;
  Future loadData() async {
    try {
      if (_loading) {
        return;
      }
      _loading = true;
      var response = await http.get(Api.novelRecommend);
      List jsonMap = jsonDecode(response.body);
      //Banner
      {
        List bannerItem = jsonMap[0]["data"];
        List<ComicHomeBannerItem> banners =
            bannerItem.map((i) => ComicHomeBannerItem.fromJson(i)).toList();
        if (banners.length != 0) {
          setState(() {
            _banners = banners.where((e) => e.type != 10).toList();
          });
        }
      }

      //最近更新
      {
        List items = jsonMap[1]["data"];
        List<ComicHomeComicItem> _items =
            items.map((i) => ComicHomeComicItem.fromJson(i)).toList();
        if (_items.length != 0) {
          setState(() {
            _new = _items;
          });
        }
      }
      //动画进行
      {
        List items = jsonMap[2]["data"];
        List<ComicHomeComicItem> _items =
            items.map((i) => ComicHomeComicItem.fromJson(i)).toList();
        if (_items.length != 0) {
          setState(() {
            _animeIng = _items;
          });
        }
      }
      //动画专区
      {
        List items = jsonMap[3]["data"];
        List<ComicHomeComicItem> _items =
            items.map((i) => ComicHomeComicItem.fromJson(i)).toList();
        if (_items.length != 0) {
          setState(() {
            _anime = _items;
          });
        }
      }
      //经典
      {
        List items = jsonMap[4]["data"];
        List<ComicHomeComicItem> _items =
            items.map((i) => ComicHomeComicItem.fromJson(i)).toList();
        if (_items.length != 0) {
          setState(() {
            _hot = _items;
          });
        }
      }
    } catch (e) {
      print(e);
    } finally {
      _loading = false;
    }
  }

  // Future loadMySub() async {
  //   try {
  //     if (!Provider.of<AppUserInfo>(context, listen: false).isLogin) {
  //       return;
  //     }
  //     var response = await http.get(Api.comicMySub(
  //         Provider.of<AppUserInfo>(context, listen: false).loginInfo.uid));
  //     var jsonMap = jsonDecode(response.body);

  //     List items = jsonMap["data"]["data"];
  //     List<ComicHomeNewItem> _items =
  //         items.map((i) => ComicHomeNewItem.fromJson(i)).toList();
  //     if (_items.length != 0) {}
  //   } catch (e) {
  //     print(e);
  //   }
  // }
}
