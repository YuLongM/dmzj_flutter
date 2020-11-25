import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dmzj/helper/utils.dart';
import 'package:flutter_dmzj/provider/download_list_provider.dart';
import 'package:provider/provider.dart';

class DownloadListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('下载列队'),
      ),
      body: ListView.builder(
          itemCount: Provider.of<DownloadList>(context).downloadList.length,
          itemBuilder: (context, index) {
            DownloadItem item =
                Provider.of<DownloadList>(context, listen: false)
                    .downloadList[index];
            return Utils.createDetailWidget(
                item.itemId, 1, item.coverUrl, item.itemName, context);
          }),
    );
  }
}
