import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dmzj/helper/api.dart';
import 'package:flutter_dmzj/helper/config_helper.dart';
import 'package:flutter_dmzj/models/comic/comic_chapter_detail.dart';
import 'package:flutter_dmzj/models/comic/comic_detail_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

enum DownState { waiting, loading, downloading, pause, done, error }

class ComicDownloadModel {
  int comicId;
  String title;
  int localCount;
  DownState state = DownState.done;
  List<List<ChapterDownloadModel>> volumeList = [];

  ComicDownloadModel(this.comicId, this.title, this.localCount);

  bool addChapter(int volume, ChapterDownloadModel chapter) {
    if (volume >= volumeList.length) return false;
    volumeList[volume].add(chapter);
    return true;
  }
}

class ChapterDownloadModel extends ChangeNotifier {
  int comicId;
  int volume;
  int chapterId;
  String chapterName;
  DownState state = DownState.waiting;
  double progress = 0.0;

  ComicChapterDetail detail;

  ChapterDownloadModel(
      this.comicId, this.volume, this.chapterId, this.chapterName);

  void updateProgress(double p) {
    progress = p;
    notifyListeners();
  }

  void setState(DownState s) {
    state = s;
    notifyListeners();
  }

  Future loadPages() async {
    var api = Api.comicChapterDetail(this.comicId, this.chapterId);

    if (ConfigHelper.getComicWebApi()) {
      api = Api.comicWebChapterDetail(this.comicId, this.chapterId);
    }
    try {
      var response = await Dio().get(api);
      var jsonMap = jsonDecode(response.data);

      detail = ComicChapterDetail.fromJson(jsonMap);
      print('load done');
    } catch (e) {
      print(e);
      return;
    }
  }
}

class Downloader extends ChangeNotifier {
  Queue<ChapterDownloadModel> _waitingQueue = new Queue<ChapterDownloadModel>();
  int _poolCount = 5;
  int _syncFlag = 0;
  static String _downloadPath;
  static final Options options =
      Options(headers: {"Referer": "http://www.dmzj.com/"});

  Future initDirectory() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    _downloadPath = appDocDir.absolute.path + '/downloads';
    print(_downloadPath);
  }

  bool setPoolCount(int count) {
    if (count > 10 || count < 1) return false;
    _poolCount = count;
    return true;
  }

  void addToQueue(ChapterDownloadModel chapter) {
    _waitingQueue.add(chapter);
  }

  void deleteFromQueue(int chapterId) {
    var result =
        _waitingQueue.where((element) => element.chapterId == chapterId);
    if (result.isNotEmpty) {
      result.forEach((element) {
        element.setState(DownState.pause);
        _waitingQueue.remove(element);
      });
    }
  }

  Future downloadCover(int comicId, String coverUrl) async {
    var directory =
        await new Directory("$_downloadPath/$comicId").create(recursive: true);
    assert(await directory.exists() == true);
    //输出绝对路径
    print("Path: ${directory.absolute.path}");
    await Dio().download(coverUrl, "$_downloadPath/$comicId/cover.jpg",
        options: options);
  }

  void startDownload() {
    int i = 0;
    while (_syncFlag > _poolCount && i < _waitingQueue.length) {
      if (_waitingQueue.elementAt(i).state == DownState.downloading) {
        _waitingQueue.elementAt(i).setState(DownState.waiting);
      }
      i++;
    }
    i = 0;
    while (_syncFlag < _poolCount && i < _waitingQueue.length) {
      if (_waitingQueue.elementAt(i).state == DownState.waiting) {
        downloadProccess(_waitingQueue.elementAt(i));
      }
      i++;
    }
  }

  Future downloadProccess(ChapterDownloadModel chapter) async {
    _syncFlag++;
    var directory = await new Directory(
            "$_downloadPath/${chapter.comicId}/${chapter.chapterId}")
        .create(recursive: true);
    assert(await directory.exists() == true);
    //输出绝对路径
    print("Path: ${directory.absolute.path}");

    chapter.setState(DownState.loading);

    await chapter.loadPages();

    chapter.setState(DownState.downloading);

    int length = chapter.detail.page_url.length;
    for (int i = 0; i < length; i++) {
      if (chapter.state != DownState.downloading) {
        _syncFlag--;
        return;
      }
      await Dio()
          .download(chapter.detail.page_url[i], "${directory.path}/$i.jpg",
              options: options)
          .whenComplete(() {
        print('${chapter.chapterId} $i done');
        chapter.updateProgress(i / length);
      });
    }

    chapter.setState(DownState.done);

    print('${chapter.chapterId} done');
  }
}
