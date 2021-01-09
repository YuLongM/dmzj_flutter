import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_dmzj/helper/api.dart';
import 'package:flutter_dmzj/helper/config_helper.dart';
import 'package:flutter_dmzj/helper/user_helper.dart';
import 'package:flutter_dmzj/provider/user_info_provider.dart';
import 'package:flutter_dmzj/helper/utils.dart';
import 'package:flutter_dmzj/models/novel/novel_detail_model.dart';
import 'package:flutter_dmzj/models/novel/novel_volume_item.dart';
import 'package:flutter_dmzj/views/other/comment_widget.dart';
import 'package:flutter_dmzj/widgets/error_pages.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class NovelDetailPage extends StatefulWidget {
  final int novelId;
  final String coverUrl;
  NovelDetailPage(this.novelId, this.coverUrl, {Key key}) : super(key: key);

  @override
  _NovelDetailPageState createState() => _NovelDetailPageState();
}

class _NovelDetailPageState extends State<NovelDetailPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  double detailExpandHeight = 150 + kToolbarHeight + 24;

  @override
  bool get wantKeepAlive => true;
  TabController _tabController;
  int historyChapter = 0;
  String _coverUrl;
  ViewState _state = ViewState.loading;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
    _coverUrl = widget.coverUrl ?? "";
    loadData();
    updateHistory();
  }

  void updateHistory() {
    var his = ConfigHelper.getNovelHistory(widget.novelId);
    setState(() {
      historyChapter = his;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double getSafebar() {
    return MediaQuery.of(context).padding.top;
  }

  NovelDetail _detail;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: createPage(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
          heroTag: "comic_float",
          child: Icon(Icons.play_arrow),
          onPressed: openRead),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          children: [
            TextButton(
              child: Text("章节"),
              onPressed: _state == ViewState.fail
                  ? null
                  : () {
                      showCupertinoModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Material(
                              child: createVolume(),
                            );
                          });
                    },
            ),
            TextButton(
              child: Text("评论"),
              onPressed: _state == ViewState.fail
                  ? null
                  : () {
                      showCupertinoModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Material(
                              child: CommentWidget(1, widget.novelId),
                            );
                          });
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget createPage() {
    switch (_state) {
      case ViewState.loading:
        return loadingPage(context);
      case ViewState.noCopyright:
        return noCopyrightPage(context);
      case ViewState.fail:
        return failPage(context, loadData);
      case ViewState.idle:
        return idlePage();
      default:
        return failPage(context, loadData);
    }
  }

  Widget idlePage() {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
              pinned: true,
              expandedHeight: detailExpandHeight,
              automaticallyImplyLeading: true,
              title: Text(_detail.name),
              actions: <Widget>[
                Provider.of<AppUserInfoProvider>(context).isLogin &&
                        _isSubscribe
                    ? IconButton(
                        icon: Icon(Icons.favorite),
                        onPressed: () async {
                          var result = await UserHelper.novelSubscribe(
                              widget.novelId,
                              cancel: true);
                          if (result) {
                            setState(() {
                              _isSubscribe = false;
                            });
                          }
                        })
                    : IconButton(
                        icon: Icon(Icons.favorite_border),
                        onPressed: () async {
                          var result =
                              await UserHelper.novelSubscribe(widget.novelId);
                          if (result) {
                            setState(() {
                              _isSubscribe = true;
                            });
                          }
                        }),
                IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () => Share.share(
                        "${_detail.name}\r\nhttp://q.dmzj.com/${widget.novelId}/index.shtml")),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Stack(
                  fit: StackFit.loose,
                  children: [
                    ClipRect(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: detailExpandHeight + getSafebar(),
                        foregroundDecoration: BoxDecoration(
                            color:
                                Theme.of(context).shadowColor.withAlpha(100)),
                        child: ImageFiltered(
                          imageFilter:
                              ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: _coverUrl.isNotEmpty
                              ? Utils.createCacheImage(
                                  _coverUrl,
                                  MediaQuery.of(context).size.width,
                                  detailExpandHeight,
                                  fit: BoxFit.cover)
                              : Container(),
                        ),
                      ),
                    ),
                    Positioned(
                        top: getSafebar() + kToolbarHeight,
                        child: Container(
                            height: 150,
                            width: MediaQuery.of(context).size.width,
                            child: createHeader())),
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
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverToBoxAdapter(
              child: createDetail(),
            )
          ],
        );
      }),
    );
  }

  Widget createHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 12,
        ),
        Utils.createCover(_coverUrl, 100, 0.75, context),
        SizedBox(
          width: 24,
        ),
        Expanded(
          child: (_detail != null)
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _detail.name,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "作者:" + _detail.authors,
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "点击:" + _detail.hot_hits.toString(),
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "订阅:" + _detail.subscribe_num.toString(),
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "状态:" + _detail.status,
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "最后更新:" +
                          DateUtil.formatDate(
                              DateTime.fromMillisecondsSinceEpoch(
                                  _detail.last_update_time * 1000),
                              format: "yyyy-MM-dd"),
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                )
              : SizedBox(
                  width: 12,
                ),
        )
      ],
    );
  }

  Widget createDetail() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            color: Theme.of(context).cardColor,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("简介", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                  _detail.introduction,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget createVolume() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text('章节'),
        ),
        volumes != null && volumes.length != 0
            ? SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    var f = volumes[i];
                    var his = f.chapters.firstWhere(
                        (x) => x.chapter_id == historyChapter,
                        orElse: () => null);
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Container(
                        color: Theme.of(context).cardColor,
                        child: ExpansionTile(
                          initiallyExpanded: his != null,
                          title: Text(f.volume_name),
                          subtitle: his != null
                              ? Text("上次看到:" + his.chapter_name)
                              : null,
                          children: f.chapters.map((item) {
                            return InkWell(
                              onTap: () async {
                                await Utils.openNovelReader(
                                    context, widget.novelId, volumes, item,
                                    novelTitle: _detail.name,
                                    isSubscribe: _isSubscribe);
                                updateHistory();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border(
                                      top: BorderSide(
                                          color: Colors.grey.withOpacity(0.1))),
                                ),
                                child: Text(
                                  item.chapter_name,
                                  style: TextStyle(
                                      color: item.chapter_id == historyChapter
                                          ? Theme.of(context).accentColor
                                          : Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              .color),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                  childCount: volumes.length,
                ),
              )
            : SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text("岂可修！竟然没有章节！"),
                  ),
                ),
              )
      ],
    );
  }

  void openRead() async {
    //Fluttertoast.showToast(msg: '没写完');

    if (volumes == null || volumes == null || volumes[0].chapters.length == 0) {
      Fluttertoast.showToast(msg: '没有可读的章节');
      return;
    }

    if (historyChapter != 0) {
      NovelVolumeChapterItem chapterItem;
      for (var item in volumes) {
        var first = item.chapters.firstWhere(
            (f) => f.chapter_id == historyChapter,
            orElse: () => null);
        if (first != null) {
          chapterItem = first;
        }
      }
      if (chapterItem != null) {
        await Utils.openNovelReader(
            context, widget.novelId, volumes, chapterItem,
            novelTitle: _detail.name, isSubscribe: _isSubscribe);
        updateHistory();
        return;
      }
    } else {
      await Utils.openNovelReader(
          context, widget.novelId, volumes, volumes[0].chapters[0],
          novelTitle: _detail.name, isSubscribe: _isSubscribe);
      updateHistory();
    }
  }

  String tagsToString(List<String> items) {
    var str = "";
    for (var item in items) {
      str += item + " ";
    }
    return str;
  }

  DefaultCacheManager _cacheManager = DefaultCacheManager();
  bool _isSubscribe = false;
  List<NovelVolumeItem> volumes = [];
  Future loadData() async {
    setState(() {
      _state = ViewState.loading;
    });
    Future.wait([
      loadDetail(),
      loadVolumes(),
      checkSubscribe(),
    ]).then((value) {
      if (value.any((element) => element == ViewState.fail)) {
        setState(() {
          _state = ViewState.idle;
        });
      }
      setState(() {
        _state = value[0];
      });
    }).catchError((e) {
      print(e);
      setState(() {
        _state = ViewState.fail;
      });
    });
  }

  Future<ViewState> loadDetail() async {
    try {
      Uint8List responseBody;
      var api = Api.novelDetail(widget.novelId);
      try {
        var response = await http.get(api);
        responseBody = response.bodyBytes;
      } catch (e) {
        var file = await _cacheManager.getFileFromCache(api);
        if (file != null) {
          responseBody = await file.file.readAsBytes();
        }
      }
      var responseStr = utf8.decode(responseBody);
      var jsonMap = jsonDecode(responseStr);

      NovelDetail detail = NovelDetail.fromJson(jsonMap);
      if (detail.name == null || detail.name == "") {
        return ViewState.fail;
      }
      await _cacheManager.putFile(api, responseBody);
      print(detail.cover);

      _coverUrl = detail.cover;
      _detail = detail;
      return ViewState.idle;
    } catch (e) {
      print(e);
      return ViewState.fail;
    }
  }

  Future<ViewState> loadVolumes() async {
    try {
      Uint8List responseBody;
      var api = Api.novelVolumeDetail(widget.novelId);
      try {
        var response = await http.get(api);
        responseBody = response.bodyBytes;
      } catch (e) {
        var file = await _cacheManager.getFileFromCache(api);
        if (file != null) {
          responseBody = await file.file.readAsBytes();
        }
      }
      var responseStr = utf8.decode(responseBody);
      List jsonMap = jsonDecode(responseStr);

      List<NovelVolumeItem> detail =
          jsonMap.map((f) => NovelVolumeItem.fromJson(f)).toList();
      if (detail != null) {
        await _cacheManager.putFile(api, responseBody);
        volumes = detail;
      }
      return ViewState.idle;
    } catch (e) {
      print(e);
      return ViewState.fail;
    }
  }

  Future<ViewState> checkSubscribe() async {
    try {
      if (!ConfigHelper.getUserIsLogined() ?? false) {
        return ViewState.idle;
      }
      var response = await http.get(Api.novelCheckSubscribe(
          widget.novelId,
          Provider.of<AppUserInfoProvider>(context, listen: false)
              .loginInfo
              .uid));
      var jsonMap = jsonDecode(response.body);

      _isSubscribe = jsonMap["code"] == 0;
      return ViewState.idle;
    } catch (e) {
      print(e);
      return ViewState.fail;
    }
  }
}
