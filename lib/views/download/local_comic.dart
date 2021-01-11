import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dmzj/helper/utils.dart';
import 'package:flutter_dmzj/models/comic/comic_detail_model.dart';
import 'package:flutter_dmzj/widgets/error_pages.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:path_provider/path_provider.dart';

import 'download_models.dart';

class LocalComicPage extends StatefulWidget {
  LocalComicPage({Key key}) : super(key: key);

  @override
  _LocalComicPageState createState() => _LocalComicPageState();
}

class _LocalComicPageState extends State<LocalComicPage> {
  String downloadPath = '';
  List<ComicDetail> _list = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _loading
          ? loadingPage(context)
          : _list.length == 0
              ? emptyPage(context, loadData)
              : EasyRefresh(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return Utils.createDetailWidget(
                          _list[index].id,
                          1,
                          '$downloadPath/${_list[index].id}/cover.jpg',
                          _list[index].title,
                          context,
                          isLocal: true);
                    },
                    itemCount: _list.length,
                  ),
                ),
    );
  }

  Future loadData() async {
    await initDir();
    List<ComicDownloadModel> comicList = await DownloadHelper.getAllComics();
    List<ChapterDownloadModel> chapterList =
        await DownloadHelper.getAllDownloads();
    print(chapterList.length);
    await loadDetail(comicList);
    setState(() {
      _loading = false;
    });
  }

  Future initDir() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory downloadDir = Directory(appDocDir.path + '/downloads');
    assert(await downloadDir.exists() == true);
    downloadPath = downloadDir.path;
    print(downloadPath);
    // downloadDir
    //     .list(recursive: false)
    //     .toList()
    //     .then((value) => value.forEach((item) async {
    //           int id = int.parse(getDirName(item.path));
    //           print(id);
    //           await loadDetail(id);
    //         }));
  }

  Future loadDetail(List<ComicDownloadModel> comicList) async {
    comicList.forEach((element) {
      File metaFile = File('$downloadPath/${element.comicId}/metadata');
      var jsonMap = jsonDecode(metaFile.readAsStringSync());
      ComicDetail detail = ComicDetail.fromJson(jsonMap);
      _list.add(detail);
    });
  }

  String getDirName(String dir) {
    return dir.substring(dir.lastIndexOf('/') + 1);
  }
}
