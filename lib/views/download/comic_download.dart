import 'package:flutter/material.dart';
import 'package:flutter_dmzj/helper/utils.dart';
import 'package:flutter_dmzj/models/comic/comic_detail_model.dart';
import 'package:flutter_dmzj/views/download/download_models.dart';
import 'package:flutter_dmzj/widgets/error_pages.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class ComicDownloadPage extends StatefulWidget {
  final ComicDetail detail;
  ComicDownloadPage(this.detail, {Key key}) : super(key: key);

  @override
  _ComicDownloadPageState createState() => _ComicDownloadPageState();
}

class _ComicDownloadPageState extends State<ComicDownloadPage> {
  bool _selectAll = false;
  List<ComicDetailChapterItem> _ls = [];
  Downloader _downloader;
  List<bool> downloadingState = [];
  List<bool> deleteState = [];
  bool _deleteMode = false;
  ViewState state = ViewState.loading;

  @override
  void initState() {
    super.initState();
    _downloader = Provider.of<Downloader>(context, listen: false);
    initList().whenComplete(() {
      setState(() {
        state = ViewState.idle;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case ViewState.loading:
        return loadingPage(context);
      case ViewState.idle:
        return idlePage();
      default:
        return failPage(context, initList);
    }
  }

  Widget idlePage() {
    return Scaffold(
      appBar: AppBar(
        title: Text('选择章节'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                _deleteMode = !_deleteMode;
              });
            },
          ),
          IconButton(
              icon: Icon(Icons.select_all),
              onPressed: () {
                _selectAll = !_selectAll;
                if (_deleteMode) {
                  for (int i = 0; i < _ls.length; i++) {
                    if (_ls[i].downloadState == 2) {
                      setState(() {
                        deleteState[i] = _selectAll;
                      });
                    }
                  }
                } else {
                  for (var item in _ls.where((x) => x.downloadState == 0)) {
                    setState(() {
                      item.selected = _selectAll;
                    });
                  }
                }
              })
        ],
      ),
      body: ListView.builder(
          itemCount: _ls.length,
          itemBuilder: (ctx, i) {
            // var item = Provider.of<Downloader>(context).waitingQueue.firstWhere(
            //     (element) => element.chapterId == _ls[i].chapter_id,
            //     orElse: () => null);
            // if (item != null) {
            //   if (item.state == DownState.done) {
            //     _ls[i].downloadState = 2;
            //   }
            // }
            return CheckboxListTile(
              value: _deleteMode ? deleteState[i] : _ls[i].selected,
              title: Text(
                _ls[i].volume_name + ' - ' + _ls[i].chapter_title,
                style: TextStyle(
                    color: _deleteMode
                        ? _ls[i].downloadState == 0
                            ? Theme.of(context).disabledColor
                            : Theme.of(context).textTheme.bodyText1.color
                        : _ls[i].downloadState == 0
                            ? Theme.of(context).textTheme.bodyText1.color
                            : Theme.of(context).disabledColor),
              ),
              subtitle: getDownStateWiget(i),
              onChanged: (e) {
                setState(() {
                  if (_deleteMode) {
                    if (_ls[i].downloadState != 0) {
                      deleteState[i] = e;
                    }
                  } else {
                    if (_ls[i].downloadState == 0) {
                      _ls[i].selected = e;
                    }
                  }
                });
              },
            );
          }),
      floatingActionButton: AnimatedCrossFade(
        firstChild: FloatingActionButton(
          heroTag: 'ComicDownload',
          child: Icon(Icons.file_download),
          onPressed: () async {
            Fluttertoast.showToast(msg: '添加到列队');
            _downloader.downloadMeta(widget.detail.id);

            for (int i = 0; i < _ls.length; i++) {
              if (_ls[i].selected) {
                ChapterDownloadModel chapter = ChapterDownloadModel(
                    widget.detail.id,
                    widget.detail.title,
                    _ls[i].chapter_id,
                    _ls[i].chapter_title,
                    _ls[i].volume_name);
                _downloader.addToQueue(chapter);
                _ls[i].selected = false;
                _ls[i].downloadState = 1;
              }
            }

            setState(() {
              _ls[0].selected = false;
            });

            print('加入下载列队完成');
            _downloader.startDownload();
          },
        ),
        secondChild: FloatingActionButton(
          heroTag: 'ComicDelete',
          backgroundColor: Theme.of(context).errorColor,
          child: Icon(
            Icons.delete,
          ),
          onPressed: () async {
            if (await Utils.showAlertDialogAsync(
              context,
              Text('删除下载'),
              Text('确认删除这些项吗'),
            )) {
              int success = 0;
              int error = 0;
              for (int i = 0; i < _ls.length; i++) {
                if (deleteState[i]) {
                  if (await _downloader.deleteFromQueue(_ls[i].chapter_id)) {
                    success += 1;
                    setState(() {
                      _ls[i].downloadState = 0;
                      deleteState[i] = false;
                    });
                  } else
                    error += 1;
                }
              }
              Fluttertoast.showToast(msg: '成功 $success 个, 失败 $error 个');
            }
          },
        ),
        crossFadeState:
            _deleteMode ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: Duration(milliseconds: 200),
      ),
    );
  }

  Widget getDownStateWiget(int index) {
    switch (_ls[index].downloadState) {
      case 0:
        return Text('未下载');
      case 1:
        {
          var item = Provider.of<Downloader>(context).waitingQueue.firstWhere(
              (element) => element.chapterId == _ls[index].chapter_id,
              orElse: () => null);
          if (item != null) {
            return LinearProgressIndicator(value: item.progress);
          } else {
            _ls[index].downloadState = 2;
            return Text('已下载');
          }
        }
        break;
      case 2:
        return Text('已下载');
      default:
        return Text('出错');
    }
  }

  Future<void> initList() async {
    _ls = [];
    List<ChapterDownloadModel> downloadList =
        await DownloadHelper.getChaptersInComic(widget.detail.id);
    for (var item in widget.detail.chapters) {
      for (var item2 in item.data) {
        item2.volume_name = item.title;
        ChapterDownloadModel temp = downloadList.firstWhere(
            (element) => element.chapterId == item2.chapter_id,
            orElse: () => null);
        if (temp != null) {
          downloadingState.add(true);
          if (temp.state == DownState.done) {
            item2.downloadState = 2;
          } else {
            item2.downloadState = 1;
          }
        } else
          downloadingState.add(false);

        deleteState.add(false);
      }
      _ls.addAll(item.data);
    }
  }
}
