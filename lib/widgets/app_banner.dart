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
              onPageChanged: (i, e) {
                setState(() {
                  currentBannerIndex = i;
                });
              },
              aspectRatio: 7.5 / 4,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.items.map<Widget>((index) {
              return InkWell(
                child: Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentBannerIndex == widget.items.indexOf(index)
                          ? Theme.of(context).accentColor
                          : Color.fromRGBO(0, 0, 0, 0.4)),
                ),
              );
            }).toList(),
          )
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
