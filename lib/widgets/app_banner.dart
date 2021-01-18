import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dmzj/helper/utils.dart';

class AppBanner extends StatefulWidget {
  final List<Widget> items;

  AppBanner({Key key, this.items}) : super(key: key);

  _AppBannerState createState() => _AppBannerState();
}

class _AppBannerState extends State<AppBanner> {
  int currentBannerIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      constraints: BoxConstraints(maxWidth: 600),
      child: Column(
        children: <Widget>[
          CarouselSlider(
            options: CarouselOptions(
              aspectRatio: 21 / 9,
              viewportFraction: 0.9,
            ),
            items: widget.items.length != 0
                ? widget.items
                : [
                    Center(
                      child: CircularProgressIndicator(),
                    )
                  ],
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              FlatButton.icon(
                onPressed: () {},
                icon: Icon(Icons.bar_chart),
                label: Text('排行'),
              ),
              FlatButton.icon(
                onPressed: () {},
                icon: Icon(Icons.update),
                label: Text('更新'),
              ),
              FlatButton.icon(
                onPressed: () {},
                icon: Icon(Icons.bookmark_border),
                label: Text('专题'),
              ),
              FlatButton.icon(
                onPressed: () {},
                icon: Icon(Icons.view_carousel),
                label: Text('分类'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BannerImageItem extends StatelessWidget {
  final String pic;
  final Function onTaped;
  final String title;
  BannerImageItem({Key key, this.pic, this.onTaped, this.title = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: InkWell(
          onTap: () {},
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image(
                  image: Utils.createCachedImageProvider(pic),
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.black87,
                      Colors.transparent,
                    ], begin: Alignment.bottomCenter, end: Alignment.center),
                  ),
                ),
                Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(title,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
