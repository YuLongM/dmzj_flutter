import 'package:flutter/foundation.dart';

class ListChapterItem {
  int chapterId;
  String chapterName;
  int chapterOrder;
  bool downloaded = false;
  ListChapterItem(this.chapterId, this.chapterName, this.chapterOrder);
}

class DownloadItem {
  int _itemId;
  int get itemId => _itemId;
  String _itemName;
  String get itemName => _itemName;
  String _coverUrl;
  String get coverUrl => _coverUrl;
  List<ListChapterItem> _listChapters = [];
  List<ListChapterItem> get listChapters => _listChapters;

  DownloadItem(int itemId, String itemName, String coverUrl) {
    _itemId = itemId;
    _itemName = itemName;
    _coverUrl = coverUrl;
  }

  void insertChapter(ListChapterItem item) {
    if (_listChapters.contains(item)) return;
    _listChapters.add(item);
  }

  void updateData(DownloadItem newItem, {bool isDelete = false}) {
    if (newItem.itemId != _itemId) return;
    _itemName = newItem.itemName;
    _coverUrl = newItem.coverUrl;
    if (isDelete) {
      for (var e in newItem.listChapters) {
        insertChapter(e);
      }
    } else {
      for (var e in newItem.listChapters) {
        deleteChapter(e);
      }
    }
    _listChapters.sort((a, b) => a.chapterOrder.compareTo(b.chapterOrder));
    return;
  }

  void deleteChapter(ListChapterItem item) {
    if (!_listChapters.contains(item)) return;
    _listChapters
      ..removeWhere((element) => element.chapterId == item.chapterId);
    return;
  }

  void sortList() {
    _listChapters.sort((a, b) => a.chapterOrder.compareTo(b.chapterOrder));
    return;
  }

  List<ListChapterItem> getDownloaded() {
    return _listChapters.where((item) => item.downloaded);
  }
}

class DownloadList extends ChangeNotifier {
  static List<DownloadItem> _downloadQueue = [];
  List<DownloadItem> get downloadList => _downloadQueue;

  void insertDownload(DownloadItem item) {
    int i =
        _downloadQueue.indexWhere((element) => element.itemId == item.itemId);
    print(i);
    switch (i) {
      case -1:
        _downloadQueue.add(item);
        break;
      default:
        _downloadQueue[i].updateData(item);
    }
    notifyListeners();
  }

  void deleteDownload(DownloadItem item) {
    int i =
        _downloadQueue.indexWhere((element) => element.itemId == item.itemId);
    switch (i) {
      case -1:
        break;
      default:
        _downloadQueue[i].updateData(item, isDelete: true);
    }
    notifyListeners();
  }
}
