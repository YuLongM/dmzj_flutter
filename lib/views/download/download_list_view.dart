import 'package:flutter/material.dart';
import 'package:flutter_dmzj/helper/utils.dart';
import 'package:flutter_dmzj/models/comic/comic_detail_model.dart';
import 'package:flutter_dmzj/views/download/download_models.dart';
import 'package:flutter_dmzj/widgets/error_pages.dart';
import 'package:flutter_dmzj/widgets/icon_text_button.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class DownloadList extends StatefulWidget {
  DownloadList({Key key}) : super(key: key);

  @override
  _DownloadListState createState() => _DownloadListState();
}

class _DownloadListState extends State<DownloadList> {
  List<bool> downloadingState = [];
  List<bool> deleteState = [];
  // ViewState state = ViewState.loading;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // switch (state) {
    //   case ViewState.loading:
    //     return loadingPage(context);
    //   case ViewState.idle:
    //     return idlePage();
    //   default:
    //     return failPage(context, null);
    // }
    return idlePage();
  }

  Widget idlePage() {
    return Scaffold(
      appBar: AppBar(
        title: Text('下载队列'),
        actions: <Widget>[],
      ),
      body: Provider.of<Downloader>(context).waitingQueue.length == 0
          ? emptyPage(context, null)
          : ListView.builder(
              itemCount: Provider.of<Downloader>(context).waitingQueue.length,
              itemBuilder: (ctx, i) => ListTile(
                title: Text(
                  Provider.of<Downloader>(context).waitingQueue[i].volume +
                      ' - ' +
                      Provider.of<Downloader>(context)
                          .waitingQueue[i]
                          .chapterName,
                ),
                subtitle:
                    Provider.of<Downloader>(context).waitingQueue[i].state ==
                            DownState.downloading
                        ? LinearProgressIndicator(
                            value: Provider.of<Downloader>(context)
                                .waitingQueue[i]
                                .progress,
                          )
                        : Text(Provider.of<Downloader>(context)
                            .waitingQueue[i]
                            .state
                            .toString()),
                leading: IconButton(
                  icon: AnimatedCrossFade(
                      duration: Duration(milliseconds: 200),
                      firstChild: Icon(Icons.pause),
                      secondChild: Icon(Icons.play_arrow),
                      crossFadeState: Provider.of<Downloader>(context)
                                  .waitingQueue[i]
                                  .state !=
                              DownState.pause
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond),
                  onPressed: () {
                    setState(() {
                      if (Provider.of<Downloader>(context, listen: false)
                              .waitingQueue[i]
                              .state ==
                          DownState.downloading)
                        Provider.of<Downloader>(context, listen: false)
                            .waitingQueue[i]
                            .setState(DownState.pause);
                      else {
                        Provider.of<Downloader>(context, listen: false)
                            .waitingQueue[i]
                            .setState(DownState.waiting);
                        Provider.of<Downloader>(context, listen: false)
                            .startDownload();
                      }
                    });
                  },
                ),
                trailing: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () async {
                      if (await Provider.of<Downloader>(context, listen: false)
                          .deleteFromQueue(
                              Provider.of<Downloader>(context, listen: false)
                                  .waitingQueue[i]
                                  .chapterId))
                        Fluttertoast.showToast(msg: '删除成功');
                      else
                        Fluttertoast.showToast(msg: '删除失败');
                      setState(() {});
                    }),
              ),
            ),
      bottomNavigationBar: Container(
        height: kToolbarHeight,
        child: Row(
          children: [
            IconTextButton(Icon(Icons.download_rounded), '全部开始',
                Provider.of<Downloader>(context, listen: false).resumeAll),
            IconTextButton(Icon(Icons.pause), '全部暂停',
                Provider.of<Downloader>(context, listen: false).pauseAll),
            Expanded(
              child: FlatButton.icon(
                height: kToolbarHeight,
                onPressed:
                    Provider.of<Downloader>(context, listen: false).deleteAll,
                icon: Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                ),
                label: Text('全部取消'),
                textColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
