import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dmzj/helper/utils.dart';
import 'package:flutter_dmzj/models/comic/comic_detail_model.dart';
import 'package:flutter_dmzj/views/download/download_models.dart';

class ComicChapterView extends StatefulWidget {
  final ComicDetail detail;
  final int comicId;
  final bool isSubscribe;
  final int historyChapter;
  final Function openReader;
  ComicChapterView(this.comicId, this.detail, this.historyChapter,
      {Key key, this.isSubscribe = false, this.openReader})
      : super(key: key);

  @override
  _ComicChapterViewState createState() => _ComicChapterViewState();
}

class _ComicChapterViewState extends State<ComicChapterView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<ChapterDownloadModel> _list = [];

  @override
  void initState() {
    super.initState();
    initLocalList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.detail.chapters != null && widget.detail.chapters.length != 0
        ? ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: ScrollPhysics(),
            itemCount: widget.detail.chapters.length,
            itemBuilder: (ctx, i) {
              var f = widget.detail.chapters[i];

              dataReverse(f);
              return Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                                f.title +
                                    "(共" +
                                    f.data.length.toString() +
                                    "话)",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              f.desc = !f.desc;
                              dataReverse(f);
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            child: Text(f.desc ? "排序 ↓" : "排序 ↑"),
                          ),
                        ),
                      ],
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      itemCount: f.data.length,
                      padding: EdgeInsets.all(2),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              MediaQuery.of(context).size.width ~/ 120,
                          mainAxisSpacing: 8.0,
                          crossAxisSpacing: 8.0,
                          childAspectRatio: 6 / 2),
                      itemBuilder: (context, i) {
                        print(_list.length);
                        return OutlinedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                                    (states) {
                              if (_list.any((element) =>
                                  element.chapterId == f.data[i].chapter_id))
                                return Colors.green[200];
                              else
                                return Colors.transparent;
                            }),
                            side: MaterialStateProperty.resolveWith((states) {
                              return BorderSide(
                                  color: f.data[i].chapter_id ==
                                          widget.historyChapter
                                      ? Theme.of(context).accentColor
                                      : Colors.grey.withOpacity(0.4));
                            }),
                          ),
                          child: Text(
                            f.data[i].chapter_title,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: f.data[i].chapter_id ==
                                        widget.historyChapter
                                    ? Theme.of(context).accentColor
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color),
                          ),
                          onPressed: () {
                            Utils.openComicReader(
                                context,
                                widget.comicId,
                                widget.detail.title,
                                widget.isSubscribe,
                                f.data,
                                f.data[i]);
                          },
                        );
                      },
                    ),
                    SizedBox(height: 8)
                  ],
                ),
              );
            })
        : Container(
            padding: EdgeInsets.all(12),
            child: Center(
              child: Text("岂可修！竟然没有可以看的章节！"),
            ),
          );
  }

  void dataReverse(ComicDetailChapter f) {
    if (!f.desc) {
      f.data.sort((x, y) => x.chapter_order.compareTo(y.chapter_order));
    } else {
      f.data.sort((x, y) => y.chapter_order.compareTo(x.chapter_order));
    }
  }

  void openRead() async {
    if (widget.detail == null ||
        widget.detail.chapters == null ||
        widget.detail.chapters.length == 0 ||
        widget.detail.chapters[0].data.length == 0) {
      Utils.showSnackbar(context, "没有可以阅读的章节");
      return;
    }
    if (widget.historyChapter != 0) {
      ComicDetailChapterItem _item;
      ComicDetailChapter chpters;
      for (var item in widget.detail.chapters) {
        var first = item.data.firstWhere(
            (f) => f.chapter_id == widget.historyChapter,
            orElse: () => null);
        if (first != null) {
          chpters = item;
          _item = first;
        }
      }
      if (_item != null) {
        Utils.openComicReader(context, widget.comicId, widget.detail.title,
            widget.isSubscribe, chpters.data, _item);
        return;
      }
    }
    Utils.openComicReader(
        context,
        widget.comicId,
        widget.detail.title,
        widget.isSubscribe,
        widget.detail.chapters[0].data,
        widget.detail.chapters[0].data.last);
  }

  Future initLocalList() async {
    var list = await DownloadHelper.getChaptersInComic(widget.detail.id);
    list.forEach((element) {
      print('${element.chapterName} ${element.state}');
    });
    setState(() {
      _list = list;
    });
  }
}
