import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dmzj/database/comic_down.dart';
import 'package:flutter_dmzj/helper/api.dart';
import 'package:flutter_dmzj/helper/config_helper.dart';
import 'package:flutter_dmzj/models/comic/comic_chapter_detail.dart';
import 'package:flutter_dmzj/models/comic/comic_detail_model.dart';
import 'package:flutter_dmzj/models/comic/comic_specia_datail_model.dart';
import 'package:flutter_dmzj/models/download/comic_download_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

enum DownState { waiting, loading, downloading, pause, done, error }

final String comicDownloadTableName = 'ComicDownload';
final String comicDownloadColumnChapterId = 'ChapterID';
final String comicDownloadColumnChapterName = 'ChapterName';
final String comicDownloadColumnComicId = 'ComicID';
final String comicDownloadColumnComicName = 'ComicName';
final String comicDownloadColumnStatus = 'Status';
final String comicDownloadColumnVolume = 'Volume';

class DownloadHelper {
  static Database db;
  static Future<bool> addDownload(ChapterDownloadModel chapter) async {
    try {
      await db.insert(comicDownloadTableName, chapter.toMap());
      return true;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> deleteDownload(int chapterId) async {
    try {
      await db.delete(comicDownloadTableName,
          where: '$comicDownloadColumnChapterId = ?', whereArgs: [chapterId]);
      return true;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> updateDownload(ChapterDownloadModel chapter) async {
    try {
      await db.update(comicDownloadTableName, chapter.toMap(),
          where: '$comicDownloadColumnChapterId = ?',
          whereArgs: [chapter.chapterId]);
      return true;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }

  static Future<ChapterDownloadModel> getDownload(int chapterId) async {
    List<Map> maps = await db.query(comicDownloadTableName,
        columns: [
          comicDownloadColumnChapterId,
          comicDownloadColumnChapterName,
          comicDownloadColumnComicId,
          comicDownloadColumnComicName,
          comicDownloadColumnStatus,
          comicDownloadColumnVolume,
        ],
        where: '$comicDownloadColumnChapterId = ?',
        whereArgs: [chapterId]);
    if (maps.length > 0) {
      return ChapterDownloadModel.fromMap(maps.first);
    }
    return null;
  }

  static Future<List<ChapterDownloadModel>> getAllDownloads() async {
    List<ChapterDownloadModel> maps = (await db.query(comicDownloadTableName,
            where: '$comicDownloadColumnStatus != ?',
            whereArgs: [DownState.done.index]))
        .map<ChapterDownloadModel>((x) => ChapterDownloadModel.fromMap(x))
        .toList();
    return maps;
  }

  static Future<List<ComicDownloadModel>> getAllComics() async {
    List<ComicDownloadModel> maps = (await db.query(comicDownloadTableName,
            columns: [comicDownloadColumnComicID, comicDownloadColumnComicName],
            groupBy: comicDownloadColumnComicId))
        .map<ComicDownloadModel>((x) => ComicDownloadModel.fromMap(x))
        .toList();
    return maps;
  }

  static Future<List<ChapterDownloadModel>> getChaptersInComic(
      int comicId) async {
    List<ChapterDownloadModel> list = (await db.query(comicDownloadTableName,
            where: '$comicDownloadColumnComicId == ?', whereArgs: [comicId]))
        .map<ChapterDownloadModel>((x) => ChapterDownloadModel.fromMap(x))
        .toList();
    return list;
  }
}

class ComicDownloadModel {
  int comicId;
  String title;

  ComicDownloadModel.fromMap(Map<String, dynamic> map) {
    comicId = map[comicDownloadColumnComicId];
    title = map[comicDownloadColumnComicName];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      comicDownloadColumnComicId: comicId,
      comicDownloadColumnComicName: title,
    };
    return map;
  }
}

class ChapterDownloadModel extends ChangeNotifier {
  int comicId;
  String comicName;
  String volume;
  int chapterId;
  String chapterName;
  DownState state = DownState.waiting;
  double progress = 0.0;

  ComicChapterDetail detail;

  ChapterDownloadModel(
    this.comicId,
    this.comicName,
    this.chapterId,
    this.chapterName,
    this.volume,
  );

  void updateProgress(double p) {
    progress = p;
    notifyListeners();
  }

  void setState(DownState s) {
    state = s;
    DownloadHelper.updateDownload(this);
    notifyListeners();
  }

  Future loadPages() async {
    var api = Api.comicChapterDetail(this.comicId, this.chapterId);

    if (ConfigHelper.getComicWebApi()) {
      api = Api.comicWebChapterDetail(this.comicId, this.chapterId);
    }
    try {
      var response = await Dio().get(api);
      var jsonMap = jsonDecode(response.toString());

      detail = ComicChapterDetail.fromJson(jsonMap);
      print('load done');
    } catch (e) {
      print(e);
      return;
    }
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      comicDownloadColumnChapterId: chapterId,
      comicDownloadColumnChapterName: chapterName,
      comicDownloadColumnComicId: comicId,
      comicDownloadColumnComicName: comicName,
      comicDownloadColumnVolume: volume,
      comicDownloadColumnStatus: state.index,
    };
    return map;
  }

  ChapterDownloadModel.fromMap(Map<String, dynamic> map) {
    comicId = map[comicDownloadColumnComicId];
    comicName = map[comicDownloadColumnComicName];
    chapterId = map[comicDownloadColumnChapterId];
    chapterName = map[comicDownloadColumnChapterName];
    volume = map[comicDownloadColumnVolume];
    state = DownState.values[map[comicDownloadColumnStatus]];
  }
}

class Downloader extends ChangeNotifier {
  Queue<ChapterDownloadModel> _waitingQueue = new Queue<ChapterDownloadModel>();
  int _poolCount = 2;
  int _syncFlag = 0;
  static String _downloadPath;
  static final Options options =
      Options(headers: {"Referer": "http://www.dmzj.com/"});

  Downloader() {
    initDirectory();
  }

  Future initQueue() async {
    _waitingQueue.addAll(await DownloadHelper.getAllDownloads());
    print('retreive queue ${_waitingQueue.length} items');
  }

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
    DownloadHelper.addDownload(chapter);
  }

  Future<bool> deleteFromQueue(int chapterId) async {
    try {
      var result =
          _waitingQueue.where((element) => element.chapterId == chapterId);
      if (result.isNotEmpty) {
        result.forEach((element) {
          element.setState(DownState.pause);
          _waitingQueue.remove(element);
          DownloadHelper.deleteDownload(element.chapterId);
        });
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> downloadMeta(int comicId) async {
    try {
      var directory = await new Directory("$_downloadPath/$comicId")
          .create(recursive: true);
      assert(await directory.exists() == true);
      //输出绝对路径
      print("Path: ${directory.absolute.path}");

      var response = await Dio().get(Api.comicDetail(comicId));

      if (response.statusCode == 200) {
        var jsonMap = jsonDecode(response.toString());

        File metaFile = File('$_downloadPath/$comicId/metadata');

        metaFile.writeAsStringSync(response.toString());

        await Dio().download(
            jsonMap['cover'], "$_downloadPath/$comicId/cover.jpg",
            options: options);
        return true;
      }

      return false;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }

  void startDownload() {
    int i = _waitingQueue.length - 1;
    while (_syncFlag > _poolCount && i > 0) {
      if (_waitingQueue.elementAt(i).state == DownState.downloading) {
        _waitingQueue.elementAt(i).setState(DownState.waiting);
      }
      i--;
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
      String index = '';
      if (i < 10) {
        index = '000' + i.toString();
      } else if (i < 100) {
        index = '00' + i.toString();
      } else if (i < 1000) {
        index = '0' + i.toString();
      }
      await Dio()
          .download(chapter.detail.page_url[i], "${directory.path}/$index.jpg",
              options: options)
          .whenComplete(() {
        print('${chapter.chapterId} $i done');
        chapter.updateProgress(i / length);
      });
    }

    chapter.setState(DownState.done);

    print('${chapter.chapterId} done');

    _waitingQueue.remove(chapter);

    _syncFlag--;

    startDownload();
  }
}
