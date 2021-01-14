import 'dart:ui';

import 'package:flutter/material.dart';

class CollapseHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget avatar;
  final double maxHeight;
  final double minHeight;
  final _avatarAlignTween =
      AlignmentTween(begin: Alignment.center, end: Alignment.centerLeft);
  final _labelAlignTween =
      AlignmentTween(begin: Alignment.bottomCenter, end: Alignment.centerLeft);
  final double safeOffset;
  final double radius = 24;
  final ImageProvider image;
  final Widget label;

  CollapseHeaderDelegate(
      {@required this.avatar,
      @required this.label,
      @required this.maxHeight,
      @required this.minHeight,
      @required this.safeOffset,
      this.image});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    double tempVal = maxExtent - minExtent;
    final _avatarScaleTween =
        Tween<double>(begin: maxExtent / minExtent - 1, end: 1);
    final _labelScaleTween =
        Tween<double>(begin: maxExtent / minExtent / 2, end: 1);
    final _labelPaddingTween = EdgeInsetsTween(
        begin: EdgeInsets.only(bottom: (maxHeight - minHeight) / 4 - 8),
        end: EdgeInsets.only(left: minHeight));
    final progressCurve = shrinkOffset > tempVal
        ? 1.0
        : Curves.easeInOutQuart.transform(shrinkOffset / tempVal);
    return ClipRRect(
      borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(radius * (progressCurve)),
          bottomRight: Radius.circular(radius * (progressCurve))),
      child: Container(
        // duration: Duration(milliseconds: 100),
        padding: EdgeInsets.only(top: safeOffset),

        constraints: BoxConstraints(maxHeight: maxExtent, minHeight: minExtent),
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
                Theme.of(context).accentColor.withOpacity(progressCurve),
                BlendMode.srcATop),
            fit: BoxFit.cover,
            image: AssetImage('assets/usercenter.jpg'),
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: _avatarAlignTween.lerp(progressCurve),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Transform.scale(
                  scale: _avatarScaleTween.lerp(progressCurve),
                  child: CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: minHeight / 2 - 8,
                    child: CircleAvatar(
                      radius: minHeight / 2 - 9,
                      backgroundImage: image,
                      child: this.avatar,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: _labelAlignTween.lerp(progressCurve),
              child: Padding(
                padding: _labelPaddingTween.lerp(progressCurve),
                child: Transform.scale(
                  scale: _labelScaleTween.lerp(progressCurve),
                  child: this.label,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => this.maxHeight;

  @override
  double get minExtent => this.minHeight + safeOffset;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class ComicHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget avatar;
  final double maxHeight;
  final double minHeight;
  final _avatarAlignTween =
      AlignmentTween(begin: Alignment.center, end: Alignment.centerLeft);
  final _labelAlignTween =
      AlignmentTween(begin: Alignment.topLeft, end: Alignment.topLeft);
  final double safeOffset;
  final double radius = 24;
  final ImageProvider image;
  final Widget label;
  final List<Widget> actions;
  final ColorTween colorFilterTween;

  ComicHeaderDelegate(
      {@required this.avatar,
      @required this.label,
      @required this.maxHeight,
      @required this.minHeight,
      @required this.safeOffset,
      @required this.actions,
      @required this.colorFilterTween,
      this.image});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    double tempVal = maxExtent - minExtent;
    final _avatarScaleTween =
        Tween<double>(begin: maxExtent / minExtent - 1, end: 1);
    final _labelPaddingTween = EdgeInsetsTween(
        begin: EdgeInsets.only(
            top: (maxHeight - minHeight) / 4 - 8,
            left: MediaQuery.of(context).size.shortestSide * 0.40),
        end: EdgeInsets.only(left: 8));
    final progressCurve = shrinkOffset > tempVal
        ? 1.0
        : Curves.easeInOutQuart.transform(shrinkOffset / tempVal);
    return ClipRRect(
      borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(radius * (progressCurve)),
          bottomRight: Radius.circular(radius * (progressCurve))),
      child: Container(
        // duration: Duration(milliseconds: 100),
        padding: EdgeInsets.only(top: safeOffset),

        constraints: BoxConstraints(maxHeight: maxExtent, minHeight: minExtent),
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
                colorFilterTween.lerp(progressCurve), BlendMode.srcATop),
            fit: BoxFit.cover,
            image: this.image,
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: ButtonBar(
                children: this.actions,
              ),
            ),
            Align(
              alignment: _labelAlignTween.lerp(progressCurve),
              child: Padding(
                padding: _labelPaddingTween.lerp(progressCurve),
                child: Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.shortestSide *
                          (0.6 + 0.2 * progressCurve)),
                  child: this.label,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => this.maxHeight;

  @override
  double get minExtent => this.minHeight + safeOffset + kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
